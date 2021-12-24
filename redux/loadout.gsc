#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;

give_loadout()
{
    self closeInGameMenu();
    self takeAllWeapons();
    self _clearPerks();
    self _detachAll();

    self loadoutAllPerks( 
        self.loadout[ "loadout_lethal" ], 
        self.loadout[ "loadout_perk1" ], 
        self.loadout[ "loadout_perk2" ], 
        self.loadout[ "loadout_perk3" ] 
    );

    primary = buildWeaponName( 
        self.loadout[ "primary_weapon" ],
        self.loadout[ "primary_attachment" ]
    );
    self _giveWeapon( primary, int( self.loadout[ "primary_camo" ] ) );
    self setSpawnWeapon( primary );

    secondary = buildWeaponName( 
        self.loadout[ "secondary_weapon" ],
        self.loadout[ "secondary_attachment" ]
    );
    self _giveWeapon( secondary, int( self.loadout[ "secondary_camo" ] ) );

    self maps\mp\gametypes\_teams::playerModelForWeapon( self.loadout[ "primary_weapon" ], self.loadout[ "secondary_weapon" ] );
}

init_loadout_stat( stat, value )
{
    value = strTok( value, ":" )[1];

    if ( stat == "primary_attachment" )
        value = tableLookup( "mp/statsTable.csv", 4, self.loadout[ "primary_weapon" ], 10 + int( value ) );
    else if ( stat == "secondary_attachment" )
        value = tableLookup( "mp/statsTable.csv", 4, self.loadout[ "secondary_weapon" ], 10 + int( value ) );

    if ( value == "" )
        value = "none";

    self iPrintLn( "Initialised stat: ", stat, " with: ", value );
    self.loadout[ stat ] = value;
    return;
}