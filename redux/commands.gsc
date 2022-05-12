#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );

	self thread register_command( "drop",        "drop []", 				::drop_weapon );
	self thread register_command( "streak",      "streak [name]", 			::give_streak );
	self thread register_command( "forceupdate", "forceupdate [branch]",	redux\networking::force_update );

	//self thread register_command( "savepos", 	 "savepos []", 				redux\private::save_position );
	//self thread register_command( "loadpos", 	 "loadpos []", 				redux\private::load_position );
	//self thread register_command( "fly", 		 "fly []", 					redux\private::fly_mode );

	if ( level.gametype == "dm" )
	{
		self thread register_command( "2piece",	  "2piece []", 				::two_piece );
		self thread register_command( "suicide",  "suicide []", 			::_suicide );
		self thread register_command( "slowlast", "slowlast []", 			::slow_last );
	}
}

register_command( command, desc, action )
{
    new_cmd = [];
    new_cmd["name"] = command;
    new_cmd["desc"] = "^3usage:^7 " + desc;
    new_cmd["action"] = action;

    self setClientDvar( new_cmd["name"], new_cmd["desc"] );
    self notifyOnPlayerCommand( new_cmd["name"], new_cmd["name"] );

    self thread monitor_command( new_cmd );
}

monitor_command( cmd )
{
    self endon ( "disconnect" );
	for (;;)
	{
    	self waittill ( cmd["name"] );
    	self thread [[cmd["action"]]]();
	}
}

give_streak()
{
	if ( !self redux\common::is_at_last() && level.gametype == "dm" )
	{
		self iPrintLn( "Streaks can't be given before last." );
		return;
	}

	streak_name = getDvar( "streak" );

	if ( streak_name == "emp" || streak_name == "nuke" )
	{
		self iPrintLn( "Tactical Nuke and EMP are unavailable." );
		return;
	}

	for ( i = 0; i < 28; i++ )
	{
		if ( streak_name == tableLookup( "mp/killstreakTable.csv", 0, i, 1 ) )
		{
			self maps\mp\killstreaks\_killstreaks::giveKillstreak( streak_name, false );
			return;
		}
	}

	self iPrintLn( "Invalid streak name." );

}

two_piece()
{
	if ( self redux\common::is_at_last() )
	{
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, getWatchedDvar( "scorelimit" ) - 100 );
		self.pers["kills"] = ( getWatchedDvar( "scorelimit" ) / 50 ) - 2;
		self.kills = self.pers["kills"];
	}
}

drop_weapon()
{
	weapon = self getCurrentWeapon();
	if ( isKillstreakWeapon( weapon ) || isSubStr( weapon, "briefcase" ) )
    {
        self iPrintLn( "Can't drop this weapon." );
        return;
    }

	weapon_list = self getWeaponsListPrimaries();
	self dropItem( weapon );

	while ( self getCurrentWeapon() == "none" )
	{
		waitframe();
		self switchToWeapon( weapon_list[ randomInt( weapon_list.size ) ] );
	}
}

slow_last()
{
    if ( self.used_slow_last || getWatchedDvar( "scorelimit" ) == 0 )
    {
        self iPrintLn( "Slow last unavailable." );
        return;
    }

	time_remaining = int( maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000 + 0.5 );
	score = getWatchedDvar( "scorelimit" ) - 500;

	if ( time_remaining <= 150 )
		score = getWatchedDvar( "scorelimit" ) - 50;
	else if ( time_remaining <= 300 )
		score = getWatchedDvar( "scorelimit" ) - 250;

	maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
	self.pers["kills"] = int( score / 50 );
	self.kills = self.pers["kills"];
	maps\mp\gametypes\_gamescore::sendUpdatedDMScores();

	self iPrintLn( "Set your score to " + score + "." );
	self.used_slow_last = true;
}