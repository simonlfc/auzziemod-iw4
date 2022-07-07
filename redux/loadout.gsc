#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

get_weapon_playerdata( stat )
{
    packed              = self getPlayerData( stat );

    struct              = spawnStruct();
    struct.weapon       = tableLookup( "redux/statsTable.csv", 1, getSubStr( packed, 0, 4 ), 4 );
    struct.camo         = packed[5];
    struct.attachment   = packed[6];
    return struct;
}

setup_playerdata()
{
    if ( self getPlayerData( "money" ) == 0 )
    {
        self setPlayerData( "money", 303862 );               // intervention w/ red tiger & fmj
        self setPlayerData( "moneyLast", 300104 );           // m9 w/ no camo & tac knife
        self setPlayerData( "timeSinceLastLoot", 32211 );    // throwing knife & stun, soh & stopping power & commando
    }

    primary     = self get_weapon_playerdata( "money" );
    secondary   = self get_weapon_playerdata( "moneyLast" );
    rest        = self getPlayerData( "timeSinceLastLoot" );

    lethal      = rest[0];
    tactical    = rest[1];
    perk1       = rest[2];
    perk2       = rest[3];
    perk3       = rest[4];
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