/*
	_bot_http
	Author: INeedGames
	Date: 09/26/2020
	The HTTP module to use with IW4X's gsc funcs
*/

#include thirdparty\bot_warfare\_bot_utility;


getRemoteWaypoints( mapname )
{
	url = "https://raw.githubusercontent.com/simonlfc/auzziemod-iw4/waypoints/" + mapname + ".csv";
	filename = "waypoints/" + mapname + "_wp.csv";

	PrintConsole("Attempting to get remote waypoints from " + url + "\n");
	res = getLinesFromUrl(url, filename);

	if (!res.lines.size)
	  return;

	waypointCount = int(res.lines[0]);

	waypoints = [];
	PrintConsole("Loading remote waypoints...\n");

	for (i = 1; i <= waypointCount; i++)
	{
	  tokens = tokenizeLine(res.lines[i], ",");

	  waypoint = parseTokensIntoWaypoint(tokens);

	  waypoints[i-1] = waypoint;
	}

	if (waypoints.size)
	{
	  level.waypoints = waypoints;
	  PrintConsole("Loaded " + waypoints.size + " waypoints from remote.\n");
	}
}


getLinesFromUrl( url, filename )
{
	result = spawnStruct();
	result.lines = [];

	request = httpGet( url );

	if (!isDefined(request))
		return result;

	request waittill( "done", success, data );

	if (!success)
	  return result;

	fileWrite(filename, data, "write");

	line = "";
	for (i=0;i<data.size;i++)
	{
		c = data[i];

		if (c == "\n")
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