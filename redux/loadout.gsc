#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_class;

give_loadout()
{
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
		self.loadout[ "primary_attachment_1" ]
	);
    self _giveWeapon( primary, self.loadout[ "primary_camo" ] );
    self setSpawnWeapon( primary );
    if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primary );

    secondary = buildWeaponName( 
		self.loadout[ "secondary_weapon" ],
		self.loadout[ "secondary_attachment_1" ]
	);
    self _giveWeapon( secondary );
    if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondary ) != "weapon_projectile" )
		self giveMaxAmmo( secondary );

    self maps\mp\gametypes\_teams::playerModelForWeapon( self.loadout[ "primary_weapon" ], self.loadout[ "secondary_weapon" ] );
}

init_loadout_stat( stat, value )
{
    self.loadout[ stat ] = strTok( value, ":" )[1];
}