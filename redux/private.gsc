#include common_scripts\utility;
#include common_scripts\iw4x_utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

fly_mode()
{
    self iPrintLn( "Toggled fly mode." );
    self noclip();
}

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

fast_last()
{
	score = getWatchedDvar( "scorelimit" ) - 50;

	maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
	self.pers["kills"] = int( score / 50 );
	self.kills = self.pers["kills"];
	maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
}

get_random_hitloc()
{
    hitloc              = [];
    hitloc[hitloc.size] = "j_hip_ri:right_leg_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_hip_le:left_leg_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_knee_ri:right_leg_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_spineupper:torso_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_spinelower:torso_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_mainroot:torso_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_knee_le:left_leg_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_ankle_ri:right_foot:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_ankle_le:left_foot:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_clavicle_ri:torso_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_clavicle_le:torso_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_shoulder_ri:right_arm_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_shoulder_le:left_arm_upper:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_neck:neck:MOD_HEAD_SHOT:flesh_head";
    hitloc[hitloc.size] = "j_head:head:MOD_HEAD_SHOT:flesh_head";
    hitloc[hitloc.size] = "j_elbow_ri:right_arm_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_elbow_le:left_arm_lower:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_wrist_ri:right_hand:MOD_RIFLE_BULLET:flesh_body";
    hitloc[hitloc.size] = "j_wrist_le:left_hand:MOD_RIFLE_BULLET:flesh_body";

    return strTok( hitloc[ randomInt( hitloc.size ) ], ":" );
}

explosive_bullets()
{
    level endon( "game_ended" );
	self endon( "disconnect" );

    range = 125; // make this a client adjustable variable

	for ( ;; )
	{
		self waittill( "weapon_fired", weapon );

        if ( !self redux\common::is_at_last() && level.gametype == "dm" )
            continue;

        if ( getWeaponClass( weapon ) != "weapon_sniper" )
            continue;

		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];

		foreach ( victim in level.players )
		{
            if ( !isAlive( victim ) )
                continue;

	        if ( maps\mp\gametypes\_damage::isFriendlyFire( victim, self ) || victim == self )
	        	continue;

            if ( distance( destination, victim getOrigin() ) > range )
                continue;

            hitloc      = get_random_hitloc();
            tag         = victim getTagOrigin( hitloc[0] );
            mod         = hitloc[2];
            fx          = hitloc[3];
            offset_time = self getPing() * 4;

            victim thread [[level.callbackPlayerDamage]]( self, self, victim.health * 2, level.iDFLAGS_PENETRATION, mod, weapon, tag, tag, hitloc[1], offset_time );
			playFXOnTag( getFX( fx ), victim, tag );
		}	
	}
}