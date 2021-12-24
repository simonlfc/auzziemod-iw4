#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    replaceFunc( maps\mp\_utility::rankingEnabled, ::is_ranked ); // Force ranked
    replaceFunc( maps\mp\_utility::matchMakingGame, ::is_ranked ); // Force ranked
    replaceFunc( maps\mp\_utility::privateMatch, ::is_unranked ); // Force ranked
    replaceFunc( maps\mp\gametypes\_gamelogic::matchStartTimerPC, ::match_start_timer_hook ); // Disable pre-match timer
    replaceFunc( maps\mp\gametypes\_class::isValidDeathstreak, ::is_valid_deathstreak_hook ); // Disable deathstreaks
    replaceFunc( maps\mp\gametypes\_class::isValidPrimary, ::is_valid_primary_hook ); // Disable Riot Shield
    replaceFunc( maps\mp\gametypes\_class::isValidPerk3, ::is_valid_perk3_hook ); // Disable Last Stand
	replaceFunc( maps\mp\gametypes\_menus::menuClass, ::menu_class_hook ); // Allow class changing at any time
}

menu_class_hook( response )
{
	self closeMenus();
	
	// clear new status of unlocked classes
	if ( response == "demolitions_mp,0" && self getPlayerData( "featureNew", "demolitions" ) )
	{
		self setPlayerData( "featureNew", "demolitions", false );
	}
	if ( response == "sniper_mp,0" && self getPlayerData( "featureNew", "sniper" ) )
	{
		self setPlayerData( "featureNew", "sniper", false );
	}

	// this should probably be an assert
	if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
		return;

	class = self maps\mp\gametypes\_class::getClassChoice( response );
	primary = self maps\mp\gametypes\_class::getWeaponChoice( response );

	if ( class == "restricted" )
	{
		self maps\mp\gametypes\_menus::beginClassChoice();
		return;
	}

	if( (isDefined( self.pers["class"] ) && self.pers["class"] == class) && 
		(isDefined( self.pers["primary"] ) && self.pers["primary"] == primary) )
		return;

	if ( self.sessionstate == "playing" )
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		self maps\mp\gametypes\_class::setClass( self.pers["class"] );
		self.tag_stowed_back = undefined;
		self.tag_stowed_hip = undefined;
		self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
	}
	else
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" && !isInKillcam() )
			self thread maps\mp\gametypes\_playerlogic::spawnClient();
	}

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

is_valid_deathstreak_hook()
{
    return false;
}

is_valid_primary_hook( refString )
{
	switch ( refString )
	{
		case "ak47":
		case "m16":
		case "m4":
		case "fn2000":
		case "masada":
		case "famas":
		case "fal":
		case "scar":
		case "tavor":
		case "mp5k":
		case "uzi":
		case "p90":
		case "kriss":
		case "ump45":
		case "barrett":
		case "wa2000":
		case "m21":
		case "cheytac":
		case "rpd":
		case "sa80":
		case "mg4":
		case "m240":
		case "aug":
			return true;
		default:
			assertMsg( "Replacing invalid primary weapon: " + refString );
			return false;
	}
}

is_valid_perk3_hook( refString )
{
	switch ( refString )
	{
		case "specialty_extendedmelee":
		case "specialty_bulletaccuracy":
		case "specialty_localjammer":
		case "specialty_heartbreaker":
		case "specialty_detectexplosive":
			return true;
		default:
			assertMsg( "Replacing invalid perk3: " + refString );
			return false;
	}
}

match_start_timer_hook()
{
    maps\mp\gametypes\_gamelogic::matchStartTimerSkip();
}

is_unranked()
{
    return false;
}

is_ranked()
{
    return true;
}