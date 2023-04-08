#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_damage;
#include maps\mp\gametypes\_class;

hookReturnTrue( var1, var2, var3, var4, var5 )
{
	return true;
}

hookReturnFalse( var1, var2, var3, var4, var5 )
{
	return false;
}

hooks()
{
	// Disable quickmessages
	replaceFunc( maps\mp\gametypes\_quickmessages::init, ::hookReturnFalse );

	// Force ranked
	replaceFunc( maps\mp\_utility::rankingEnabled, ::hookReturnTrue );
	replaceFunc( maps\mp\_utility::privateMatch, ::hookReturnFalse );

	// Use our custom statstable.csv instead
	replaceFunc( maps\mp\_utility::getWeaponClass, ::getWeaponClassHook );

	// Disable forfeits
	replaceFunc( maps\mp\gametypes\_gamelogic::onForfeit, ::hookReturnFalse );

	// Intercept processLobbyData for map voting
	replaceFunc( maps\mp\gametypes\_gamelogic::processLobbyData, ::processLobbyDataHook );

	// Disable pre-match timer
	replaceFunc( maps\mp\gametypes\_gamelogic::matchStartTimerPC, maps\mp\gametypes\_gamelogic::matchStartTimerSkip );

	// Disable Deathstreaks
	replaceFunc( maps\mp\gametypes\_class::isValidDeathstreak, ::hookReturnFalse );

	// Disable Riot Shield
	replaceFunc( maps\mp\gametypes\_class::isValidPrimary, ::isValidPrimaryHook );

	// Disable Last Stand
	replaceFunc( maps\mp\gametypes\_class::isValidPerk3, ::isValidPerk3Hook );

	// Intercept valid weapon check to allow for our custom attachments
	replaceFunc( maps\mp\gametypes\_class::isValidWeapon, ::isValidWeaponHook );

	// Add support for in-game loadout
	replaceFunc( maps\mp\gametypes\_class::giveLoadout, ::giveLoadoutHook );

	// Add damage callback
	replaceFunc( maps\mp\gametypes\_damage::Callback_PlayerDamage_internal, ::playerDamageInternalHook );

	// Disable assisted suicides
	replaceFunc( maps\mp\gametypes\_damage::PlayerKilled_internal, ::playerKilledInternalHook );

	// Allow unbalanced teams
	replaceFunc( maps\mp\gametypes\_teams::getJoinTeamPermissions, ::hookReturnTrue );

	// Allow first connect players to spawn mid-round
	replaceFunc( maps\mp\gametypes\_playerlogic::maySpawn, ::maySpawnHook );

	// Fix SD teams
	replaceFunc( maps\mp\gametypes\sd::onStartGameType, ::onStartGametypeHook );

	// Allow class changing at any time
	replaceFunc( maps\mp\gametypes\_menus::menuClass, ::menuClassHook );

	// Disable owner crate capture time
	replaceFunc( maps\mp\killstreaks\_airdrop::useHoldThink, ::useHoldThinkLoopHook );

	// Disable tac insert enemy listener
	replaceFunc( maps\mp\perks\_perkfunctions::GlowStickEnemyUseListener, ::hookReturnFalse );

	// Disable tac insert damage
	replaceFunc( maps\mp\perks\_perkfunctions::GlowStickDamageListener, ::hookReturnFalse );

	// Give player Throwing Knife after placing TI
	replaceFunc( maps\mp\perks\_perkfunctions::monitorTIUse, ::monitorTIUseHook );
	replaceFunc( maps\mp\perks\_perkfunctions::setTacticalInsertion, ::setTIHook );
}

maySpawnHook()
{
	if ( getGametypeNumLives() || isDefined( level.disableSpawning ) )
	{
		if ( isDefined( level.disableSpawning ) && level.disableSpawning )
			return false;

		if ( self.pers["teamKillPunish"] )
			return false;

		if ( !self.pers["lives"] && gameHasStarted() )
			return false;

		/*
		else if ( gameHasStarted() )
		{
			// disallow spawning for late comers
			if ( !level.inGracePeriod && !self.hasSpawned )
				return false;
		}
		*/
	}

	return true;
}

useHoldThinkLoopHook( player, useTime )
{
	player playerLinkTo( self );
	player playerLinkedOffsetEnable();

	player _disableWeapon();

	self.curProgress = 0;
	self.inUse = true;
	self.useRate = 0;
	self.useTime = 3000;

	player thread maps\mp\killstreaks\_airdrop::personalUseBar( self );

	result = maps\mp\killstreaks\_airdrop::useHoldThinkLoop( player );
	assert( isDefined( result ) );

	if ( isAlive( player ) )
	{
		player _enableWeapon();
		player unlink();
	}

	if ( !isDefined( self ) )
		return false;

	self.inUse = false;
	self.curProgress = 0;

	return ( result );
}

playerKilledInternalHook( eInflictor, attacker, victim, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, isFauxDeath )
{
	prof_begin( "PlayerKilled" );
	//prof_begin( " PlayerKilled_1" );

	victim endon( "spawned" );
	victim notify( "killed_player" );

	assert( victim.sessionteam != "spectator" );

	if ( isDefined( attacker ) )
		attacker.assistedSuicide = undefined;

	if ( !isDefined( victim.idFlags ) )
	{
		if ( sMeansOfDeath == "MOD_SUICIDE" )
			victim.idFlags = 0;
		else if ( sMeansOfDeath == "MOD_GRENADE" && isSubstr( sWeapon, "frag_grenade" ) && iDamage == 100000 )
			victim.idFlags = 0;
		else if ( sWeapon == "nuke_mp" )
			victim.idFlags = 0;
		else if ( level.friendlyfire >= 2 )
			victim.idFlags = 0;
		else
			assertEx( 0, "Victims ID flags not set, but means of death was gr or nuke: " + sMeansOfDeath );
	}

	if ( victim.hasRiotShieldEquipped )
		victim LaunchShield( iDamage, sMeansofDeath );

	//victim thread checkForceBleedOut();

	if ( !isFauxDeath )
	{
		if ( isDefined( victim.endGame ) )
			victim VisionSetNakedForPlayer( level.script, 2 );
		else if ( !isDefined( victim.nuked ) )
		{
			victim VisionSetNakedForPlayer( level.script, 0 );
			victim ThermalVisionOff();
		}
	}
	else
	{
		victim.fauxDead = true;
		self notify( "death" );
	}

	if ( game[ "state" ] == "postgame" )
	{
		//prof_end( " PlayerKilled_1" );
		prof_end( "PlayerKilled" );
		return;
	}

	// replace params with last stand info
	deathTimeOffset = 0;

	if ( !isPlayer( eInflictor ) && isDefined( eInflictor.primaryWeapon ) )
		sPrimaryWeapon = eInflictor.primaryWeapon;
	else if ( isDefined( attacker ) && isPlayer( attacker ) && attacker getCurrentPrimaryWeapon() != "none" )
		sPrimaryWeapon = attacker getCurrentPrimaryWeapon();
	else
		sPrimaryWeapon = undefined;

	if ( isdefined( victim.useLastStandParams ) )
	{
		victim ensureLastStandParamsValidity();
		victim.useLastStandParams = undefined;

		assert( isdefined( victim.lastStandParams ) );

		eInflictor = victim.lastStandParams.eInflictor;
		attacker = victim.lastStandParams.attacker;
		iDamage = victim.lastStandParams.iDamage;
		sMeansOfDeath = victim.lastStandParams.sMeansOfDeath;
		sWeapon = victim.lastStandParams.sWeapon;
		sPrimaryWeapon = victim.lastStandParams.sPrimaryWeapon;
		vDir = victim.lastStandParams.vDir;
		sHitLoc = victim.lastStandParams.sHitLoc;

		deathTimeOffset = ( gettime() - victim.lastStandParams.lastStandStartTime ) / 1000;
		victim.lastStandParams = undefined;
	}

	//prof_end( " PlayerKilled_1" );
	//prof_begin( " PlayerKilled_2" );

	if ( !( ( !isDefined( attacker ) || attacker.classname == "trigger_hurt" || attacker.classname == "worldspawn" || attacker == victim ) && isDefined( self.attackers ) ) )
	{
		if ( isDefined( attacker ) )
			attacker.assistedSuicide = undefined;
	}

	// override MOD
	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, attacker ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";
	else if ( sMeansOfDeath != "MOD_MELEE" && !isDefined( victim.nuked ) )
		victim playDeathSound();

	friendlyFire = isFriendlyFire( victim, attacker );

	if ( isDefined( attacker ) )
	{
		// override attacker if it's a vehicle
		if ( attacker.code_classname == "script_vehicle" && isDefined( attacker.owner ) )
			attacker = attacker.owner;

		// override attacker if it's a sentry
		if ( attacker.code_classname == "misc_turret" && isDefined( attacker.owner ) )
			attacker = attacker.owner;

		// override attacker if it's a crate
		if ( attacker.code_classname == "script_model" && isDefined( attacker.owner ) )
		{
			attacker = attacker.owner;

			if ( !isFriendlyFire( victim, attacker ) && attacker != victim )
				attacker notify( "crushed_enemy" );
		}
	}

	//prof_end( " PlayerKilled_2" );
	//prof_begin( " PlayerKilled_3" );

	//prof_begin( " PlayerKilled_3_drop" );
	// drop weapons from killed player
	victim maps\mp\gametypes\_weapons::dropScavengerForDeath( attacker );	// must be done before dropWeaponForDeath, since we use some weapon information
	victim maps\mp\gametypes\_weapons::dropWeaponForDeath( attacker );
	//prof_end( " PlayerKilled_3_drop" );

	if ( !isFauxDeath )
	{
		victim.sessionstate = "dead";
		victim.statusicon = "hud_status_dead";
	}

	// UTS update aliveCount
	victim maps\mp\gametypes\_playerlogic::removeFromAliveCount();

	if ( !isDefined( victim.switching_teams ) )
	{
		// update our various stats
		victim incPersStat( "deaths", 1 );
		victim.deaths = victim getPersStat( "deaths" );
		victim updatePersRatio( "kdRatio", "kills", "deaths" );
		victim maps\mp\gametypes\_persistence::statSetChild( "round", "deaths", victim.deaths );
		victim incPlayerStat( "deaths", 1 );
	}

	if ( isDefined( attacker ) )
		attacker checkKillSteal( victim );

	// obituary
	obituary( victim, attacker, sWeapon, sMeansOfDeath );

	doKillcam = false;

	lifeId = getNextLifeId();

	victim logPrintPlayerDeath( lifeId, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc );
	victim maps\mp\_matchdata::logPlayerLife( lifeId );
	victim maps\mp\_matchdata::logPlayerDeath( lifeId, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc );

	if ( ( sMeansOfDeath == "MOD_MELEE" ) )
	{
		if ( IsSubStr( sWeapon, "riotshield" ) )
		{
			attacker incPlayerStat( "shieldkills", 1 );

			if ( !matchMakingGame() )
				victim incPlayerStat( "shielddeaths", 1 );
		}
		else
			attacker incPlayerStat( "knifekills", 1 );
	}

	//prof_end( " PlayerKilled_3" );
	//prof_begin( " PlayerKilled_4" );

	if ( victim isSwitchingTeams() )
		handleTeamChangeDeath();
	else if ( !isPlayer( attacker ) || ( isPlayer( attacker ) && sMeansOfDeath == "MOD_FALLING" ) )
		handleWorldDeath( attacker, lifeId, sMeansOfDeath, sHitLoc );
	else if ( attacker == victim )
		handleSuicideDeath( sMeansOfDeath, sHitLoc );
	else if ( friendlyFire )
	{
		if ( !isDefined( victim.nuked ) )
			handleFriendlyFireDeath( attacker );
	}
	else
	{
		if ( sMeansOfDeath == "MOD_GRENADE" && eInflictor == attacker )
			addAttacker( victim, attacker, eInflictor, sWeapon, iDamage, ( 0, 0, 0 ), vDir, sHitLoc, psOffsetTime, sMeansOfDeath );

		doKillcam = true;
		handleNormalDeath( lifeId, attacker, eInflictor, sWeapon, sMeansOfDeath );
		victim thread maps\mp\gametypes\_missions::playerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc, attacker.modifiers );

		victim.pers["cur_death_streak"]++;

		if ( !getGametypeNumLives() && !matchMakingGame() )
			victim setPlayerStatIfGreater( "deathstreak", victim.pers["cur_death_streak"] );
	}

	//prof_end( " PlayerKilled_4" );
	//prof_begin( " PlayerKilled_5" );

	// clear any per life variables
	victim resetPlayerVariables();
	victim.lastAttacker = attacker;
	victim.lastDeathPos = victim.origin;
	victim.deathTime = getTime();
	victim.wantSafeSpawn = false;
	victim.revived = false;
	victim.sameShotDamage = 0;

	if ( isFauxDeath )
	{
		doKillcam = false;
		deathAnimDuration = ( victim PlayerForceDeathAnim( eInflictor, sMeansOfDeath, sWeapon, sHitLoc, vDir ) );
	}

	victim.body = victim clonePlayer( deathAnimDuration );

	if ( isFauxDeath )
		victim PlayerHide();

	if ( victim isOnLadder() || victim isMantling() || !victim isOnGround() || isDefined( victim.nuked ) )
		victim.body startRagDoll();

	if ( !isDefined( victim.switching_teams ) )
		thread maps\mp\gametypes\_deathicons::addDeathicon( victim.body, victim, victim.team, 5.0 );

	thread delayStartRagdoll( victim.body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );

	// allow per gametype death handling
	victim thread [[ level.onPlayerKilled ]]( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, lifeId );

	if ( isPlayer( attacker ) )
		attackerNum = attacker getEntityNumber();
	else
		attackerNum = -1;

	killcamentity = victim getKillcamEntity( attacker, eInflictor, sWeapon );
	killcamentityindex = -1;
	killcamentitystarttime = 0;

	if ( isDefined( killcamentity ) )
	{
		killcamentityindex = killcamentity getEntityNumber();// must do this before any waiting lest the entity be deleted
		killcamentitystarttime = killcamentity.birthtime;

		if ( !isdefined( killcamentitystarttime ) )
			killcamentitystarttime = 0;
	}

	/#

	if ( getDvarInt( "scr_forcekillcam" ) != 0 )
		doKillcam = true;

#/

	if ( isDefined( attacker.finalKill ) )
		maps\mp\_awards::addAwardWinner( "finalkill", attacker.clientid );

	//prof_end( " PlayerKilled_5" );
	//prof_begin( " PlayerKilled_6" );

	if ( isDefined( attacker.finalKill ) && doKillcam && !isDefined( level.nukeDetonated ) )
	{
		level thread doFinalKillcam( 5.0, victim, attacker, attackerNum, killcamentityindex, killcamentitystarttime, sWeapon, deathTimeOffset, psOffsetTime );

		if ( !isFauxDeath )
			wait( 1.0 );
	}

	if ( !isFauxDeath )
	{
		if ( !level.showingFinalKillcam && !level.killcam && doKillcam )
		{
			if ( victim _hasPerk( "specialty_copycat" ) && isDefined( victim.pers["copyCatLoadout"] ) )
			{
				victim thread maps\mp\gametypes\_killcam::waitDeathCopyCatButton( attacker );
				wait( 1.0 );
			}
		}

		// let the player watch themselves die
		wait( 0.25 );
		victim thread maps\mp\gametypes\_killcam::cancelKillCamOnUse();
		wait( 0.25 );

		self.respawnTimerStartTime = gettime() + 1000;
		timeUntilSpawn = maps\mp\gametypes\_playerlogic::TimeUntilSpawn( true );

		if ( timeUntilSpawn < 1 )
			timeUntilSpawn = 1;

		victim thread maps\mp\gametypes\_playerlogic::predictAboutToSpawnPlayerOverTime( timeUntilSpawn );

		wait( 1.0 );
		victim notify( "death_delay_finished" );
	}

	postDeathDelay = ( getTime() - victim.deathTime ) / 1000;
	self.respawnTimerStartTime = gettime();

	if ( !( isDefined( victim.cancelKillcam ) && victim.cancelKillcam ) && doKillcam && level.killcam && game[ "state" ] == "playing" && !victim isUsingRemote() && !level.showingFinalKillcam )
	{
		livesLeft = !( getGametypeNumLives() && !victim.pers[ "lives" ] );
		timeUntilSpawn = maps\mp\gametypes\_playerlogic::TimeUntilSpawn( true );
		willRespawnImmediately = livesLeft && ( timeUntilSpawn <= 0 );

		if ( !livesLeft )
			timeUntilSpawn = -1;

		victim maps\mp\gametypes\_killcam::killcam( attackerNum, killcamentityindex, killcamentitystarttime, sWeapon, postDeathDelay + deathTimeOffset, psOffsetTime, timeUntilSpawn, maps\mp\gametypes\_gamelogic::timeUntilRoundEnd(), attacker, victim );
	}

	//prof_end( " PlayerKilled_6" );
	//prof_begin( " PlayerKilled_7" );

	//self openMenu( "killedby_card_hide" );

	if ( game[ "state" ] != "playing" )
	{
		if ( !level.showingFinalKillcam )
		{
			victim.sessionstate = "dead";
			victim ClearKillcamState();
		}

		//prof_end( " PlayerKilled_7" );
		prof_end( "PlayerKilled" );
		return;
	}

	// class may be undefined if we have changed teams
	if ( isValidClass( victim.class ) )
		victim thread maps\mp\gametypes\_playerlogic::spawnClient();

	//prof_end( " PlayerKilled_7" );
	prof_end( "PlayerKilled" );
}

onStartGametypeHook()
{
	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	game["attackers"] = "axis";
	game["defenders"] = "allies";

	setClientNameMode( "auto_change" );

	game["strings"]["target_destroyed"] = &"MP_TARGET_DESTROYED";
	game["strings"]["bomb_defused"] = &"MP_BOMB_DEFUSED";

	precacheString( game["strings"]["target_destroyed"] );
	precacheString( game["strings"]["bomb_defused"] );

	level._effect["bombexplosion"] = loadfx( "explosions/tanker_explosion" );

	setObjectiveText( game["attackers"], &"OBJECTIVES_SD_ATTACKER" );
	setObjectiveText( game["defenders"], &"OBJECTIVES_SD_DEFENDER" );

	setObjectiveScoreText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_SCORE" );
	setObjectiveScoreText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_SCORE" );

	setObjectiveHintText( game["attackers"], &"OBJECTIVES_SD_ATTACKER_HINT" );
	setObjectiveHintText( game["defenders"], &"OBJECTIVES_SD_DEFENDER_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_attacker" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sd_spawn_defender" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	allowed[0] = "sd";
	allowed[1] = "bombzone";
	allowed[2] = "blocker";
	maps\mp\gametypes\_gameobjects::main( allowed );

	maps\mp\gametypes\_rank::registerScoreInfo( "win", 2 );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", 1.5 );

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 20 );
	maps\mp\gametypes\_rank::registerScoreInfo( "plant", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 100 );

	thread maps\mp\gametypes\sd::updateGametypeDvars();
	thread maps\mp\gametypes\sd::bombs();
}

getWeaponClassHook( weapon )
{
	tokens = strTok( weapon, "_" );

	weaponClass = tablelookup( "redux/statstable.csv", 4, tokens[0], 2 );

	// handle special case weapons like grenades, airdrop markers, etc...
	if ( weaponClass == "" )
	{
		weaponName = strip_suffix( weapon, "_mp" );
		weaponClass = tablelookup( "redux/statstable.csv", 4, weaponName, 2 );
	}

	if ( isMG( weapon ) )
		weaponClass = "weapon_mg";
	else if ( isKillstreakWeapon( weapon ) )
		weaponClass = "killstreak";
	else if ( isDeathStreakWeapon( weapon ) )
		weaponClass = "deathstreak";
	else if ( weapon == "none" ) //airdrop crates
		weaponClass = "other";
	else if ( weaponClass == "" )
		weaponClass = "other";

	assertEx( weaponClass != "", "ERROR: invalid weapon class for weapon " + weapon );

	return weaponClass;
}


setTIHook()
{
	self setOffhandPrimaryClass( "other" );
	self takeWeapon( "throwingknife_mp" );
	self unsetPerk( "throwingknife_mp", false );

	self _giveWeapon( "flare_mp", 0 );
	self giveStartAmmo( "flare_mp" );

	self thread monitorTIUseHook();
}

monitorTIUseHook()
{
	self endon( "death" );
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "end_monitorTIUse" );

	self thread maps\mp\perks\_perkfunctions::updateTISpawnPosition();
	self thread maps\mp\perks\_perkfunctions::clearPreviousTISpawnpoint();

	for ( ;; )
	{
		self waittill( "grenade_fire", lightstick, weapName );

		if ( weapName != "flare_mp" )
			continue;

		if ( isDefined( self.setSpawnPoint ) )
			self maps\mp\perks\_perkfunctions::deleteTI( self.setSpawnPoint );

		if ( !isDefined( self.TISpawnPosition ) )
			continue;

		if ( self touchingBadTrigger() )
			continue;

		TIGroundPosition = playerPhysicsTrace( self.TISpawnPosition + ( 0, 0, 16 ), self.TISpawnPosition - ( 0, 0, 2048 ) ) + ( 0, 0, 1 );

		glowStick = spawn( "script_model", TIGroundPosition );
		glowStick.angles = self.angles;
		glowStick.team = self.team;
		glowStick.enemyTrigger = spawn( "script_origin", TIGroundPosition );
		glowStick thread maps\mp\perks\_perkfunctions::GlowStickSetupAndWaitForDeath( self );
		glowStick.playerSpawnPos = self.TISpawnPosition;

		glowStick thread maps\mp\gametypes\_weapons::createBombSquadModel( "weapon_light_stick_tactical_bombsquad", "tag_fire_fx", level.otherTeam[self.team], self );

		self maps\mp\perks\_perks::givePerk( "throwingknife_mp" );
		self.setSpawnPoint = glowStick;
		return;
	}
}


processLobbyDataHook()
{
	curPlayer = 0;

	foreach ( player in level.players )
	{
		if ( !isDefined( player ) )
			continue;

		player.clientMatchDataId = curPlayer;
		curPlayer++;

		setClientMatchData( "players", player.clientMatchDataId, "xuid", player.name );
	}

	maps\mp\_awards::assignAwards();
	maps\mp\_scoreboard::processLobbyScoreboards();

	sendClientMatchData();
	waitframe();

	if ( gameFlag( "map_voting_active" ) )
	{
		if ( matchMakingGame() )
			sendMatchData();

		foreach ( player in level.players )
			player.pers["stats"] = player.stats;

		redux\voting::startMapVote();
	}
}

isValidWeaponHook( refString )
{
	if ( isSubStr( refString, "irons" ) )
		return true;

	if ( !isDefined( level.weaponRefs ) )
	{
		level.weaponRefs = [];

		foreach ( weaponRef in level.weaponList )
			level.weaponRefs[ weaponRef ] = true;
	}

	if ( isDefined( level.weaponRefs[ refString ] ) )
		return true;

	assertMsg( "Replacing invalid weapon/attachment combo: " + refString );

	return false;
}


giveLoadoutHook( team, class, allowCopycat )
{
	self takeAllWeapons();

	primaryIndex = 0;

	// initialize specialty array
	self.specialty = [];

	if ( !isDefined( allowCopycat ) )
		allowCopycat = true;

	primaryWeapon = undefined;

	if ( isDefined( self.pers["copyCatLoadout"] ) && self.pers["copyCatLoadout"]["inUse"] && allowCopycat )
	{
		self maps\mp\gametypes\_class::setClass( "copycat" );
		self.class_num = getClassIndex( "copycat" );

		clonedLoadout = self.pers["copyCatLoadout"];

		loadoutPrimary = clonedLoadout["loadoutPrimary"];
		loadoutPrimaryAttachment = clonedLoadout["loadoutPrimaryAttachment"];
		loadoutPrimaryAttachment2 = clonedLoadout["loadoutPrimaryAttachment2"] ;
		loadoutPrimaryCamo = clonedLoadout["loadoutPrimaryCamo"];
		loadoutSecondary = clonedLoadout["loadoutSecondary"];
		loadoutSecondaryAttachment = clonedLoadout["loadoutSecondaryAttachment"];
		loadoutSecondaryAttachment2 = clonedLoadout["loadoutSecondaryAttachment2"];
		loadoutSecondaryCamo = clonedLoadout["loadoutSecondaryCamo"];
		loadoutEquipment = clonedLoadout["loadoutEquipment"];
		loadoutPerk1 = clonedLoadout["loadoutPerk1"];
		loadoutPerk2 = clonedLoadout["loadoutPerk2"];
		loadoutPerk3 = clonedLoadout["loadoutPerk3"];
		loadoutOffhand = clonedLoadout["loadoutOffhand"];
	}
	else if ( isSubstr( class, "custom" ) )
	{
		class_num = getClassIndex( class );
		self.class_num = class_num;

		loadoutPrimary = cac_getWeapon( class_num, 0 );
		loadoutPrimaryAttachment = cac_getWeaponAttachment( class_num, 0 );
		loadoutPrimaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 0 );
		loadoutPrimaryCamo = cac_getWeaponCamo( class_num, 0 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutSecondary = cac_getWeapon( class_num, 1 );
		loadoutSecondaryAttachment = cac_getWeaponAttachment( class_num, 1 );
		loadoutSecondaryAttachment2 = cac_getWeaponAttachmentTwo( class_num, 1 );
		loadoutSecondaryCamo = cac_getWeaponCamo( class_num, 1 );
		loadoutEquipment = cac_getPerk( class_num, 0 );
		loadoutPerk1 = cac_getPerk( class_num, 1 );
		loadoutPerk2 = cac_getPerk( class_num, 2 );
		loadoutPerk3 = cac_getPerk( class_num, 3 );
		loadoutOffhand = cac_getOffhand( class_num );
	}
	else
	{
		class_num 						= getClassIndex( class );
		self.class_num 					= class_num;

		loadoutPrimary 					= redux\loadout::getLoadoutStat( "primary_weapon" );
		loadoutPrimaryAttachment 		= redux\loadout::getLoadoutStat( "primary_attachment" );
		loadoutPrimaryAttachment2 		= "none"; // i am not implementing bling in menus bro get fookt make a pr
		loadoutPrimaryCamo 				= redux\loadout::getLoadoutStat( "primary_camo" );
		loadoutSecondary 				= redux\loadout::getLoadoutStat( "secondary_weapon" );
		loadoutSecondaryAttachment 		= redux\loadout::getLoadoutStat( "secondary_attachment" );
		loadoutSecondaryAttachment2 	= "none"; // i am not implementing bling in menus bro get fookt make a pr
		loadoutSecondaryCamo 			= redux\loadout::getLoadoutStat( "secondary_camo" );
		loadoutEquipment 				= redux\loadout::getLoadoutStat( "lethal" );
		loadoutPerk1 					= redux\loadout::getLoadoutStat( "perk1" );
		loadoutPerk2 					= redux\loadout::getLoadoutStat( "perk2" );
		loadoutPerk3 					= redux\loadout::getLoadoutStat( "perk3" );
		loadoutOffhand 					= redux\loadout::getLoadoutStat( "tactical" );
	}

	if ( loadoutPerk1 != "specialty_bling" )
	{
		loadoutPrimaryAttachment2 = "none";
		loadoutSecondaryAttachment2 = "none";
	}

	if ( loadoutPerk1 != "specialty_onemanarmy" && loadoutSecondary == "onemanarmy" )
		loadoutSecondary = table_getWeapon( level.classTableName, 10, 1 );

	if ( level.killstreakRewards )
	{
		loadoutKillstreak1 = "uav";
		loadoutKillstreak2 = "airdrop";
		loadoutKillstreak3 = "airdrop_mega";
	}
	else
	{
		loadoutKillstreak1 = "none";
		loadoutKillstreak2 = "none";
		loadoutKillstreak3 = "none";
	}

	secondaryName = buildWeaponName( loadoutSecondary, loadoutSecondaryAttachment, loadoutSecondaryAttachment2 );
	self _giveWeapon( secondaryName, int( tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) ) );

	self.loadoutPrimaryCamo = int( tableLookup( "mp/camoTable.csv", 1, loadoutPrimaryCamo, 0 ) );
	self.loadoutPrimary = loadoutPrimary;
	self.loadoutSecondary = loadoutSecondary;
	self.loadoutSecondaryCamo = int( tableLookup( "mp/camoTable.csv", 1, loadoutSecondaryCamo, 0 ) );

	self setOffhandPrimaryClass( "other" );

	// Action Slots
	self _setActionSlot( 1, "" );
	self _setActionSlot( 1, "nightvision" );
	self _setActionSlot( 3, "altMode" );
	self _setActionSlot( 4, "" );

	// Perks
	self _clearPerks();
	self _detachAll();

	self loadoutAllPerks( loadoutEquipment, loadoutPerk1, loadoutPerk2, loadoutPerk3 );

	self setKillstreaks( loadoutKillstreak1, loadoutKillstreak2, loadoutKillstreak3 );

	if ( self hasPerk( "specialty_extraammo", true ) && getWeaponClass( secondaryName ) != "weapon_projectile" )
		self giveMaxAmmo( secondaryName );

	// Primary Weapon
	primaryName = buildWeaponName( loadoutPrimary, loadoutPrimaryAttachment, loadoutPrimaryAttachment2 );
	self _giveWeapon( primaryName, self.loadoutPrimaryCamo );

	// fix changing from a riotshield class to a riotshield class during grace period not giving a shield
	if ( primaryName == "riotshield_mp" && level.inGracePeriod )
		self notify( "weapon_change", "riotshield_mp" );

	if ( self hasPerk( "specialty_extraammo", true ) )
		self giveMaxAmmo( primaryName );

	self setSpawnWeapon( primaryName );

	primaryTokens = strtok( primaryName, "_" );
	self.pers["primaryWeapon"] = primaryTokens[0];

	// Primary Offhand was given by givePerk (it's your perk1)

	// Secondary Offhand
	offhandSecondaryWeapon = loadoutOffhand + "_mp";

	if ( loadoutOffhand == "flash_grenade" )
		self setOffhandSecondaryClass( "flash" );
	else
		self setOffhandSecondaryClass( "smoke" );

	self giveWeapon( offhandSecondaryWeapon );

	if ( loadOutOffhand == "smoke_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );
	else if ( loadOutOffhand == "flash_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else if ( loadOutOffhand == "concussion_grenade" )
		self setWeaponAmmoClip( offhandSecondaryWeapon, 2 );
	else
		self setWeaponAmmoClip( offhandSecondaryWeapon, 1 );

	primaryWeapon = primaryName;
	self.primaryWeapon = primaryWeapon;
	self.secondaryWeapon = secondaryName;

	self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"], getBaseWeaponName( secondaryName ) );

	self.isSniper = weaponClass( self.primaryWeapon ) == "sniper";

	self maps\mp\gametypes\_weapons::updateMoveSpeedScale( "primary" );

	// cac specialties that require loop threads
	self maps\mp\perks\_perks::cac_selector();

	self notify( "changed_kit" );
	self notify( "giveLoadout" );
}

menuClassHook( response )
{
	self closeMenus();

	// clear new status of unlocked classes
	if ( response == "demolitions_mp,0" && self getPlayerData( "featureNew", "demolitions" ) )
		self setPlayerData( "featureNew", "demolitions", false );

	if ( response == "sniper_mp,0" && self getPlayerData( "featureNew", "sniper" ) )
		self setPlayerData( "featureNew", "sniper", false );

	// this should probably be an assert
	if ( !isDefined( self.pers["team"] ) || ( self.pers["team"] != "allies" && self.pers["team"] != "axis" ) )
		return;

	class = self maps\mp\gametypes\_class::getClassChoice( response );
	primary = self maps\mp\gametypes\_class::getWeaponChoice( response );

	if ( class == "restricted" )
	{
		self maps\mp\gametypes\_menus::beginClassChoice();
		return;
	}

	if ( response != "class0" && ( isDefined( self.pers["class"] ) && self.pers["class"] == class ) &&
	        ( isDefined( self.pers["primary"] ) && self.pers["primary"] == primary ) )
		return;

	if ( self.sessionstate == "playing" )
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		self maps\mp\gametypes\_class::setClass( self.pers["class"] );
		self.tag_stowed_back = undefined;
		self.tag_stowed_hip = undefined;

		self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], self.pers["class"] );
	}
	else
	{
		self.pers["class"] = class;
		self.class = class;
		self.pers["primary"] = primary;

		if ( game["state"] == "postgame" )
			return;

		if ( game["state"] == "playing" && !isInKillcam() )
			self thread maps\mp\gametypes\_playerlogic::spawnClient();
	}

	self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
}

isValidPrimaryHook( refString )
{
	switch ( refString )
	{
	case "ak47":
	case "m16":
	case "m4":
	case "fn2000":
	case "masada":
	case "famas":
	case "fal":
	case "scar":
	case "tavor":
	case "mp5k":
	case "uzi":
	case "p90":
	case "kriss":
	case "ump45":
	case "barrett":
	case "wa2000":
	case "m21":
	case "cheytac":
	case "rpd":
	case "sa80":
	case "mg4":
	case "m240":
	case "aug":
	case "m40a3":
	case "ak47classic":
	case "ak74u":
	case "peacekeeper":
	case "dragunov":
		return true;

	default:
		assertMsg( "Replacing invalid primary weapon: " + refString );
		return false;
	}
}

isValidPerk3Hook( refString )
{
	switch ( refString )
	{
	case "specialty_extendedmelee":
	case "specialty_bulletaccuracy":
	case "specialty_localjammer":
	case "specialty_heartbreaker":
	case "specialty_detectexplosive":
		return true;

	default:
		assertMsg( "Replacing invalid perk3: " + refString );
		return false;
	}
}


playerDamageInternalHook( eInflictor, eAttacker, victim, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( !isReallyAlive( victim ) )
		return;

	if ( isDefined( eAttacker ) && eAttacker.classname == "script_origin" && isDefined( eAttacker.type ) && eAttacker.type == "soft_landing" )
		return;

	if ( isDefined( level.hostMigrationTimer ) )
		return;

	if ( sMeansOfDeath == "MOD_FALLING" )
		victim thread emitFallDamage( iDamage );

	if ( sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && iDamage != 1 )
	{
		iDamage *= getDvarFloat( "scr_explBulletMod" );
		iDamage = int( iDamage );
	}

	if ( isDefined( eAttacker ) && eAttacker.classname == "worldspawn" )
		eAttacker = undefined;

	if ( isDefined( eAttacker ) && isDefined( eAttacker.gunner ) )
		eAttacker = eAttacker.gunner;

	attackerIsNPC = isDefined( eAttacker ) && !isDefined( eAttacker.gunner ) && ( eAttacker.classname == "script_vehicle" || eAttacker.classname == "misc_turret" || eAttacker.classname == "script_model" );
	attackerIsHittingTeammate = level.teamBased && isDefined( eAttacker ) && ( victim != eAttacker ) && isDefined( eAttacker.team ) && ( victim.pers[ "team" ] == eAttacker.team );

	stunFraction = 0.0;

	if ( iDFlags & level.iDFLAGS_STUN )
	{
		stunFraction = 0.0;
		//victim StunPlayer( 1.0 );
		iDamage = 0.0;
	}
	else if ( sHitLoc == "shield" )
	{
		if ( attackerIsHittingTeammate && level.friendlyfire == 0 )
			return;

		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" && !attackerIsHittingTeammate )
		{
			if ( isPlayer( eAttacker ) )
			{
				eAttacker.lastAttackedShieldPlayer = victim;
				eAttacker.lastAttackedShieldTime = getTime();
			}

			victim notify( "shield_blocked" );

			// fix turret + shield challenge exploits
			if ( sWeapon == "turret_minigun_mp" )
				shieldDamage = 25;
			else
				shieldDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );

			victim.shieldDamage += shieldDamage;

			// fix turret + shield challenge exploits
			if ( sWeapon != "turret_minigun_mp" || cointoss() )
				victim.shieldBulletHits++;

			if ( victim.shieldBulletHits >= level.riotShieldXPBullets )
			{
				if ( self.recentShieldXP > 4 )
					xpVal = int( 50 / self.recentShieldXP );
				else
					xpVal = 50;

				printLn( xpVal );

				victim thread maps\mp\gametypes\_rank::giveRankXP( "shield_damage", xpVal );
				victim thread giveRecentShieldXP();

				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_damage", victim.shieldDamage );

				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_bullet_hits", victim.shieldBulletHits );

				victim.shieldDamage = 0;
				victim.shieldBulletHits = 0;
			}
		}

		if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT )
		{
			if ( !attackerIsHittingTeammate )
				victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );

			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.

			if ( !( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_IMPACT_HUGE ) )
				iDamage *= 0.0;
		}
		else if ( iDFlags & level.iDFLAGS_SHIELD_EXPLOSIVE_SPLASH )
		{
			if ( isDefined( eInflictor ) && isDefined( eInflictor.stuckEnemyEntity ) && eInflictor.stuckEnemyEntity == victim ) //does enough damage to shield carrier to ensure death
				iDamage = 101;

			victim thread maps\mp\gametypes\_missions::genericChallenge( "shield_explosive_hits", 1 );
			sHitLoc = "none";	// code ignores any damage to a "shield" bodypart.
		}
		else
			return;
	}
	else if ( ( smeansofdeath == "MOD_MELEE" ) && IsSubStr( sweapon, "riotshield" ) )
	{
		if ( !( attackerIsHittingTeammate && ( level.friendlyfire == 0 ) ) )
		{
			stunFraction = 0.0;
			victim StunPlayer( 0.0 );
		}
	}

	if ( !attackerIsHittingTeammate )
		iDamage = maps\mp\perks\_perks::cac_modified_damage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc );

	if ( isDefined( level.modifyPlayerDamage ) )
		iDamage = int( [[level.modifyPlayerDamage]]( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc ) );

	if ( !iDamage )
		return false;

	victim.iDFlags = iDFlags;
	victim.iDFlagsTime = getTime();

	if ( game[ "state" ] == "postgame" )
		return;

	if ( victim.sessionteam == "spectator" )
		return;

	if ( isDefined( victim.canDoCombat ) && !victim.canDoCombat )
		return;

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;

	// handle vehicles/turrets and friendly fire
	if ( attackerIsNPC && attackerIsHittingTeammate )
	{
		if ( sMeansOfDeath == "MOD_CRUSH" )
		{
			victim _suicide();
			return;
		}

		if ( !level.friendlyfire )
			return;
	}

	prof_begin( "PlayerDamage flags/tweaks" );

	// Don't do knockback if the damage direction was not specified
	if ( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	friendly = false;

	if ( ( victim.health == victim.maxhealth && ( !isDefined( victim.lastStand ) || !victim.lastStand ) ) || !isDefined( victim.attackers ) && !isDefined( victim.lastStand ) )
	{
		victim.attackers = [];
		victim.attackerData = [];
	}

	if ( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, eAttacker ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";

	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "game", "onlyheadshots" ) )
	{
		if ( sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_EXPLOSIVE_BULLET" )
			return;
		else if ( sMeansOfDeath == "MOD_HEAD_SHOT" )
			iDamage = 150;
	}

	// explosive barrel/car detection
	if ( sWeapon == "none" && isDefined( eInflictor ) )
	{
		if ( isDefined( eInflictor.destructible_type ) && isSubStr( eInflictor.destructible_type, "vehicle_" ) )
			sWeapon = "destructible_car";
	}

	prof_end( "PlayerDamage flags/tweaks" );

	// check for completely getting out of the damage
	if ( !( iDFlags & level.iDFLAGS_NO_PROTECTION ) )
	{
		// items you own don't damage you in FFA
		if ( !level.teamBased && attackerIsNPC && isDefined( eAttacker.owner ) && eAttacker.owner == victim )
		{
			prof_end( "PlayerDamage player" );

			if ( sMeansOfDeath == "MOD_CRUSH" )
				victim _suicide();

			return;
		}

		if ( ( isSubStr( sMeansOfDeath, "MOD_GRENADE" ) || isSubStr( sMeansOfDeath, "MOD_EXPLOSIVE" ) || isSubStr( sMeansOfDeath, "MOD_PROJECTILE" ) ) && isDefined( eInflictor ) && isDefined( eAttacker ) )
		{
			// protect players from spawnkill grenades
			if ( eInflictor.classname == "grenade" && ( victim.lastSpawnTime + 3500 ) > getTime() && isDefined( victim.lastSpawnPoint ) && distance( eInflictor.origin, victim.lastSpawnPoint.origin ) < 250 )
			{
				prof_end( "PlayerDamage player" );
				return;
			}

			victim.explosiveInfo = [];
			victim.explosiveInfo[ "damageTime" ] = getTime();
			victim.explosiveInfo[ "damageId" ] = eInflictor getEntityNumber();
			victim.explosiveInfo[ "returnToSender" ] = false;
			victim.explosiveInfo[ "counterKill" ] = false;
			victim.explosiveInfo[ "chainKill" ] = false;
			victim.explosiveInfo[ "cookedKill" ] = false;
			victim.explosiveInfo[ "throwbackKill" ] = false;
			victim.explosiveInfo[ "suicideGrenadeKill" ] = false;
			victim.explosiveInfo[ "weapon" ] = sWeapon;

			isFrag = isSubStr( sWeapon, "frag_" );

			if ( eAttacker != victim )
			{
				if ( ( isSubStr( sWeapon, "c4_" ) || isSubStr( sWeapon, "claymore_" ) ) && isDefined( eAttacker ) && isDefined( eInflictor.owner ) )
				{
					victim.explosiveInfo[ "returnToSender" ] = ( eInflictor.owner == victim );
					victim.explosiveInfo[ "counterKill" ] = isDefined( eInflictor.wasDamaged );
					victim.explosiveInfo[ "chainKill" ] = isDefined( eInflictor.wasChained );
					victim.explosiveInfo[ "bulletPenetrationKill" ] = isDefined( eInflictor.wasDamagedFromBulletPenetration );
					victim.explosiveInfo[ "cookedKill" ] = false;
				}

				if ( isDefined( eAttacker.lastGrenadeSuicideTime ) && eAttacker.lastGrenadeSuicideTime >= gettime() - 50 && isFrag )
					victim.explosiveInfo[ "suicideGrenadeKill" ] = true;
			}

			if ( isFrag )
			{
				victim.explosiveInfo[ "cookedKill" ] = isDefined( eInflictor.isCooked );
				victim.explosiveInfo[ "throwbackKill" ] = isDefined( eInflictor.threwBack );
			}

			victim.explosiveInfo[ "stickKill" ] = isDefined( eInflictor.isStuck ) && eInflictor.isStuck == "enemy";
			victim.explosiveInfo[ "stickFriendlyKill" ] = isDefined( eInflictor.isStuck ) && eInflictor.isStuck == "friendly";
		}

		if ( isPlayer( eAttacker ) )
			eAttacker.pers[ "participation" ]++ ;

		prevHealthRatio = victim.health / victim.maxhealth;

		if ( attackerIsHittingTeammate )
		{
			if ( !matchMakingGame() && isPlayer( eAttacker ) )
				eAttacker incPlayerStat( "mostff", 1 );

			prof_begin( "PlayerDamage player" );// profs automatically end when the function returns

			if ( level.friendlyfire == 0 || ( !isPlayer( eAttacker ) && level.friendlyfire != 1 ) ) // no one takes damage
			{
				if ( sWeapon == "artillery_mp" || sWeapon == "stealth_bomb_mp" )
					victim damageShellshockAndRumble( eInflictor, sWeapon, sMeansOfDeath, iDamage, iDFlags, eAttacker );

				return;
			}
			else if ( level.friendlyfire == 1 )// the friendly takes damage
			{
				if ( iDamage < 1 )
					iDamage = 1;

				victim.lastDamageWasFromEnemy = false;

				victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
			}
			else if ( ( level.friendlyfire == 2 ) && isReallyAlive( eAttacker ) )// only the attacker takes damage
			{
				iDamage = int( iDamage * .5 );

				if ( iDamage < 1 )
					iDamage = 1;

				eAttacker.lastDamageWasFromEnemy = false;

				eAttacker.friendlydamage = true;
				eAttacker finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
				eAttacker.friendlydamage = undefined;
			}
			else if ( level.friendlyfire == 3 && isReallyAlive( eAttacker ) )// both friendly and attacker take damage
			{
				iDamage = int( iDamage * .5 );

				if ( iDamage < 1 )
					iDamage = 1;

				victim.lastDamageWasFromEnemy = false;
				eAttacker.lastDamageWasFromEnemy = false;

				victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );

				if ( isReallyAlive( eAttacker ) )// may have died due to friendly fire punishment
				{
					eAttacker.friendlydamage = true;
					eAttacker finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );
					eAttacker.friendlydamage = undefined;
				}
			}

			friendly = true;

		}
		else// not hitting teammate
		{
			prof_begin( "PlayerDamage world" );

			if ( iDamage < 1 )
				iDamage = 1;

			if ( isDefined( eAttacker ) && isPlayer( eAttacker ) )
				addAttacker( victim, eAttacker, eInflictor, sWeapon, iDamage, vPoint, vDir, sHitLoc, psOffsetTime, sMeansOfDeath );

			if ( sMeansOfDeath == "MOD_EXPLOSIVE" || sMeansOfDeath == "MOD_GRENADE_SPLASH" && iDamage < victim.health )
				victim notify( "survived_explosion" );

			if ( isdefined( eAttacker ) )
				level.lastLegitimateAttacker = eAttacker;

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) )
				eAttacker thread maps\mp\gametypes\_weapons::checkHit( sWeapon, victim );

			if ( isdefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( sWeapon ) && eAttacker != victim )
			{
				eAttacker thread maps\mp\_events::damagedPlayer( self, iDamage, sWeapon );
				victim.attackerPosition = eAttacker.origin;
			}
			else
				victim.attackerPosition = undefined;

			if ( issubstr( sMeansOfDeath, "MOD_GRENADE" ) && isDefined( eInflictor.isCooked ) )
				victim.wasCooked = getTime();
			else
				victim.wasCooked = undefined;

			victim.lastDamageWasFromEnemy = ( isDefined( eAttacker ) && ( eAttacker != victim ) );

			if ( victim.lastDamageWasFromEnemy )
				eAttacker.damagedPlayers[ victim.guid ] = getTime();

			victim finishPlayerDamageWrapper( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime, stunFraction );

			if ( isDefined( level.ac130player ) && isDefined( eAttacker ) && ( level.ac130player == eAttacker ) )
				level notify( "ai_pain", victim );

			victim thread maps\mp\gametypes\_missions::playerDamaged( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc );

			prof_end( "PlayerDamage world" );

		}

		if ( attackerIsNPC && isDefined( eAttacker.gunner ) )
			damager = eAttacker.gunner;
		else
			damager = eAttacker;

		if ( isDefined( damager ) && damager != victim && iDamage > 0 )
		{
			if ( iDFlags & level.iDFLAGS_STUN )
				typeHit = "stun";
			else if ( victim hasPerk( "specialty_armorvest", true ) || ( isExplosiveDamage( sMeansOfDeath ) && victim _hasPerk( "_specialty_blastshield" ) ) )
				typeHit = "hitBodyArmor";
			else if ( victim _hasPerk( "specialty_combathigh" ) )
				typeHit = "hitEndGame";
			else
				typeHit = "standard";

			damager thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( typeHit );
		}

		victim.hasDoneCombat = true;
	}

	if ( isdefined( eAttacker ) && ( eAttacker != victim ) && !friendly )
		level.useStartSpawns = false;


	//=================
	// Damage Logging
	//=================

	prof_begin( "PlayerDamage log" );

	// why getEntityNumber() for victim and .clientid for attacker?
	if ( getDvarInt( "g_debugDamage" ) )
		println( "client:" + victim getEntityNumber() + " health:" + victim.health + " attacker:" + eAttacker.clientid + " inflictor is player:" + isPlayer( eInflictor ) + " damage:" + iDamage + " hitLoc:" + sHitLoc );

	if ( victim.sessionstate != "dead" )
	{
		lpselfnum = victim getEntityNumber();
		lpselfname = victim.name;
		lpselfteam = victim.pers[ "team" ];
		lpselfGuid = victim.guid;
		lpattackerteam = "";

		if ( isPlayer( eAttacker ) )
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker.guid;
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers[ "team" ];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		logPrint( "D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n" );
	}

	HitlocDebug( eAttacker, victim, iDamage, sHitLoc, iDFlags );

	/*if( isDefined( eAttacker ) && eAttacker != victim )
	{
		if ( isPlayer( eAttacker ) )
			eAttacker incPlayerStat( "damagedone", iDamage );

		victim incPlayerStat( "damagetaken", iDamage );
	}*/

	prof_end( "PlayerDamage log" );
}