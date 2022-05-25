/*
	_bot
	Author: INeedGames
	Date: 09/26/2020
	The entry point and manager of the bots.
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include thirdparty\bot_warfare\_bot_utility;

/*
	Initiates the whole bot scripts.
*/
init()
{
	level.bw_VERSION = "2.0.0";

	setDvarIfUninitialized( "bots_main", true );

	thread load_waypoints();
	thread hook_callbacks();

	switch ( level.gametype )
	{
	case "sd":
		setDvarIfUninitialized( "bots_manage_add", 2 );			  // amount of bots to add to the game
		setDvarIfUninitialized( "bots_manage_fill", 2 );		  // amount of bots to maintain
		setDvarIfUninitialized( "bots_manage_fill_mode", 1 );	  // fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
		setDvarIfUninitialized( "bots_manage_fill_kick", false ); // kick bots if too many
		setDvarIfUninitialized( "bots_team", "axis" );			  // which team for bots to join
		setDvarIfUninitialized( "bots_team_force", true );		  // force bots on team
		setDvarIfUninitialized( "bots_team_mode", 1 );			  // counts just bots when 1
		break;
	default:
		setDvarIfUninitialized( "bots_manage_add", 0 );			 // amount of bots to add to the game
		setDvarIfUninitialized( "bots_manage_fill", 12 );		 // amount of bots to maintain
		setDvarIfUninitialized( "bots_manage_fill_mode", 0 );	 // fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
		setDvarIfUninitialized( "bots_manage_fill_kick", true ); // kick bots if too many
		setDvarIfUninitialized( "bots_team", "autoassign" );	 // which team for bots to join
		setDvarIfUninitialized( "bots_team_force", false );		 // force bots on team
		setDvarIfUninitialized( "bots_team_mode", 0 );			 // counts just bots when 1
		break;
	}

	setDvarIfUninitialized( "bots_main_GUIDs", "" );		  // guids of players who will be given host powers, comma seperated
	setDvarIfUninitialized( "bots_main_firstIsHost", false ); // first play to connect is a host

	setDvarIfUninitialized( "bots_manage_add", 0 );			 // amount of bots to add to the game
	setDvarIfUninitialized( "bots_manage_fill", 12 );		 // amount of bots to maintain
	setDvarIfUninitialized( "bots_manage_fill_mode", 0 );	 // fill mode, 0 adds everyone, 1 just bots, 2 maintains at maps, 3 is 2 with 1
	setDvarIfUninitialized( "bots_manage_fill_kick", true ); // kick bots if too many
	setDvarIfUninitialized( "bots_team", "autoassign" );	 // which team for bots to join
	setDvarIfUninitialized( "bots_team_force", false );		 // force bots on team
	setDvarIfUninitialized( "bots_team_mode", 0 );			 // counts just bots when 1
	setDvarIfUninitialized( "bots_manage_fill_spec", true ); // to count for fill if player is on spec team
	setDvarIfUninitialized( "bots_team_amount", 0 );		 // amount of bots on axis team

	setDvarIfUninitialized( "bots_skill", 2 );			 // 0 is random, 1 is easy 7 is hard, 8 is custom, 9 is completely random
	setDvarIfUninitialized( "bots_skill_axis_hard", 0 ); // amount of hard bots on axis team
	setDvarIfUninitialized( "bots_skill_axis_med", 0 );
	setDvarIfUninitialized( "bots_skill_allies_hard", 0 );
	setDvarIfUninitialized( "bots_skill_allies_med", 0 );

	setDvarIfUninitialized( "bots_loadout_reasonable", true );
	setDvarIfUninitialized( "bots_loadout_allow_op", false );
	setDvarIfUninitialized( "bots_loadout_rank", 0 );
	setDvarIfUninitialized( "bots_loadout_prestige", -1 );

	setDvarIfUninitialized( "bots_play_move", true );
	setDvarIfUninitialized( "bots_play_knife", false );
	setDvarIfUninitialized( "bots_play_fire", true );
	setDvarIfUninitialized( "bots_play_nade", true );
	setDvarIfUninitialized( "bots_play_take_carepackages", false );
	setDvarIfUninitialized( "bots_play_obj", false );
	setDvarIfUninitialized( "bots_play_camp", true );
	setDvarIfUninitialized( "bots_play_jumpdrop", false );
	setDvarIfUninitialized( "bots_play_target_other", false );
	setDvarIfUninitialized( "bots_play_killstreak", false );
	setDvarIfUninitialized( "bots_play_ads", false );

	if ( !isDefined( game["botWarfare"] ) )
	{
		game["botWarfare"] = true;
	}

	level.defuseObject			 = undefined;
	level.bots_smokeList		 = List();
	level.bots_fragList			 = List();

	level.bots_minSprintDistance = 315;
	level.bots_minSprintDistance *= level.bots_minSprintDistance;
	level.bots_minGrenadeDistance = 256;
	level.bots_minGrenadeDistance *= level.bots_minGrenadeDistance;
	level.bots_maxGrenadeDistance = 1024;
	level.bots_maxGrenadeDistance *= level.bots_maxGrenadeDistance;
	level.bots_maxKnifeDistance = 80;
	level.bots_maxKnifeDistance *= level.bots_maxKnifeDistance;
	level.bots_goalDistance = 27.5;
	level.bots_goalDistance *= level.bots_goalDistance;
	level.bots_noADSDistance = 200;
	level.bots_noADSDistance *= level.bots_noADSDistance;
	level.bots_maxShotgunDistance = 500;
	level.bots_maxShotgunDistance *= level.bots_maxShotgunDistance;
	level.bots_listenDist = 100;
	level.bots_listenDist *= level.bots_listenDist;

	level.smokeRadius					   = 255;

	level.bots							   = [];

	level.bots_fullautoguns				   = [];
	level.bots_fullautoguns["aa12"]		   = true;
	level.bots_fullautoguns["ak47"]		   = true;
	level.bots_fullautoguns["aug"]		   = true;
	level.bots_fullautoguns["fn2000"]	   = true;
	level.bots_fullautoguns["glock"]	   = true;
	level.bots_fullautoguns["kriss"]	   = true;
	level.bots_fullautoguns["m4"]		   = true;
	level.bots_fullautoguns["m240"]		   = true;
	level.bots_fullautoguns["masada"]	   = true;
	level.bots_fullautoguns["mg4"]		   = true;
	level.bots_fullautoguns["mp5k"]		   = true;
	level.bots_fullautoguns["p90"]		   = true;
	level.bots_fullautoguns["pp2000"]	   = true;
	level.bots_fullautoguns["rpd"]		   = true;
	level.bots_fullautoguns["sa80"]		   = true;
	level.bots_fullautoguns["scar"]		   = true;
	level.bots_fullautoguns["tavor"]	   = true;
	level.bots_fullautoguns["tmp"]		   = true;
	level.bots_fullautoguns["ump45"]	   = true;
	level.bots_fullautoguns["uzi"]		   = true;

	level.bots_fullautoguns["ac130"]	   = true;
	level.bots_fullautoguns["heli"]		   = true;

	level.bots_fullautoguns["ak47classic"] = true;
	level.bots_fullautoguns["ak74u"]	   = true;
	level.bots_fullautoguns["peacekeeper"] = true;

	level thread fixGamemodes();

	level thread onPlayerConnect();
	level thread addNotifyOnAirdrops();
	level thread watchScrabler();

	level thread handleBots();
}

/*
	Starts the threads for bots.
*/
handleBots()
{
	level thread teamBots();
	level thread diffBots();
	level addBots();

	while ( !level.intermission )
	{
		wait 0.05;
	}

	setDvar( "bots_manage_add", getBotArray().size );
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( self isTestClient() )
	{
		self thirdparty\bot_warfare\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self thirdparty\bot_warfare\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	}

	self [[level.prevCallbackPlayerDamage]] ( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if ( self isTestClient() )
	{
		self thirdparty\bot_warfare\_bot_internal::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
		self thirdparty\bot_warfare\_bot_script::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
	}

	self [[level.prevCallbackPlayerKilled]] ( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	level waittill( "prematch_over" ); // iw4madmin waits this long for some reason...
	wait 0.05;						   // so we need to be one frame after it sets up its callbacks.
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage	   = ::onPlayerDamage;

	level.prevCallbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerKilled	   = ::onPlayerKilled;
}

/*
	Fixes gamemodes when level starts.
*/
fixGamemodes()
{
	for ( i = 0; i < 19; i++ )
	{
		if ( isDefined( level.bombZones ) && level.gametype == "sd" )
		{
			for ( i = 0; i < level.bombZones.size; i++ )
			{
				level.bombZones[i].onUse = ::onUsePlantObjectFix;
			}
			break;
		}

		if ( isDefined( level.radios ) && level.gametype == "koth" )
		{
			level thread fixKoth();

			break;
		}

		if ( isDefined( level.bombZones ) && level.gametype == "dd" )
		{
			level thread fixDem();

			break;
		}

		wait 0.05;
	}
}

/*
	Converts t5 dd to iw4
*/
fixDem()
{
	for ( ;; )
	{
		level.bombAPlanted = level.aPlanted;
		level.bombBPlanted = level.bPlanted;

		for ( i = 0; i < level.bombZones.size; i++ )
		{
			bombzone = level.bombZones[i];

			if ( isDefined( bombzone.trigger.trigger_off ) )
			{
				bombzone.bombExploded = true;
			}
			else
			{
				bombzone.bombExploded = undefined;
			}
		}

		wait 0.05;
	}
}

/*
	Fixes the king of the hill headquarters obj
*/
fixKoth()
{
	level.radio = undefined;

	for ( ;; )
	{
		wait 0.05;

		if ( !isDefined( level.radioObject ) )
		{
			continue;
		}

		for ( i = level.radios.size - 1; i >= 0; i-- )
		{
			if ( level.radioObject != level.radios[i].gameobject )
			{
				continue;
			}

			level.radio = level.radios[i];
			break;
		}

		while ( isDefined( level.radioObject ) && level.radio.gameobject == level.radioObject )
		{
			wait 0.05;
		}
	}
}

/*
	Adds a notify when the airdrop is dropped
*/
addNotifyOnAirdrops()
{
	for ( ;; )
	{
		wait 1;
		dropCrates = getEntArray( "care_package", "targetname" );

		for ( i = dropCrates.size - 1; i >= 0; i-- )
		{
			airdrop = dropCrates[i];

			if ( !isDefined( airdrop.owner ) )
			{
				continue;
			}

			if ( isDefined( airdrop.doingPhysics ) )
			{
				continue;
			}

			airdrop.doingPhysics = true;
			airdrop thread doNotifyOnAirdrop();
		}
	}
}

/*
	Does the notify
*/
doNotifyOnAirdrop()
{
	self endon( "death" );
	self waittill( "physics_finished" );

	self.doingPhysics = false;
	self.owner notify( "crate_physics_done" );
}

/*
	Thread when any player connects. Starts the threads needed.
*/
onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		player thread onGrenadeFire();
		player thread onWeaponFired();

		player thread connected();
	}
}

/*
	Watches players with scrambler perk
*/
watchScrabler()
{
	for ( ;; )
	{
		wait 1;

		for ( i = level.players.size - 1; i >= 0; i-- )
		{
			player				   = level.players[i];

			player.bot_isScrambled = false;

			if ( !player _HasPerk( "specialty_localjammer" ) || !isReallyAlive( player ) )
			{
				continue;
			}

			if ( player isEMPed() )
			{
				continue;
			}

			for ( h = level.players.size - 1; h >= 0; h-- )
			{
				player2 = level.players[h];

				if ( player2 == player )
				{
					continue;
				}

				if ( level.teamBased && player2.team == player.team )
				{
					continue;
				}

				if ( DistanceSquared( player2.origin, player.origin ) > 100 * 100 )
				{
					continue;
				}

				player.bot_isScrambled = true;
			}
		}
	}
}

/*
	When a bot disconnects.
*/
onDisconnect()
{
	self waittill( "disconnect" );

	level.bots = array_remove( level.bots, self );
}

/*
	Called when a player connects.
*/
connected()
{
	self endon( "disconnect" );

	if ( !isDefined( self.pers["bot_host"] ) )
	{
		self thread doHostCheck();
	}

	if ( !self isTestClient() )
	{
		return;
	}

	if ( !isDefined( self.pers["isBot"] ) )
	{
		// fast_restart occured...
		self.pers["isBot"] = true;
	}

	if ( !isDefined( self.pers["isBotWarfare"] ) )
	{
		self.pers["isBotWarfare"] = true;
		self thread added();
	}

	self thread thirdparty\bot_warfare\_bot_internal::connected();
	self thread thirdparty\bot_warfare\_bot_script::connected();

	level.bots[level.bots.size] = self;
	self thread onDisconnect();

	level notify( "bot_connected", self );
}

/*
	When a bot gets added into the game.
*/
added()
{
	self endon( "disconnect" );

	self thread thirdparty\bot_warfare\_bot_internal::added();
	self thread thirdparty\bot_warfare\_bot_script::added();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();

	if ( isdefined( bot ) )
	{
		bot.pers["isBot"]		 = true;
		bot.pers["isBotWarfare"] = true;
		bot thread added();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots()
{
	for ( ;; )
	{
		wait 1.5;

		var_allies_hard = getDVarInt( "bots_skill_allies_hard" );
		var_allies_med	= getDVarInt( "bots_skill_allies_med" );
		var_axis_hard	= getDVarInt( "bots_skill_axis_hard" );
		var_axis_med	= getDVarInt( "bots_skill_axis_med" );
		var_skill		= getDvarInt( "bots_skill" );

		allies_hard		= 0;
		allies_med		= 0;
		axis_hard		= 0;
		axis_med		= 0;

		if ( var_skill == 8 )
		{
			playercount = level.players.size;
			for ( i = 0; i < playercount; i++ )
			{
				player = level.players[i];

				if ( !isDefined( player.pers["team"] ) )
				{
					continue;
				}

				if ( !player isTestClient() )
				{
					continue;
				}

				if ( player.pers["team"] == "axis" )
				{
					if ( axis_hard < var_axis_hard )
					{
						axis_hard++;
						player.pers["bots"]["skill"]["base"] = 7;
					}
					else if ( axis_med < var_axis_med )
					{
						axis_med++;
						player.pers["bots"]["skill"]["base"] = 4;
					}
					else
					{
						player.pers["bots"]["skill"]["base"] = 1;
					}
				}
				else if ( player.pers["team"] == "allies" )
				{
					if ( allies_hard < var_allies_hard )
					{
						allies_hard++;
						player.pers["bots"]["skill"]["base"] = 7;
					}
					else if ( allies_med < var_allies_med )
					{
						allies_med++;
						player.pers["bots"]["skill"]["base"] = 4;
					}
					else
					{
						player.pers["bots"]["skill"]["base"] = 1;
					}
				}
			}
		}
		else if ( var_skill != 0 && var_skill != 9 )
		{
			playercount = level.players.size;
			for ( i = 0; i < playercount; i++ )
			{
				player = level.players[i];

				if ( !player isTestClient() )
				{
					continue;
				}

				player.pers["bots"]["skill"]["base"] = var_skill;
			}
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	for ( ;; )
	{
		wait 1.5;
		teamAmount	  = getDvarInt( "bots_team_amount" );
		toTeam		  = getDvar( "bots_team" );

		alliesbots	  = 0;
		alliesplayers = 0;
		axisbots	  = 0;
		axisplayers	  = 0;

		playercount	  = level.players.size;
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( !isDefined( player.pers["team"] ) )
			{
				continue;
			}

			if ( player isTestClient() )
			{
				if ( player.pers["team"] == "allies" )
				{
					alliesbots++;
				}
				else if ( player.pers["team"] == "axis" )
				{
					axisbots++;
				}
			}
			else
			{
				if ( player.pers["team"] == "allies" )
				{
					alliesplayers++;
				}
				else if ( player.pers["team"] == "axis" )
				{
					axisplayers++;
				}
			}
		}

		allies = alliesbots;
		axis   = axisbots;

		if ( !getDvarInt( "bots_team_mode" ) )
		{
			allies += alliesplayers;
			axis += axisplayers;
		}

		if ( toTeam != "custom" )
		{
			if ( getDvarInt( "bots_team_force" ) )
			{
				if ( toTeam == "autoassign" )
				{
					if ( abs( axis - allies ) > 1 )
					{
						toTeam = "axis";
						if ( axis > allies )
						{
							toTeam = "allies";
						}
					}
				}

				if ( toTeam != "autoassign" )
				{
					playercount = level.players.size;
					for ( i = 0; i < playercount; i++ )
					{
						player = level.players[i];

						if ( !isDefined( player.pers["team"] ) )
						{
							continue;
						}

						if ( !player isTestClient() )
						{
							continue;
						}

						if ( player.pers["team"] == toTeam )
						{
							continue;
						}

						if ( toTeam == "allies" )
						{
							player thread [[level.allies]] ();
						}
						else if ( toTeam == "axis" )
						{
							player thread [[level.axis]] ();
						}
						else
						{
							player thread [[level.spectator]] ();
						}
						break;
					}
				}
			}
		}
		else
		{
			playercount = level.players.size;
			for ( i = 0; i < playercount; i++ )
			{
				player = level.players[i];

				if ( !isDefined( player.pers["team"] ) )
				{
					continue;
				}

				if ( !player isTestClient() )
				{
					continue;
				}

				if ( player.pers["team"] == "axis" )
				{
					if ( axis > teamAmount )
					{
						player thread [[level.allies]] ();
						break;
					}
				}
				else
				{
					if ( axis < teamAmount )
					{
						player thread [[level.axis]] ();
						break;
					}
					else if ( player.pers["team"] != "allies" )
					{
						player thread [[level.allies]] ();
						break;
					}
				}
			}
		}
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots()
{
	level endon( "game_ended" );

	for ( ;; )
	{
		wait 1;

		botsToAdd = GetDvarInt( "bots_manage_add" );

		if ( botsToAdd > 0 )
		{
			SetDvar( "bots_manage_add", 0 );

			if ( botsToAdd > 64 )
			{
				botsToAdd = 64;
			}

			for ( ; botsToAdd > 0; botsToAdd-- )
			{
				level add_bot();
				wait 0.1;
			}
		}

		fillMode = getDVarInt( "bots_manage_fill_mode" );

		if ( fillMode == 2 || fillMode == 3 )
		{
			setDvar( "bots_manage_fill", getGoodMapAmount() );
		}

		fillAmount	= getDvarInt( "bots_manage_fill" );

		players		= 0;
		bots		= 0;
		spec		= 0;

		playercount = level.players.size;
		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( player isTestClient() )
			{
				bots++;
			}
			else if ( !isDefined( player.pers["team"] ) || ( player.pers["team"] != "axis" && player.pers["team"] != "allies" ) )
			{
				spec++;
			}
			else
			{
				players++;
			}
		}

		if ( fillMode == 4 )
		{
			axisplayers	  = 0;
			alliesplayers = 0;

			playercount	  = level.players.size;
			for ( i = 0; i < playercount; i++ )
			{
				player = level.players[i];

				if ( player isTestClient() )
				{
					continue;
				}

				if ( !isDefined( player.pers["team"] ) )
				{
					continue;
				}

				if ( player.pers["team"] == "axis" )
				{
					axisplayers++;
				}
				else if ( player.pers["team"] == "allies" )
				{
					alliesplayers++;
				}
			}

			result = fillAmount - abs( axisplayers - alliesplayers ) + bots;

			if ( players == 0 )
			{
				if ( bots < fillAmount )
				{
					result = fillAmount - 1;
				}
				else if ( bots > fillAmount )
				{
					result = fillAmount + 1;
				}
				else
				{
					result = fillAmount;
				}
			}

			bots = result;
		}

		amount = bots;
		if ( fillMode == 0 || fillMode == 2 )
		{
			amount += players;
		}
		if ( getDVarInt( "bots_manage_fill_spec" ) )
		{
			amount += spec;
		}

		if ( amount < fillAmount )
		{
			setDvar( "bots_manage_add", 1 );
		}
		else if ( amount > fillAmount && getDvarInt( "bots_manage_fill_kick" ) )
		{
			tempBot = random( getBotArray() );
			if ( isDefined( tempBot ) )
			{
				kick( tempBot getEntityNumber(), "EXE_PLAYERKICKED" );
			}
		}
	}
}

/*
	A thread for ALL players, will monitor and grenades thrown.
*/
onGrenadeFire()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "grenade_fire", grenade, weaponName );
		grenade.name = weaponName;

		if ( weaponName == "smoke_grenade_mp" )
		{
			grenade thread AddToSmokeList();
		}
		else if ( isSubStr( weaponName, "frag_" ) )
		{
			grenade thread AddToFragList( self );
		}
	}
}

/*
	Adds a frag grenade to the list of all frags
*/
AddToFragList( who )
{
	grenade			  = spawnstruct();
	grenade.origin	  = self getOrigin();
	grenade.velocity  = ( 0, 0, 0 );
	grenade.grenade	  = self;
	grenade.owner	  = who;
	grenade.team	  = who.team;
	grenade.throwback = undefined;

	grenade thread thinkFrag();

	level.bots_fragList ListAdd( grenade );
}

/*
	Watches while the frag exists
*/
thinkFrag()
{
	while ( isDefined( self.grenade ) )
	{
		nowOrigin	  = self.grenade getOrigin();
		self.velocity = ( nowOrigin - self.origin ) * 20;
		self.origin	  = nowOrigin;

		wait 0.05;
	}

	level.bots_fragList ListRemove( self );
}

/*
	Adds a smoke grenade to the list of smokes in the game. Used to prevent bots from seeing through smoke.
*/
AddToSmokeList()
{
	grenade			= spawnstruct();
	grenade.origin	= self getOrigin();
	grenade.state	= "moving";
	grenade.grenade = self;

	grenade thread thinkSmoke();

	level.bots_smokeList ListAdd( grenade );
}

/*
	The smoke grenade logic.
*/
thinkSmoke()
{
	while ( isDefined( self.grenade ) )
	{
		self.origin = self.grenade getOrigin();
		self.state	= "moving";
		wait 0.05;
	}
	self.state = "smoking";
	wait 11.5;

	level.bots_smokeList ListRemove( self );
}

/*
	A thread for ALL players when they fire.
*/
onWeaponFired()
{
	self endon( "disconnect" );
	self.bots_firing = false;
	for ( ;; )
	{
		self waittill( "weapon_fired" );
		self thread doFiringThread();
	}
}

/*
	Lets bot's know that the player is firing.
*/
doFiringThread()
{
	self endon( "disconnect" );
	self endon( "weapon_fired" );
	self.bots_firing = true;
	wait 1;
	self.bots_firing = false;
}
