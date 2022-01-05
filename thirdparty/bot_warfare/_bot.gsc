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
	thread load_waypoints();
	thread hook_callbacks();

	register_bot_var( "manage_add", 0 );						// [int] Amount of bots to add to the game
	register_bot_var( "manage_fill", 12 );						// [int] Amount of bots to maintain
	register_bot_var( "manage_fill_spec", true );				// [bool] To count for fill if player is on spectator team
	register_bot_var( "manage_fill_mode", 0 );					// [0] - add everyone | [1] - just bots | [2] - maintains at maps | [3] maintains at maps, just bots
	register_bot_var( "manage_fill_kick", true );				// [bool] Kick bots if too many are added
	register_bot_var( "manage_team", "autoassign" );			// ["allies", "axis", "autoassign"] What team should bots join
	register_bot_var( "manage_team_amount", 0 );				// [int] Amount of bots on Axis team
	register_bot_var( "manage_team_force", false );				// [bool] Force bots on team
	register_bot_var( "manage_team_mode", false );				// [bool] Should count bots
	register_bot_var( "manage_kick_at_end", false );			// [bool] Kicks bots at the end of a game

	register_bot_var( "skill_level", 2 );						// [0] - random | [1] - easy <---> [7] hard | 8 - custom | 9 - completely random

	register_bot_var( "profile_rank", -2 );						// [-2] - based around players | [-1] - random | [0+] use var
	register_bot_var( "profile_prestige", -2 );					// [-2] - based around players | [-1] - random | [0+] use var

	register_bot_var( "core_move", true );						// [bool] Allow bots to move
	register_bot_var( "core_advmove", true );					// [bool] Allow bots to jump and dropshot
	register_bot_var( "core_melee", true );						// [bool] Allow bots to melee
	register_bot_var( "core_ads", true );						// [bool] Allow bots to aim down sights
	register_bot_var( "core_aim", true );						// [bool] Allow bots to aim
	register_bot_var( "core_fire", true );						// [bool] Allow bots to fire
	register_bot_var( "core_grenade", true );					// [bool] Allow bots to use grenades
	register_bot_var( "core_airdrop", true );					// [bool] Allow bots to take airdrops
	register_bot_var( "core_obj", true );						// [bool] Allow bots to play the objective
	register_bot_var( "core_camp", true );						// [bool] Allow bots to camp
	register_bot_var( "core_target_other", true );				// [bool] Allow bots to target non-player entities
	register_bot_var( "core_streak", true );					// [bool] Allow bots to use killstreaks


	level.defuseObject = undefined;
	level.bots_smokeList = List();
	level.bots_fragList = List();

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

	level.smokeRadius = 255;

	level.bots = [];

	level.bots_fullautoguns = [];
	level.bots_fullautoguns["aa12"] = true;
	level.bots_fullautoguns["ak47"] = true;
	level.bots_fullautoguns["aug"] = true;
	level.bots_fullautoguns["fn2000"] = true;
	level.bots_fullautoguns["glock"] = true;
	level.bots_fullautoguns["kriss"] = true;
	level.bots_fullautoguns["m4"] = true;
	level.bots_fullautoguns["m240"] = true;
	level.bots_fullautoguns["masada"] = true;
	level.bots_fullautoguns["mg4"] = true;
	level.bots_fullautoguns["mp5k"] = true;
	level.bots_fullautoguns["p90"] = true;
	level.bots_fullautoguns["pp2000"] = true;
	level.bots_fullautoguns["rpd"] = true;
	level.bots_fullautoguns["sa80"] = true;
	level.bots_fullautoguns["scar"] = true;
	level.bots_fullautoguns["tavor"] = true;
	level.bots_fullautoguns["tmp"] = true;
	level.bots_fullautoguns["ump45"] = true;
	level.bots_fullautoguns["uzi"] = true;

	level.bots_fullautoguns["ac130"] = true;
	level.bots_fullautoguns["heli"] = true;

	level.bots_fullautoguns["ak47classic"] = true;
	level.bots_fullautoguns["ak74u"] = true;
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
		wait 0.05;

	set_bot_var( "manage_add", getBotArray().size );

	if ( get_bot_var( "manage_kick_at_end" ) )
		return;

	bots = getBotArray();

	for ( i = 0; i < bots.size; i++ )
	{
		kick( bots[i] getEntityNumber(), "EXE_PLAYERKICKED" );
	}
}

/*
	The hook callback for when any player becomes damaged.
*/
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
	if ( self isBot() )
	{
		self thirdparty\bot_warfare\_bot_internal::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self thirdparty\bot_warfare\_bot_script::onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
	}

	self [[level.prevCallbackPlayerDamage]]( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
}

/*
	The hook callback when any player gets killed.
*/
onPlayerKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if ( self isBot() )
	{
		self thirdparty\bot_warfare\_bot_internal::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
		self thirdparty\bot_warfare\_bot_script::onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
	}

	self [[level.prevCallbackPlayerKilled]]( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration );
}

/*
	Starts the callbacks.
*/
hook_callbacks()
{
	level waittill( "prematch_over" ); // iw4madmin waits this long for some reason...
	wait 0.05; // so we need to be one frame after it sets up its callbacks.
	level.prevCallbackPlayerDamage = level.callbackPlayerDamage;
	level.callbackPlayerDamage = ::onPlayerDamage;

	level.prevCallbackPlayerKilled = level.callbackPlayerKilled;
	level.callbackPlayerKilled = ::onPlayerKilled;
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
				level.bombZones[i].onUse = ::onUsePlantObjectFix;

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
				bombzone.bombExploded = true;
			else
				bombzone.bombExploded = undefined;
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
				continue;

			level.radio = level.radios[i];
			break;
		}

		while ( isDefined( level.radioObject ) && level.radio.gameobject == level.radioObject )
			wait 0.05;
	}
}

/*
	Adds a notify when the airdrop is dropped
*/
addNotifyOnAirdrops_loop()
{
	dropCrates = getEntArray( "care_package", "targetname" );

	for ( i = dropCrates.size - 1; i >= 0; i-- )
	{
		airdrop = dropCrates[i];

		if ( !isDefined( airdrop.owner ) )
			continue;

		if ( isDefined( airdrop.doingPhysics ) )
			continue;

		airdrop.doingPhysics = true;
		airdrop thread doNotifyOnAirdrop();
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
		addNotifyOnAirdrops_loop();
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

		player.bot_isScrambled = false;

		player thread onGrenadeFire();
		player thread onWeaponFired();

		player thread connected();
	}
}

/*
	Watches players with scrambler perk
*/
watchScrabler_loop()
{
	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];
		player.bot_isScrambled = false;
	}

	for ( i = level.players.size - 1; i >= 0; i-- )
	{
		player = level.players[i];

		if ( !player _HasPerk( "specialty_localjammer" ) || !isReallyAlive( player ) )
			continue;

		if ( player isEMPed() )
			continue;

		for ( h = level.players.size - 1; h >= 0; h-- )
		{
			player2 = level.players[h];

			if ( player2 == player )
				continue;

			if ( level.teamBased && player2.team == player.team )
				continue;

			if ( DistanceSquared( player2.origin, player.origin ) > 256 * 256 )
				continue;

			player2.bot_isScrambled = true;
		}
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

		watchScrabler_loop();
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

	if ( !self isBot() )
		return;

	self thread added();

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

	self thread thirdparty\bot_warfare\_bot_internal::init_pers_variables();
	self thread thirdparty\bot_warfare\_bot_script::init_new_bot();
}

/*
	Adds a bot to the game.
*/
add_bot()
{
	bot = addtestclient();

	if ( isdefined( bot ) )
	{
		bot thread added();
	}
}

/*
	A server thread for monitoring all bot's difficulty levels for custom server settings.
*/
diffBots_loop()
{
	var_skill = get_bot_var( "skill_level" );
	
	if ( var_skill != 0 && var_skill != 9 )
	{
		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( !player isBot() )
				continue;

			player.pers["bots"]["skill"]["base"] = var_skill;
		}
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

		diffBots_loop();
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots_loop()
{
	teamAmount = get_bot_var( "manage_team_amount" );
	toTeam = get_bot_var( "manage_team" );

	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( !isDefined( player.pers["team"] ) )
			continue;

		if ( player isBot() )
		{
			if ( player.pers["team"] == "allies" )
				alliesbots++;
			else if ( player.pers["team"] == "axis" )
				axisbots++;
		}
		else
		{
			if ( player.pers["team"] == "allies" )
				alliesplayers++;
			else if ( player.pers["team"] == "axis" )
				axisplayers++;
		}
	}

	allies = alliesbots;
	axis = axisbots;

	if ( !get_bot_var( "manage_team_mode" ) )
	{
		allies += alliesplayers;
		axis += axisplayers;
	}

	if ( toTeam != "custom" )
	{
		if ( get_bot_var( "manage_team_force" ) )
		{
			if ( toTeam == "autoassign" )
			{
				if ( abs( axis - allies ) > 1 )
				{
					toTeam = "axis";

					if ( axis > allies )
						toTeam = "allies";
				}
			}

			if ( toTeam != "autoassign" )
			{
				playercount = level.players.size;

				for ( i = 0; i < playercount; i++ )
				{
					player = level.players[i];

					if ( !isDefined( player.pers["team"] ) )
						continue;

					if ( !player isBot() )
						continue;

					if ( player.pers["team"] == toTeam )
						continue;

					if ( toTeam == "allies" )
						player thread [[level.allies]]();
					else if ( toTeam == "axis" )
						player thread [[level.axis]]();
					else
						player thread [[level.spectator]]();

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
				continue;

			if ( !player isBot() )
				continue;

			if ( player.pers["team"] == "axis" )
			{
				if ( axis > teamAmount )
				{
					player thread [[level.allies]]();
					break;
				}
			}
			else
			{
				if ( axis < teamAmount )
				{
					player thread [[level.axis]]();
					break;
				}
				else if ( player.pers["team"] != "allies" )
				{
					player thread [[level.allies]]();
					break;
				}
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
		teamBots_loop();
	}
}

/*
	A server thread for monitoring all bot's in game. Will add and kick bots according to server settings.
*/
addBots_loop()
{
	botsToAdd = get_bot_var( "manage_add" );

	if ( botsToAdd > 0 )
	{
		set_bot_var( "manage_add", 0 );

		if ( botsToAdd > 64 )
			botsToAdd = 64;

		for ( ; botsToAdd > 0; botsToAdd-- )
		{
			level add_bot();
			wait 0.25;
		}
	}

	fillMode = get_bot_var( "manage_fill_mode" );

	if ( fillMode == 2 || fillMode == 3 )
		set_bot_var( "manage_fill", getGoodMapAmount() );

	fillAmount = get_bot_var( "manage_fill" );

	players = 0;
	bots = 0;
	spec = 0;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[i];

		if ( player isBot() )
			bots++;
		else if ( !isDefined( player.pers["team"] ) || ( player.pers["team"] != "axis" && player.pers["team"] != "allies" ) )
			spec++;
		else
			players++;
	}
	
	if ( fillMode == 4 )
	{
		axisplayers = 0;
		alliesplayers = 0;

		playercount = level.players.size;

		for ( i = 0; i < playercount; i++ )
		{
			player = level.players[i];

			if ( player isBot() )
				continue;

			if ( !isDefined( player.pers["team"] ) )
				continue;

			if ( player.pers["team"] == "axis" )
				axisplayers++;
			else if ( player.pers["team"] == "allies" )
				alliesplayers++;
		}

		result = fillAmount - abs( axisplayers - alliesplayers ) + bots;

		if ( players == 0 )
		{
			if ( bots < fillAmount )
				result = fillAmount - 1;
			else if ( bots > fillAmount )
				result = fillAmount + 1;
			else
				result = fillAmount;
		}

		bots = result;
	}

	amount = bots;

	if ( fillMode == 0 || fillMode == 2 )
		amount += players;

	if ( get_bot_var( "manage_fill_spec" ) )
		amount += spec;

	if ( amount < fillAmount )
		set_bot_var( "manage_add", 1 );
	else if ( amount > fillAmount && get_bot_var( "manage_fill_kick" ) )
	{
		tempBot = random( getBotArray() );

		if ( isDefined( tempBot ) )
			kick( tempBot getEntityNumber(), "EXE_PLAYERKICKED" );
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
		wait 1.5;

		addBots_loop();
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
		self waittill ( "grenade_fire", grenade, weaponName );

		if ( !isDefined( grenade ) )
			continue;

		grenade.name = weaponName;

		if ( weaponName == "smoke_grenade_mp" )
			grenade thread AddToSmokeList();
		else if ( isSubStr( weaponName, "frag_" ) )
			grenade thread AddToFragList( self );
	}
}

/*
	Adds a frag grenade to the list of all frags
*/
AddToFragList( who )
{
	grenade = spawnstruct();
	grenade.origin = self getOrigin();
	grenade.velocity = ( 0, 0, 0 );
	grenade.grenade = self;
	grenade.owner = who;
	grenade.team = who.team;
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
		nowOrigin = self.grenade getOrigin();
		self.velocity = ( nowOrigin - self.origin ) * 20;
		self.origin = nowOrigin;

		wait 0.05;
	}

	level.bots_fragList ListRemove( self );
}

/*
	Adds a smoke grenade to the list of smokes in the game. Used to prevent bots from seeing through smoke.
*/
AddToSmokeList()
{
	grenade = spawnstruct();
	grenade.origin = self getOrigin();
	grenade.state = "moving";
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
		self.state = "moving";
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
