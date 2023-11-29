#include common_scripts\utility;
#include common_scripts\iw4x_utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\utils;

savePosition()
{
	if ( !self isOnGround() )
	{
		self iPrintLn( "Can't save position here." );
		return;
	}

	self.pers["saved_position"] = spawnStruct();
	self.pers["saved_position"].origin = self getOrigin();
	self.pers["saved_position"].angles = self getPlayerAngles();

	self iPrintLn( "Saved position." );
}

loadPosition()
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

fastLast()
{
	if ( level.gametype != "dm" )
		return;

	score = getWatchedDvar( "scorelimit" ) - 50;
	maps\mp\gametypes\_gamescore::_setPlayerScore( self, score );
	self.pers["kills"] = int( score / 50 );
	self.kills = self.pers["kills"];
	maps\mp\gametypes\_gamescore::sendUpdatedDMScores();
}

getDamageData()
{
	data = [];
	data[data.size] = "j_hip_ri:right_leg_upper:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_hip_le:left_leg_upper:MOD_RIFLE_BULLET:flesh_body";
	//data[data.size] = "j_knee_ri:right_leg_lower:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_spineupper:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_spinelower:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_mainroot:torso_lower:MOD_RIFLE_BULLET:flesh_body";
	//data[data.size] = "j_knee_le:left_leg_lower:MOD_RIFLE_BULLET:flesh_body";
	//data[data.size] = "j_ankle_ri:right_foot:MOD_RIFLE_BULLET:flesh_body";
	//data[data.size] = "j_ankle_le:left_foot:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_clavicle_ri:torso_upper:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_clavicle_le:torso_upper:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_shoulder_ri:right_arm_upper:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_shoulder_le:left_arm_upper:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_neck:neck:MOD_HEAD_SHOT:flesh_head";
	data[data.size] = "j_head:head:MOD_HEAD_SHOT:flesh_head";
	data[data.size] = "j_elbow_ri:right_arm_lower:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_elbow_le:left_arm_lower:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_wrist_ri:right_hand:MOD_RIFLE_BULLET:flesh_body";
	data[data.size] = "j_wrist_le:left_hand:MOD_RIFLE_BULLET:flesh_body";

	return strTok( data[ randomInt( data.size ) ], ":" );
}

explosiveBullets()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "weapon_fired", weapon );

		if ( !getDvarInt( "sv_extrafeatures", false ) )
			continue;

		setDvarIfUninitialized( "sv_ebrange", 300 );
			
		if ( !level.canUseEB && level.gametype == "sd" )
			continue;

		if ( !self isAtLast() && level.gametype == "dm" )
			continue;

		if ( getWeaponClass( weapon ) != "weapon_sniper" )
			continue;

		if ( self playerADS() >= 0.75 )
			continue;

		destination = bulletTrace( self getEye(), anglesToForward( self getPlayerAngles() ) * 1000000, true, self )["position"];

		foreach ( victim in level.players )
		{
			if ( !isAlive( victim ) )
				continue;

			if ( maps\mp\gametypes\_damage::isFriendlyFire( victim, self ) || victim == self )
				continue;

			//normal = vectorNormalize( victim.origin - self getEye() );
			//forward = anglesToForward( self getPlayerAngles() );
			//dot = vectorDot( forward, normal );
			//if ( dot < cos( 15 ) )
			//	continue;

			range = getDvarInt( "sv_ebrange" );

			if ( distance( destination, victim getOrigin() ) >= range )
				continue;

			data = getDamageData();
			tag = victim getTagOrigin( data[0] );
			hitloc = data[1];
			mod = data[2];
			effect = data[3]; 
			offset = Select( self isHost(), 35, self.ping ) * 3;

			victim thread [[level.callbackPlayerDamage]]( self, self, victim.health * 2, level.iDFLAGS_PENETRATION, mod, weapon, victim.origin, ( 0, 0, 0 ), hitloc, offset );
			playFX( getFX( effect ), tag );

			break;
		}
	}
}