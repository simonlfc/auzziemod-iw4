#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;

give_loadout()
{
    self setOffhandPrimaryClass( "other" );
    self takeAllWeapons();
    self _clearPerks();
    self _detachAll();

    self loadoutAllPerks( 
        self.loadout[ "lethal" ], 
        self.loadout[ "perk1" ], 
        self.loadout[ "perk2" ], 
        self.loadout[ "perk3" ] 
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

    // Secondary Offhand
	offhandSecondaryWeapon = self.loadout[ "tactical" ] + "_mp";
	if ( self.loadout[ "tactical" ] == "flash_grenade" )
		self SetOffhandSecondaryClass( "flash" );
	else
		self SetOffhandSecondaryClass( "smoke" );
	
	self giveWeapon( offhandSecondaryWeapon );
	if( self.loadout[ "tactical" ] == "smoke_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	else if( self.loadout[ "tactical" ] == "flash_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else if( self.loadout[ "tactical" ] == "concussion_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );

    self maps\mp\gametypes\_teams::playerModelForWeapon( self.loadout[ "primary_weapon" ], self.loadout[ "secondary_weapon" ] );

    self.isSniper = ( weaponClass(  self.loadout[ "primary_weapon" ] ) == "sniper");
	
	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();
	
	self notify ( "changed_kit" );
	self notify ( "giveLoadout" );
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