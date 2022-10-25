#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

on_script_menu_response()
{
    self endon( "disconnect" );
    
    for(;;)
    {
        self waittill( "menuresponse", menu, response );
        /#
        self iPrintLn( "^5Callback received from: ", menu, "(", response, ")" );
        #/

        if ( isSubStr( response, "cast_vote" ) )
            self redux\voting::cast_map_vote( int( strTok( response, ":" )[1] ) );

        if ( response == "class0" )
        {
            self closepopupMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self [[level.class]]( "class0" );
        }

        if ( isSubStr( response, "streak" ) )
            self thread give_streak( strTok( response, ":" )[1] );

        if ( isSubStr( response, "loadout_" ) )
        {
            switch ( strTok( response, ":" )[0] )
            {
            case "loadout_primary":                 redux\loadout::init_loadout_stat( "primary_weapon", strTok( response, ":" )[1] );                 break;
            case "loadout_primary_camo":            redux\loadout::init_loadout_stat( "primary_camo", strTok( response, ":" )[1] );                   break;
            case "loadout_primary_attachment":      redux\loadout::init_loadout_stat( "primary_attachment", strTok( response, ":" )[1] );             break;
            case "loadout_secondary":               redux\loadout::init_loadout_stat( "secondary_weapon", strTok( response, ":" )[1] );               break;
            case "loadout_secondary_camo":          redux\loadout::init_loadout_stat( "secondary_camo", strTok( response, ":" )[1] );                 break;
            case "loadout_secondary_attachment":    redux\loadout::init_loadout_stat( "secondary_attachment", strTok( response, ":" )[1] );           break;
            case "loadout_lethal":                  redux\loadout::init_loadout_stat( "lethal", strTok( response, ":" )[1] );                         break;
            case "loadout_tactical":                redux\loadout::init_loadout_stat( "tactical", strTok( response, ":" )[1] );                       break;
            case "loadout_perk1":                   redux\loadout::init_loadout_stat( "perk1", strTok( response, ":" )[1] );                          break;
            case "loadout_perk2":                   redux\loadout::init_loadout_stat( "perk2", strTok( response, ":" )[1] );                          break;
            case "loadout_perk3":                   redux\loadout::init_loadout_stat( "perk3", strTok( response, ":" )[1] );                          break;
            }
        }
    }
}

give_streak( name )
{
	if ( !self redux\common::is_at_last() && level.gametype == "dm" )
	{
		self iPrintLn( "Streaks can't be given before last." );
		return;
	}

	if ( name == "emp" || name == "nuke" )
	{
		self iPrintLn( "Tactical Nuke and EMP are unavailable." );
		return;
	}

	if ( tableLookup( "mp/killstreakTable.csv", 1, name, 1 ) == name )
	{
		self maps\mp\killstreaks\_killstreaks::giveKillstreak( name, false );
		return;
	}

	self iPrintLn( "Invalid streak name." );

}