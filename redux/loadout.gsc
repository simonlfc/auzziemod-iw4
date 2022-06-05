#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

update_remote_loadout()
{
    redux\networking::network_print( "Storage", "Updating loadout data for " + self.name + "(" + self.guid + ")" );
    
    fileWrite( "storage/" + self.guid + "/loadout.class", get_loadout_stat( "primary_weapon" ), "write" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "primary_camo" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "primary_attachment" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "secondary_weapon" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "secondary_camo" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "secondary_attachment" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "lethal" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "tactical" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "perk1" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "perk2" ), "append" );
    fileWrite( "storage/" + self.guid + "/loadout.class", "," + get_loadout_stat( "perk3" ), "append" );
}

init_remote_loadout()
{
    if ( !fileExists( "storage/" + self.guid + "/loadout.class" ) )
    {
        redux\networking::network_print( "Storage", "Creating loadout data for " + self.name + "(" + self.guid + ")" );
        fileWrite( "storage/" + self.guid + "/loadout.class", fileRead( "storage/default.class" ), "write" );
    }
    else
    {
        // We need to get our GUID into the UI, this sucks but it'll do
        self setClientDvar( "temp", self.guid );
        self openPopupMenu( "loadout_init" );

        loadout = fileRead( "storage/" + self.guid + "/loadout.class" );
        tokenised = strTok( loadout, "," );
        redux\loadout::init_loadout_stat( "primary_weapon", tokenised[0] );
        redux\loadout::init_loadout_stat( "primary_camo", tokenised[1] );
        redux\loadout::init_loadout_stat( "primary_attachment", tokenised[2] );
        redux\loadout::init_loadout_stat( "secondary_weapon", tokenised[3] );
        redux\loadout::init_loadout_stat( "secondary_camo", tokenised[4] );
        redux\loadout::init_loadout_stat( "secondary_attachment", tokenised[5] );
        redux\loadout::init_loadout_stat( "lethal", tokenised[6] );
        redux\loadout::init_loadout_stat( "tactical", tokenised[7] );
        redux\loadout::init_loadout_stat( "perk1", tokenised[8] );
        redux\loadout::init_loadout_stat( "perk2", tokenised[9] );
        redux\loadout::init_loadout_stat( "perk3", tokenised[10] );
    }
}

get_loadout_stat( stat )
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

init_loadout_stat( stat, value )
{
    if ( stat == "primary_attachment" )
        value = tablelookup( "redux/statsTable.csv", 4, get_loadout_stat( "primary_weapon" ), 10 + int( value ) );
    else if ( stat == "secondary_attachment" )
        value = tablelookup( "redux/statsTable.csv", 4, get_loadout_stat( "secondary_weapon" ), 10 + int( value ) );

    if ( value == "" )
        value = "none";

    self iPrintLn( "Initialised stat: ", stat, " with: ", value );
    
    self.pers["loadout"][ stat ] = value;
    return;
}