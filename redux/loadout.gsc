#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\utils;

getLoadoutStat( stat )
{
	val = self.pers["loadout"][ stat ];

	if ( isSubStr( stat, "perk" ) )
	{
		if ( !isDefined( val ) || val == "" )
			return "specialty_null";
	}

	if ( !isDefined( val ) || val == "" )
		return "none";

	return self.pers["loadout"][ stat ];
}

initLoadoutStat( stat, value )
{
	if ( stat == "primary_attachment" )
		value = tablelookup( "redux/statsTable.csv", 4, getLoadoutStat( "primary_weapon" ), 10 + int( value ) );
	else if ( stat == "secondary_attachment" )
		value = tablelookup( "redux/statsTable.csv", 4, getLoadoutStat( "secondary_weapon" ), 10 + int( value ) );

	if ( value == "" )
		value = "none";

	/#
	self iPrintLn( "Initialised stat: ", stat, " with: ", value );
	#/

	self.pers["loadout"][ stat ] = value;
	return;
}