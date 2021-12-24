#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

on_script_menu_response()
{
    self endon( "disconnect" );
    for(;;)
    {
        self waittill( "menuresponse", menu, response );
        
        if ( menu == "map_voting" )
        {
            if ( isSubStr( response, "map_vote;" ) )
                self redux\voting::cast_map_vote( strTok( response, ";" )[1] );
        }

        if ( menu == "loadout" )
        {

        }
    }
}