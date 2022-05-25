/*
	_bot_http
	Author: INeedGames
	Date: 09/26/2020
	The HTTP module to use with IW4X's gsc funcs
*/

#include thirdparty\bot_warfare\_bot_utility;

getRemoteWaypoints( mapname )
{
	redux\networking::network_print( "Waypoints", "Requesting waypoints for map: " + mapname );
	gametype = getDvar( "g_gametype" );
	url		 = "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/waypoints/" + gametype + "/" + mapname + ".csv";
	request  = httpGet( url );
	request waittill( "done", success );

	if ( !success )
	{
		redux\networking::network_print( "Waypoints", "No gametype specific waypoints available, defaulting." );
		url = "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/waypoints/" + mapname + ".csv";
	}
	else
	{
		redux\networking::network_print( "Waypoints", "Using gametype '" + gametype + "' specific waypoints." );
	}
	
	redux\networking::network_print( "Waypoints", "Contacting: " + url );
	res = getLinesFromUrl( url );

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
		redux\networking::network_print( "Waypoints", "Retrieved " + waypoints.size + " waypoints." );
	}
	else
	{
		redux\networking::network_print( "Waypoints", "Something went wrong." );
	}
}

getLinesFromUrl( url )
{
	result		 = spawnStruct();
	result.lines = [];

	request		 = httpGet( url );

	if ( !isDefined( request ) )
	{
		return result;
	}

	request waittill( "done", success, data );

	if ( !success )
	{
		return result;
	}

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