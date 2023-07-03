#include common_scripts\utility;
#include common_scripts\iw4x_utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\utils;

init()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	_ = [];
	_["drop"] = ::dropWeapon;
	_["2piece"] = ::twoPiece;
	_["suicide"] = ::_suicide;
	_["slowlast"] = ::slowLast;

	if ( getDvarInt( "sv_extrafeatures", false ) )
	{
		_["savepos"] = redux\private::savePosition;
		_["loadpos"] = redux\private::loadPosition;
		_["fly"] = ::_noclip;
		_["fastlast"] = redux\private::fastLast;
	}

	foreach ( name, func in _ )
		self childthread run( name, func );
}

run( name, func )
{
	self setClientDvar( name, "Script command" );
	self notifyOnPlayerCommand( name, name );

	for ( ;; )
	{
		self waittill( name );
		self thread [[func]]();
	}
}

twoPiece()
{
	if ( level.gametype != "sd" )
		return;

	if ( self isAtLast() )
	{
		maps\mp\gametypes\_gamescore::_setPlayerScore( self, getWatchedDvar( "scorelimit" ) - 100 );
		self.pers["kills"] = ( getWatchedDvar( "scorelimit" ) / 50 ) - 2;
		self.kills = self.pers["kills"];
		maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
	}
}

dropWeapon()
{
	weapon = self getCurrentWeapon();

	if ( isKillstreakWeapon( weapon ) || isSubStr( weapon, "briefcase" ) )
	{
		self iPrintLn( "Can't drop this weapon." );
		return;
	}

	weapons = self getWeaponsListPrimaries();
	self dropItem( weapon );

	while ( self getCurrentWeapon() == "none" )
	{
		waitframe();
		self switchToWeapon( weapons[ randomInt( weapons.size ) ] );
	}
}

slowLast()
{
	if ( self.used_slow_last || getWatchedDvar( "scorelimit" ) == 0 || level.gametype != "dm" )
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