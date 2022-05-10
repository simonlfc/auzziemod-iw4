#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );
	self thread register_command( "drop",        "^3usage: drop []" );
	self thread register_command( "streak",      "^3usage: streak [name]" );
	self thread register_command( "forceupdate", "^3usage: forceupdate []" );

	//self thread registerCommand( "savepos", 	"^3usage: savepos []" );
	//self thread registerCommand( "loadpos", 	"^3usage: loadpos []" );
	//self thread registerCommand( "fly", 		"^3usage: fly []" );

	if ( level.gametype == "dm" )
	{
		self thread register_command( "suicide",     "^3usage: suicide []" );
		self thread register_command( "slowlast",    "^3usage: slowlast []" );
	}
}

register_command( command, detail )
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
        case "drop":            self thread drop_weapon();                                                                  break;
        case "suicide":         self suicide();                                                                             break;
        case "streak":
			if ( self.pers["score"] != ( getWatchedDvar( "scorelimit" ) - 50 ) && level.gametype == "dm" )
        	{
				self iPrintLn( "Streaks can't be given before last." );
				break;
			}
			self maps\mp\killstreaks\_killstreaks::giveKillstreak( getDvar( "streak" ), false );	    
			break;
        case "slowlast":        self thread slow_last();			                                                        break;
        case "forceupdate":     thread redux\networking::update( "main" );		                  	                 	 	break;
		//case "savepos":     	self thread redux\private::save_position();		                  	                 	 	break;
        //case "loadpos":     	self thread redux\private::load_position();		                  	                 	 	break;
        //case "fly":     		self noclip();																				break;
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
		waittillframeend;
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