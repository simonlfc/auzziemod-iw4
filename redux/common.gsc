#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{    
    thread redux\hooks::hooks();
    thread thirdparty\bot_warfare\_bot::init();

    level.onlineGame = true;
    level.rankedMatch = true;
    level.modifyPlayerDamage = redux\common::modify_player_damage;

    precacheMenu( "map_voting" );
    precacheMenu( "loadout" );
    
    precacheItem( "cheytac_irons_mp" );
    precacheItem( "codol-cheytac_mp" );
    precacheItem( "codol-l115a3_mp" );
    precacheItem( "codol-msr_mp" );

    level thread redux\voting::init();
    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill( "connected", player );
        if ( !player isBot() )
        {
            player.used_slow_last = false;
            if ( !isDefined( player.loadout ) )
                player.loadout = [];

            player thread redux\commands::init();
            player thread redux\ui_callbacks::on_script_menu_response();
            player thread spawn_message();
        }
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
            if ( self isBot() )
                self thread bot_score_check();
        }
    }
}

spawn_message()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );
    if ( game["roundsPlayed"] == 0 )
    {
        self iPrintLn( ">>^3 auzziemod IW4" );
        self iPrintLn( ">>^3 https://github.com/simonlfc/auzziemod-iw4" );
    }
    return;
}

last_check()
{
    self endon( "death" );
    for(;;)
    {
        self waittill( "killed_enemy" );
        if ( self.pers["score"] == ( getWatchedDvar( "scorelimit" ) - 50 ) )
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
    if ( eAttacker isBot() && victim isBot() )
        return int( iDamage );
    
    if ( eAttacker isBot() && !victim isBot() )
    {
        iDamage *= 0.15;
        return int( iDamage );
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

	return int( iDamage );
}