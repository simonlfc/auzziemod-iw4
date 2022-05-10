#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

save_position()
{
	if ( !self isOnGround() )
	{
		self iPrintLn( "Can't save position here." );
		return;
	}

	self.pers["saved_position"] 		= spawnStruct();
	self.pers["saved_position"].origin 	= self getOrigin();
	self.pers["saved_position"].angles 	= self getPlayerAngles();

	self iPrintLn( "Saved position." );
}

load_position()
{
	if ( !isDefined( self.pers["saved_position"] ) )
	{
		self iPrintLn( "No saved position found." );
		return;
	}

	self setOrigin( self.pers["saved_position"].origin );
	self setPlayerAngles( self.pers["saved_position"].angles );

	self iPrintLn( "Loaded position." );
}

get_random_hitloc()
{
    hitloc              = [];
    hitloc[hitloc.size] = "j_hip_ri:right_leg_upper";
    hitloc[hitloc.size] = "j_hip_le:left_leg_upper";
    hitloc[hitloc.size] = "j_knee_ri:right_leg_lower";
    hitloc[hitloc.size] = "j_spineupper:torso_lower";
    hitloc[hitloc.size] = "j_spinelower:torso_lower";
    hitloc[hitloc.size] = "j_mainroot:torso_lower";
    hitloc[hitloc.size] = "j_knee_le:left_leg_lower";
    hitloc[hitloc.size] = "j_ankle_ri:right_foot";
    hitloc[hitloc.size] = "j_ankle_le:left_foot";
    hitloc[hitloc.size] = "j_clavicle_ri:torso_upper";
    hitloc[hitloc.size] = "j_clavicle_le:torso_upper";
    hitloc[hitloc.size] = "j_shoulder_ri:right_arm_upper";
    hitloc[hitloc.size] = "j_shoulder_le:left_arm_upper";
    hitloc[hitloc.size] = "j_neck:neck";
    hitloc[hitloc.size] = "j_head:head";
    hitloc[hitloc.size] = "j_elbow_ri:right_arm_lower";
    hitloc[hitloc.size] = "j_elbow_le:left_arm_lower";
    hitloc[hitloc.size] = "j_wrist_ri:right_hand";
    hitloc[hitloc.size] = "j_wrist_le:left_hand";

    return strTok( hitloc[ randomInt( hitloc.size ) ], ":" );
}

explosive_bullets()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

    range = 125; // make this a client adjustable variable

	for ( ;; )
	{
		self waittill( "weapon_fired", weaponName );
		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];

		foreach ( victim in level.players )
		{
            if ( !isAlive( victim ) )
                continue;

	        if ( maps\mp\gametypes\_damage::isFriendlyFire( victim, self ) || victim == self )
	        	continue;

            if ( getWeaponClass( weaponName ) != "weapon_sniper" )
                continue;

            if ( distance( destination, victim getOrigin() ) > range )
                continue;

            hitloc      = get_random_hitloc();
            tag         = victim getTagOrigin( hitloc[0] );

            if ( hitloc[1] == "neck" || hitloc[1] == "head" )
            {
			    victim thread [[level.callbackPlayerDamage]]( self, self, victim.health, level.iDFLAGS_PENETRATION, "MOD_HEAD_SHOT", self getCurrentWeapon(), tag, tag, hitloc[1], ( self getPing() * 3 ) );
			    playFXOnTag( getFX( "flesh_head" ), victim, tag );
            }
            else
            {
			    victim thread [[level.callbackPlayerDamage]]( self, self, victim.health, level.iDFLAGS_PENETRATION, "MOD_RIFLE_BULLET", self getCurrentWeapon(), tag, tag, hitloc[1], ( self getPing() * 3 ) );
			    playFXOnTag( getFX( "flesh_body" ), victim, tag );
            }
		}	
	}
}