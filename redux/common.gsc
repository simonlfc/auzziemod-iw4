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

        if ( level.gametype == "dm" )
        {
            self thread last_check();

            if ( self isTestClient() )
                self thread bot_score_check();
        }
    }
}

on_joined_team()
{
	self endon( "disconnect" );
    
    if ( self isTestClient() )
        self [[level.axis]]();
    else
        self [[level.allies]]();

	for(;;)
	{
		self waittill( "joined_team" );

        if ( self isTestClient() && self.pers["team"] != "axis" )
            self [[level.axis]]();

        if ( !self isTestClient() && self.pers["team"] != "allies" )
            self [[level.allies]]();
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
    if ( !isPlayer( eAttacker ) || !isPlayer( victim ) || isKillstreakWeapon( sWeapon ) )
        return int( iDamage * 0.01 );
        
    if ( eAttacker isTestClient() )
    {
        if ( victim isTestClient() )
            return int( iDamage );
        else
            return int( iDamage * 0.15 );
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