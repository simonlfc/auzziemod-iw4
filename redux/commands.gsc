#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );

	self thread register_command( "drop",        "drop []", 			::drop_weapon );
	self thread register_command( "streak",      "streak [name]", 		::give_streak );

	//self thread register_command( "savepos", 	 "savepos []", 			redux\private::save_position );
	//self thread register_command( "loadpos", 	 "loadpos []", 			redux\private::load_position );
	//self thread register_command( "fly", 		 "fly []", 				redux\private::fly_mode );

	if ( level.gametype == "dm" )
	{
		self thread register_command( "2piece",	  "2piece []", 			::two_piece );
		self thread register_command( "suicide",  "suicide []", 		::_suicide );
		self thread register_command( "slowlast", "slowlast []", 		::slow_last );
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
	if ( !isDefined( streak_name ) || streak_name == "" )
	{
		self iPrintLn( "No streak specified." );
		return;
	}

	self maps\mp\killstreaks\_killstreaks::giveKillstreak( streak_name, false );   
}

two_piece()
{
	if ( self redux\common::is_at_last() )
	{
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, getWatchedDvar( "scorelimit" ) - 100 );
		self.pers["kills"] = ( getWatchedDvar( "scorelimit" ) / 30 ) - 2;
		self.kills = self.pers["kills"];
	}
}

drop_weapon()
{
	weapons = self getWeaponsListPrimaries();

	if ( isKillstreakWeapon( self getCurrentWeapon() ) )
    {
        self iPrintLn( "Can't drop this weapon." );
        return;
    }

	self dropItem( self getCurrentWeapon() );
	while ( self getCurrentWeapon() == "none" )
	{
		waitframe();
		self switchToWeapon( weapons[ randomInt( weapons.size ) ] );
	}

    return;
}

slow_last()
{
	timeLeft = maps\mp\gametypes\_gamelogic::getTimeRemaining() / 1000;
	timeLeftInt = int( timeLeft + 0.5 );

    if ( self.used_slow_last )
    {
        self iPrintLn( "Slow last unavailable." );
        return;
    }

	if ( timeLeftInt <= 150 && getWatchedDvar( "scorelimit" ) != 0 ) // 2:30 left
	{
		score = getWatchedDvar( "scorelimit" ) - 50;
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
		self.pers["kills"] = ( score / 50 );
		self.kills = self.pers["kills"];
		self freezeControls( true );
		wait 3;
		self freezeControls( false );
	}
	else if ( timeLeftInt <= 300 && getWatchedDvar( "scorelimit" ) != 0 ) // 5:00 left
	{
		score = getWatchedDvar( "scorelimit" ) - 250;
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
		self.pers["kills"] = ( score / 50 );
		self.kills = self.pers["kills"];
		self freezeControls( true );
		wait 1;
		self freezeControls( false );
	}
	else
	{
		score = getWatchedDvar( "scorelimit" ) - 500;
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
		self.pers["kills"] = ( score / 50 );
		self.kills = self.pers["kills"];
	}

	self iPrintLn( "Set your score to " + score + "." );
	maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
	self.used_slow_last = true;
    return;
}