#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	self endon( "disconnect" );

	self thread register_command( "drop", "drop []", ::drop_weapon, false );
	self thread register_command( "streak", "streak [name]", ::give_streak, false );


	self thread register_command( "2piece", "2piece []", ::two_piece, true );
	self thread register_command( "suicide", "suicide []", ::_suicide, true );
	self thread register_command( "slowlast", "slowlast []", ::slow_last, true );

	/#
	self thread register_command( "savepos", "savepos []", redux\private::save_position, false );
	self thread register_command( "loadpos", "loadpos []", redux\private::load_position, false );
	self thread register_command( "fly", "fly []", redux\private::fly_mode, false );
	self thread register_command( "fastlast", "fastlast []", redux\private::fast_last, true );
	#/
}

register_command( command, description, function, dm_only )
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	// let's just register it anyways because if you change gametype its gonna be confusing
	if ( dm_only && level.gametype != "dm" )
	{
		self setClientDvar( command, "^1Unavailable in this gametype." );
		return;
	}

	self setClientDvar( command, description );
	self notifyOnPlayerCommand( command, command );

	for ( ;; )
	{
		self waittill( command );
		self thread [[function]]();
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

	if ( tableLookup( "mp/killstreakTable.csv", 1, streak_name, 1 ) == streak_name )
	{
		self maps\mp\killstreaks\_killstreaks::giveKillstreak( streak_name, false );
		return;
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
		maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
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