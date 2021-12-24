#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{    
    thread redux\hooks::init();

    level.onlineGame = true;
    level.rankedMatch = true;
    level.modifyPlayerDamage = redux\common::modify_player_damage;

    precacheItem( "codol-cheytac_mp" );
    precacheItem( "codol-l115a3_mp" );
    precacheItem( "codol-msr_mp" );
    
    precacheMenu( "map_voting" );

    level thread redux\voting::init();
    level thread on_player_connect();
}

on_player_connect()
{
    for(;;)
    {
        level waittill( "connected", player );
        player.used_slow_last = false;
        player thread redux\commands::init();
        player thread redux\ui_callbacks::on_script_menu_response();
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

        if ( self isBot() )
            self thread bot_score_check();
    }
}

bot_score_check()
{
    self endon( "death" );
    for(;;)
    {
        self waittill( "player_killed" );
        if ( self.pers["score"] > getWatchedDvar( "scorelimit" ) / 2 && getWatchedDvar( "scorelimit" ) != 0 )
        {
            maps\mp\gametypes\_gamescore::_setPlayerScore( self, 0 );
            maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
            break;
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
            
            if ( getWeaponClass( weapon ) == "weapon_grenade" || getWeaponClass( weapon ) == "weapon_explosive" )
                self setWeaponAmmoClip( weapon, self getWeaponAmmoClip( weapon ) + 1 );
        }
        wait 10;
    }

}

modify_player_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
    if ( eAttacker isBot() && !victim isBot() )
    {
        iDamage *= 0.15;
        return int( iDamage );
    }

    if ( level.gametype == "sd" && sMeansOfDeath == "MOD_FALLING" )
        iDamage = 1;

    if ( sMeansOfDeath == "MOD_MELEE" )
        iDamage = 1;

    if ( isBulletDamage( sMeansOfDeath ) && getWeaponClass( sWeapon ) != "weapon_sniper" )
        iDamage = 1;

	if ( getWeaponClass( sWeapon ) == "weapon_sniper" || sWeapon == "throwingknife_mp" || isSubStr( sWeapon, "fal_" ) )
		iDamage = 99999;

    // Mala fix
	if ( getWeaponClass( sWeapon ) == "weapon_grenade" || getWeaponClass( sWeapon ) == "weapon_explosive" )
	{
		if ( sMeansOfDeath == "MOD_RIFLE_BULLET" )
			iDamage = 99999;
		else
			iDamage = 1;
	}

	return int( iDamage );
}