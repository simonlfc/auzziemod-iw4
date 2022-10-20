/*
	_bot_waypoints
	Author: INeedGames
	Date: 09/26/2020
	The HTTP module to use with IW4X's gsc funcs
*/

#include thirdparty\bot_warfare\_bot_utility;


get_waypoints( mapname )
{
	redux\common::console_print( "Waypoints", "Requesting waypoints for map: " + mapname );
	file	 = fileRead( "waypoints/" + level.gametype + "/" + mapname + ".csv" );

	if ( !isDefined( file ) )
	{
		redux\common::console_print( "Waypoints", "No gametype specific waypoints available, defaulting." );
		file = fileRead( "waypoints/" + mapname + ".csv" );
	}
	else
	{
		redux\common::console_print( "Waypoints", "Using gametype specific waypoints." );
	}
	
	res = parse_waypoints( file );

	if ( !res.lines.size )
	{
		return;
	}

	waypointCount = int( res.lines[0] );
	waypoints	  = [];

	for ( i = 1; i <= waypointCount; i++ )
	{
		tokens			 = tokenizeLine( res.lines[i], "," );
		waypoint		 = parseTokensIntoWaypoint( tokens );
		waypoints[i - 1] = waypoint;
	}

	if ( waypoints.size )
	{
		level.waypoints = waypoints;
		redux\common::console_print( "Waypoints", "Loaded " + waypoints.size + " waypoints." );
	}
	else
	{
		redux\common::console_print( "Waypoints", "Something went wrong." );
	}
}

parse_waypoints( data )
{
	result = spawnStruct();
	result.lines = [];
	line = "";
	
	for ( i = 0; i < data.size; i++ )
	{
		c = data[i];

		if ( c == "\n" )
		{
			result.lines[result.lines.size] = line;

			line = "";
			continue;
		}

		line += c;
	}

	result.lines[result.lines.size] = line;
	return result;
}