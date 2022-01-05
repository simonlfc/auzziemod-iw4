#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );
	self thread registerCommand( "drop",        "^3usage: drop []" );
	self thread registerCommand( "streak",      "^3usage: streak [name]" );
	if ( level.gametype == "dm" )
	{
		self thread registerCommand( "suicide",     "^3usage: suicide []" );
		self thread registerCommand( "slowlast",    "^3usage: slowlast []" );
	}
}

registerCommand( command, detail )
{
	self endon ( "disconnect" );
	self notifyOnPlayerCommand( command, command );
	self setClientDvar( command, detail );
	for(;;)
	{
		self waittill( command );
		switch( command )
		{
//      command                 action
        case "drop":            self drop_weapon();                                                                         break;
        case "suicide":         self suicide();                                                                             break;
        case "streak":          self maps\mp\killstreaks\_killstreaks::giveKillstreak( getDvar( "streak" ), false );	    break;
        case "slowlast":        self slow_last();			                                                                break;
		}
	}
}

drop_weapon()
{
	weapons = self getWeaponsListPrimaries();

	if ( isKillstreakWeapon( self getCurrentWeapon() ) )
    {
        self iPrintLn( "Can't drop this weapon" );
        return;
    }

	self dropItem( self getCurrentWeapon() );
	while ( self getCurrentWeapon() == "none" )
	{
		wait 0.01;
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
        self iPrintLn( "Slow last unavailable" );
        return;
    }

	if ( timeLeftInt <= 150 && getWatchedDvar( "scorelimit" ) != 0 ) // 2:30 left
	{
		score = getWatchedDvar( "scorelimit" ) - 50;
		self iPrintLn( "Set your score to ", score );
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
		self freezeControls( true );
		wait 3;
		self freezeControls( false );
	}
	else if ( timeLeftInt <= 300 && getWatchedDvar( "scorelimit" ) != 0 ) // 5:00 left
	{
		score = getWatchedDvar( "scorelimit" ) - 250;
		self iPrintLn( "Set your score to ", score );
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
		self freezeControls( true );
		wait 1;
		self freezeControls( false );
	}
	else
	{
		score = getWatchedDvar( "scorelimit" ) - 500;
		self iPrintLn( "Set your score to ", score );
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
	}

	maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
	self.used_slow_last = true;
    return;
}