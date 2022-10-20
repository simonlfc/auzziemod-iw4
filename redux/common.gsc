#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{    
    level.onlineGame            = true;
    level.rankedMatch           = true;
    level.modifyPlayerDamage    = ::modify_player_damage;

    level._effect["flesh_body"] = loadFX( "impacts/flesh_hit_body_fatal_exit" );
    level._effect["flesh_head"] = loadFX( "impacts/flesh_hit_head_fatal_exit" );

    precacheMenu( "map_voting" );
    precacheMenu( "loadout" );
    precacheMenu( "loadout_select" );
    precacheMenu( "mod_options" );
    precacheMenu( "callvote" );
    precacheMenu( "loadout_init" );

    precacheItem( "cheytac_irons_mp" );
    precacheItem( "ax50_mp" );
    precacheItem( "m200_mp" );
    precacheItem( "l115a3_mp" );
    precacheItem( "msr_mp" );

    level thread redux\voting::init();
    level thread on_player_connect();

    setDvar( "bg_surfacePenetration", 128 );

    // ever so slightly hacky
    if ( level.gametype == "sd" )
    {
        level waittill( "update_scorelimit" );
        setDvar( "ui_allow_teamchange", 0 );
        setDvar( "scr_sd_roundswitch", 0 );
    }
}

on_player_connect()
{
    for(;;)
    {
        level waittill( "connected", player );
        
        if ( !player isTestClient() )
        {
            player.used_slow_last = false;
            player.spawn_message  = false;
            
            if ( !isDefined( player.pers["loadout"] ) )
                player.pers["loadout"] = [];

            player thread redux\commands::init();
            player thread redux\ui_callbacks::on_script_menu_response();
            //player thread redux\private::explosive_bullets();
            player thread spawn_message();
        }
        else
        {
            player thread bot_ping();
        }

        if ( level.gametype == "sd" )
            player thread on_joined_team();

        player thread on_player_spawned();
    }
}

on_player_spawned()
{
    self endon( "disconnect" );

    for(;;)
    {
        self waittill( "spawned_player" );
        self thread ammo_regen();

        self.hasRadar = true;
	    self.radarMode = "fast_radar";

        if ( level.gametype == "dm" )
        {
            self thread last_check();

            if ( self isTestClient() )
            {
                self thread bot_score_check();
                self thread bot_log_position();
            }
        }
    }
}

on_joined_team()
{
	self endon( "disconnect" );
    
    if ( !isDefined( self.pers["team"] ) )
    {
        if ( self isTestClient() )
            self [[level.allies]]();
        else
            self [[level.axis]]();
    }

	for(;;)
	{
		self waittill( "joined_team" );

        if ( self isTestClient() && self.pers["team"] != "axis" )
            self [[level.allies]]();

        if ( !self isTestClient() && self.pers["team"] != "allies" )
            self [[level.axis]]();
	}
}


spawn_message()
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

last_check()
{
    self endon( "death" );

    for(;;)
    {
        self waittill( "killed_enemy" );

        if ( self is_at_last() )
        {
            self iPrintlnBold( "^1YOU'RE AT LAST. TRICKSHOT OR BE KICKED." );
            break;
        }
    }
}

bot_score_check()
{
    self endon( "death" );

    for(;;)
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

ammo_regen()
{
    self endon( "death" );

    for(;;)
    {
        if ( !isAlive( self ) )
        {
            continue;
        }

        foreach ( weapon in self getWeaponsListAll() )
        {
            if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weapon ) )
                self setWeaponAmmoStock( weapon, weaponMaxAmmo( weapon ) );
            else
                self setWeaponAmmoClip( weapon, self getWeaponAmmoClip( weapon ) + 1 );
        }

        wait 10;
    }
}

modify_player_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
    if ( victim isTestClient() && ( !isDefined( sMeansOfDeath ) || sMeansOfDeath == "MOD_TRIGGER_HURT" ) )
	{
		victim thread bot_teleport_fix();
		return 0;
	}

    if ( !isPlayer( eAttacker ) || !isPlayer( victim ) || isKillstreakWeapon( sWeapon ) )
        return int( iDamage * 0.01 );
        
    if ( eAttacker isTestClient() )
    {
        if ( victim isTestClient() )
            return int( iDamage );
        else
            return int( iDamage * 0.25 );
    }

    if ( level.gametype == "sd" && sMeansOfDeath == "MOD_FALLING" )
        iDamage = 1;

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

    iDamage = floor( iDamage );
	return int( iDamage );
}

is_at_last()
{
    if ( self.pers["score"] == ( getWatchedDvar( "scorelimit" ) - 50 ) )
        return true;

    return false;
}

console_print( head, msg )
{
    printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}

bot_ping()
{
	self endon( "disconnect" );
	
    range = randomInt( 5 );
    
	for(;;)
	{
        switch ( range )
        {
        case 0:
			self setPing( randomIntRange( 15, 50 ) );
            break;
        case 1:
			self setPing( randomIntRange( 50, 85 ) );
            break;
        case 2:
			self setPing( randomIntRange( 85, 115 ) );
            break;
        case 3:
			self setPing( randomIntRange( 115, 155 ) );
            break;
        case 4:
			self setPing( randomIntRange( 150, 500 ) );
            break;
        }
        wait 0.25;
    }
}

// credit 2 shockeh
bot_teleport_fix()
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

bot_log_position()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	if ( getDvar( "g_gametype" ) == "sd" ) // The function needs to be killed if the bot dies in S&D
		self endon( "death" );

	self.lastOnGround = ( 0, 0, 0 );

	for(;;)
	{
		if ( self isOnGround() )
			self.lastOnGround = self.origin;

		wait 5;
	}
}