#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.onlineGame = true;
	level.rankedMatch = true;
	level.modifyPlayerDamage = ::modifyPlayerDamage;

	level._effect["flesh_body"] = loadFX( "impacts/flesh_hit_body_fatal_exit" );
	level._effect["flesh_head"] = loadFX( "impacts/flesh_hit_head_fatal_exit" );
	
	// asset precaching
    if ( !isDefined( game["precachedAssets"] ) )
    {
        precacheMenu( "map_voting" );
        precacheMenu( "loadout" );
        precacheMenu( "loadout_select" );
        precacheMenu( "mod_options" );
        precacheMenu( "callvote" );

        precacheItem( "cheytac_irons_mp" );
        precacheItem( "ax50_mp" );
        precacheItem( "m200_mp" );
        precacheItem( "l115a3_mp" );
        precacheItem( "msr_mp" );

        game["precachedAssets"] = true;
    }

	level thread redux\voting::init();
	level thread onPlayerConnect();

	// gameplay changes
	setDvar( "g_knockback", 1 );
	setDvar( "bg_surfacePenetration", 128 );
	setDvar( "player_sprintUnlimited", true );
	setDvar( "bg_viewKickMin", 2 );
	setDvar( "bg_viewKickMax", 10 );
	setDvar( "bg_viewKickRandom", 0.4 );
	setDvar( "bg_viewKickScale", 0.15 );

	if ( level.gametype == "sd" )
	{
		level waittill( "update_scorelimit" );
		setDvar( "ui_allow_teamchange", 0 );
		setDvar( "scr_sd_roundswitch", 0 );
	}
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		if ( !player isTestClient() )
		{
			player.used_slow_last = false;
			player.spawn_message  = false;

			if ( !isDefined( player.pers["loadout"] ) )
				player.pers["loadout"] = [];

			player thread redux\commands::init();
			player thread redux\ui_callbacks::onScriptMenuResponse();
			//player thread redux\private::explosiveBullets();
			player thread spawnMessage();
		}

		if ( level.gametype == "sd" )
			player thread onJoinedTeam();

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "spawned_player" );
		self childthread sustainAmmo();

		self.hasRadar = true;
		self.radarMode = "fast_radar";

		if ( self isTestClient() )
			self childthread botLogPosition();

		if ( level.gametype == "dm" )
		{
			self childthread lastCheck();

			if ( self isTestClient() )
				self childthread botScoreCheck();
		}
	}
}

onJoinedTeam()
{
	self endon( "disconnect" );

    if ( self isTestClient() )
        self maps\mp\gametypes\_menus::addToTeam( "allies", true );
    else
        self maps\mp\gametypes\_menus::addToTeam( "axis", true );

	for ( ;; )
	{
		self waittill_any( "joined_team" );

		// failsafe
		if ( self isTestClient() && self.pers["team"] != "allies" )
			self [[level.allies]]();

		if ( !self isTestClient() && self.pers["team"] != "axis" )
			self [[level.axis]]();
	}
}

spawnMessage()
{
	self endon( "disconnect" );
	self waittill( "spawned_player" );

	if ( !self.spawn_message )
	{
		self iPrintLn( ">>^3 auzziemod IW4" );
		self iPrintLn( ">>^3 https://github.com/simonlfc/auzziemod-iw4" );
		self.spawn_message = true;
	}
}

lastCheck()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "killed_enemy" );

		if ( self isAtLast() )
		{
			self iPrintlnBold( "^1YOU'RE AT LAST. TRICKSHOT OR BE KICKED." );
			return;
		}
	}
}

botScoreCheck()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "killed_enemy" );

		if ( self.pers["score"] > getWatchedDvar( "scorelimit" ) / 2 && getWatchedDvar( "scorelimit" ) != 0 )
		{
			maps\mp\gametypes\_gamescore::_setPlayerScore( self, 0 );
			self.pers["kills"] = 0;
			self.kills = self.pers["kills"];
			maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
		}
	}
}

sustainAmmo()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill_notify_or_timeout( "reload", 10 );

		if ( !isAlive( self ) )
			continue;

		foreach ( weapon in self getWeaponsListAll() )
		{
			if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weapon ) )
				self setWeaponAmmoStock( weapon, weaponMaxAmmo( weapon ) );
			else
				self setWeaponAmmoClip( weapon, self getWeaponAmmoClip( weapon ) + 1 );
		}
	}
}

Select( eval, a, b )
{
	if ( eval )
		return a;

	return b;
}

modifyPlayerDamage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	if ( victim isTestClient() && ( !isDefined( sMeansOfDeath ) || sMeansOfDeath == "MOD_TRIGGER_HURT" ) )
	{
		victim thread botTeleportFix();
		return 0;
	}

	if ( sMeansOfDeath == "MOD_FALLING" )
		return Select( level.gametype == "sd", 0, iDamage );

	if ( isKillstreakWeapon( sWeapon ) )
		return 0;

	if ( eAttacker isTestClient() )
		return Select( victim isTestClient(), iDamage, iDamage * 0.25 );

	if ( sMeansOfDeath == "MOD_MELEE"
	        || sMeansOfDeath == "MOD_GRENADE"
	        || sMeansOfDeath == "MOD_GRENADE_SPLASH"
	        || sMeansOfDeath == "MOD_PROJECTILE"
	        || sMeansOfDeath == "MOD_PROJECTILE_SPLASH"
	        || sMeansOfDeath == "MOD_EXPLOSIVE"
	        || sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 1;

	if ( isSubStr( sWeapon, "gl_" ) && sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 99999;

	if ( isBulletDamage( sMeansOfDeath ) && getWeaponClass( sWeapon ) != "weapon_sniper" )
		iDamage = 1;

	// Mala fix
	if ( isBulletDamage( sMeansOfDeath ) && ( getWeaponClass( sWeapon ) == "weapon_grenade" || getWeaponClass( sWeapon ) == "weapon_explosive" ) )
		iDamage = 99999;

	if ( getWeaponClass( sWeapon ) == "weapon_sniper" || sWeapon == "throwingknife_mp" )
		iDamage = 99999;

	return iDamage;
}

isAtLast()
{
	if ( self.pers["score"] == ( getWatchedDvar( "scorelimit" ) - 50 ) )
		return true;

	return false;
}

consolePrint( head, msg )
{
	printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}

botTeleportFix() // credit to Shockeh
{
	self setOrigin( self.lastOnGround + ( 0, 0, 10 ) );

	self.stop = true;
	self.bot.target = self;
	self.bot.towards_goal = undefined;
	self.bot.script_goal = undefined;

	self notify( "kill_goal" );
	self notify( "new_goal_internal" );
	self notify( "bad_path_internal" );

	wait 7;
	self.stop = undefined;
}

botLogPosition()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	if ( level.gametype == "sd" )
		self endon( "death" );

	self.lastOnGround = ( 0, 0, 0 );

	for ( ;; )
	{
		if ( self isOnGround() )
			self.lastOnGround = self.origin;

		wait 5;
	}
}
