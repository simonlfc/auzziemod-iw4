#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

on_script_menu_response()
{
    self endon( "disconnect" );
    for(;;)
    {
        self waittill( "menuresponse", menu, response );
        self iPrintLn( "^5Callback received from: ", menu, "(", response, ")" );

        if ( isSubStr( response, "cast_vote" ) )
            self redux\voting::cast_map_vote( int( strTok( response, ":" )[1] ) );
        
        if ( response == "class4" )
        {
            self closepopupMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self [[level.class]]( "class4" );
        }

        if ( isSubStr( response, "loadout_" ) )
        {
            switch ( strTok( response, ":" )[0] )
            {
            case "loadout_primary":                 redux\loadout::init_loadout_stat( "primary_weapon", response );                 break;
            case "loadout_primary_camo":            redux\loadout::init_loadout_stat( "primary_camo", response );                   break;
            case "loadout_primary_attachment":      redux\loadout::init_loadout_stat( "primary_attachment", response );             break;
            case "loadout_secondary":               redux\loadout::init_loadout_stat( "secondary_weapon", response );               break;
            case "loadout_secondary_camo":          redux\loadout::init_loadout_stat( "secondary_camo", response );                 break;
            case "loadout_secondary_attachment":    redux\loadout::init_loadout_stat( "secondary_attachment", response );           break;
            case "loadout_lethal":                  redux\loadout::init_loadout_stat( "lethal", response );                         break;
            case "loadout_tactical":                redux\loadout::init_loadout_stat( "tactical", response );                       break;
            case "loadout_perk1":                   redux\loadout::init_loadout_stat( "perk1", response );                          break;
            case "loadout_perk2":                   redux\loadout::init_loadout_stat( "perk2", response );                          break;
            case "loadout_perk3":                   redux\loadout::init_loadout_stat( "perk3", response );                          break;
            case "loadout_give":                    redux\loadout::give_loadout();                                                  break;
            }
        }
    }
}
