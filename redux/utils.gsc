#include common_scripts\utility;
#include common_scripts\iw4x_utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

Select( eval, a, b )
{
	if ( eval )
		return a;

	return b;
}

Default( eval, default_ )
{
	if ( isDefined( eval ) )
		return eval;

	return default_;	
}

isAtLast()
{
	if ( self.pers["score"] == ( getWatchedDvar( "scorelimit" ) - 50 ) )
		return true;

	return false;
}

consolePrint( head, msg )
{
	printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}

_getPing()
{
	shortversion = getDvar( "shortversion" );
	if ( shortversion[0] != "r" )
		return self getPing();
	
	version = int( getSubStr( shortversion, 1, shortversion.size - 1 ) );
	if ( version >= 4246 )
		return self.ping;
	
	return self getPing();
}