/*
	_bot_waypoints
	Author: INeedGames
	Date: 09/26/2020
	The waypoint module to use with IW4X's gsc funcs
*/

#include thirdparty\bot_warfare\_bot_utility;

getWaypoints( mapname )
{
	redux\common::consolePrint( "Waypoints", "Requesting waypoints for map: " + mapname );
	filename = "waypoints/" + level.gametype + "/" + mapname + ".csv";

	if ( !fileExists( filename ) )
	{
		redux\common::consolePrint( "Waypoints", "No gametype specific waypoints available, defaulting." );
		filename = "waypoints/" + mapname + ".csv";
		if ( !fileExists( filename ) )
			return false;
	}

	result = spawnStruct();
	result.lines = [];

	if ( openFile( filename, "read" ) == -1 )
		return false;

	for ( ;; )
	{
		line = readStream();
		if ( !isDefined( line ) )
			break;

		result.lines[result.lines.size] = line;
	}

	closeFile();

	if ( result.lines.size == 0 )
		return false;

	waypointCount = int( result.lines[0] );
	waypoints = [];

	for ( i = 1; i <= waypointCount; i++ )
	{
		tokens = tokenizeLine( result.lines[i], "," );
		waypoint = parseTokensIntoWaypoint( tokens );
		waypoints[i - 1] = waypoint;
	}

	level.waypoints = waypoints;
	return true;
}