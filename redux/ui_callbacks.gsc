#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

get_loadout_stat( stat )
{
    return self.pers["loadout"][ stat ];
}

init_loadout_stat( stat, value )
{
    value = strTok( value, ":" )[1];

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

on_script_menu_response()
{
    self endon( "disconnect" );
    
    for(;;)
    {
        self waittill( "menuresponse", menu, response );
        self iPrintLn( "^5Callback received from: ", menu, "(", response, ")" );

        if ( isSubStr( response, "cast_vote" ) )
            self redux\voting::cast_map_vote( int( strTok( response, ":" )[1] ) );

        if ( response == "class0" )
        {
            self closepopupMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self [[level.class]]( "class0" );
        }

        if ( isSubStr( response, "loadout_" ) )
        {
            switch ( strTok( response, ":" )[0] )
            {
            case "loadout_primary":                 init_loadout_stat( "primary_weapon", response );                 break;
            case "loadout_primary_camo":            init_loadout_stat( "primary_camo", response );                   break;
            case "loadout_primary_attachment":      init_loadout_stat( "primary_attachment", response );             break;
            case "loadout_secondary":               init_loadout_stat( "secondary_weapon", response );               break;
            case "loadout_secondary_camo":          init_loadout_stat( "secondary_camo", response );                 break;
            case "loadout_secondary_attachment":    init_loadout_stat( "secondary_attachment", response );           break;
            case "loadout_lethal":                  init_loadout_stat( "lethal", response );                         break;
            case "loadout_tactical":                init_loadout_stat( "tactical", response );                       break;
            case "loadout_perk1":                   init_loadout_stat( "perk1", response );                          break;
            case "loadout_perk2":                   init_loadout_stat( "perk2", response );                          break;
            case "loadout_perk3":                   init_loadout_stat( "perk3", response );                          break;
            }
        }
    }
}