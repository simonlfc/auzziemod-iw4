#define CAC_OPEN( type, extra ) \
		setLocalVarString "cac_type" ( type ); \
		extra; \
		open "loadout_select";

#define CAC_SUB_OPEN( type ) \
		setLocalVarString "cac_type" ( type );

#define CAC_BUTTON( idx, text, action_, vis ) \
		REDUX_BUTTON_VIS( idx, text, action_, localVarString( "cac_type" ) == vis )

#define CAC_SELECT_WEAPON( weapon ) \
		setLocalVarString "cac_current_weapon" ( weapon ); \
		if ( localVarInt( "weapon_slot" ) == 0 ) \
		{ \
			setLocalVarString "loadout_primary" ( weapon ); \
			scriptmenuresponse "loadout_primary:"weapon; \
		} \
		else \
		{ \
			setLocalVarString "loadout_secondary" ( weapon ); \
			scriptmenuresponse "loadout_secondary:"weapon; \
		} \
		setLocalVarString "cac_type" ( "attachments" ); \

#define CAC_SELECT_ATTACHMENT( idx ) \
		if ( localVarInt( "weapon_slot" ) == 0 ) \
		{ \
			setLocalVarString "loadout_primary_attachment" ( idx ); \
			scriptmenuresponse "loadout_primary_attachment:"idx; \
		} \
		else \
		{ \
			setLocalVarString "loadout_secondary_attachment" ( idx ); \
			scriptmenuresponse "loadout_secondary_attachment:"idx; \
		} \
		setLocalVarString "cac_type" ( "camos" );

#define CAC_SELECT_CAMO( idx ) \
		if ( localVarInt( "weapon_slot" ) == 0 ) \
		{ \
			setLocalVarString "loadout_primary_camo" ( idx ); \
			scriptmenuresponse "loadout_primary_camo:"idx; \
		} \
		else \
		{ \
			setLocalVarString "loadout_secondary_camo" ( idx ); \
			scriptmenuresponse "loadout_secondary_camo:"idx; \
		} \
		close "loadout_select";

#define CAC_SELECT_PERK( name ) \
		if ( localVarInt( "perk_slot" ) == 0 ) \
		{ \
			setLocalVarString "loadout_perk1" ( name ); \
			scriptmenuresponse "loadout_perk1:"name; \
		} \
		if ( localVarInt( "perk_slot" ) == 1 ) \
		{ \
			setLocalVarString "loadout_perk2" ( name ); \
			scriptmenuresponse "loadout_perk2:"name; \
		} \
		if ( localVarInt( "perk_slot" ) == 2 ) \
		{ \
			setLocalVarString "loadout_perk3" ( name ); \
			scriptmenuresponse "loadout_perk3:"name; \
		} \
		close "loadout_select";
		
#define IS_WEAPON \
		( localVarString( "cac_type" ) == "weapon_assault" \
		|| localVarString( "cac_type" ) == "weapon_smg" \
		|| localVarString( "cac_type" ) == "weapon_lmg" \
		|| localVarString( "cac_type" ) == "weapon_sniper" \
		|| localVarString( "cac_type" ) == "weapon_machine_pistol" \
		|| localVarString( "cac_type" ) == "weapon_shotgun" \
		|| localVarString( "cac_type" ) == "weapon_pistol" \
		|| localVarString( "cac_type" ) == "weapon_projectile" )

// add disable param when it = an existing weapon in your loadout
#define CAC_WEAPON( idx, weapon ) \
		REDUX_BUTTON_ALL( idx, "@" + tablelookup( "redux/statsTable.csv", 4, weapon, 3 ), CAC_SELECT_WEAPON( weapon );, tablelookup( "redux/statsTable.csv", 4, weapon, 2 ) == localVarString( "cac_type" ), setLocalVarString "cac_current_focus" ( weapon );, ;, 0 )
		
#define CAC_ATTACHMENT( idx, fixed_idx ) \
		REDUX_BUTTON_VIS( idx, "@" + tablelookup( "redux/attachmentTable.csv", 4, tablelookup( "redux/statsTable.csv", 4, localVarString( "cac_current_weapon" ), 10 + idx ), 3 ), CAC_SELECT_ATTACHMENT( fixed_idx );, tablelookup( "redux/statsTable.csv", 4, localVarString( "cac_current_weapon" ), 10 + idx ) != "" && localVarString( "cac_type" ) == "attachments" )

#define CAC_CAMO( idx, name ) \
		REDUX_BUTTON_VIS( idx, "@" + tableLookup( "mp/camoTable.csv", 1, name, 2 ), CAC_SELECT_CAMO( name );, tablelookup( "redux/statsTable.csv", 4, localVarString( "cac_current_weapon" ), 0 ) < 52 && localVarString( "cac_type" ) == "camos" )

#define CAC_PERK( idx, name, slot ) \
		REDUX_BUTTON_VIS( idx, "@" + tableLookup( "mp/perkTable.csv", 1, name, 9 ), CAC_SELECT_PERK( name );, localVarString( "cac_type" ) == "perk_select" && localVarInt( "perk_slot" ) == slot )

#define CAC_LETHAL( idx, name ) \
		REDUX_BUTTON_VIS( idx, "@" + tableLookup( "mp/perkTable.csv", 1, name, 2 ), setLocalVarString "loadout_lethal" ( name ); scriptmenuresponse "loadout_lethal:"name; close "loadout_select";, localVarString( "cac_type" ) == "lethal_select" )

#define GET_TACTICAL_LOCNAME( name )	locstring( "@MPUI_N_XN", "@" + tablelookup( "redux/statsTable.csv", 4, name, 3 ) , int( tablelookup( "redux/statsTable.csv", 4, name, 5 ) ) )

#define CAC_TACTICAL( idx, name ) \
		REDUX_BUTTON_VIS( idx, GET_TACTICAL_LOCNAME( name ), setLocalVarString "loadout_tactical" ( name ); scriptmenuresponse "loadout_tactical:"name; close "loadout_select";, localVarString( "cac_type" ) == "tactical_select" )

#define CAC_LOOKUP_ATTACH( col, localvar, ret )		tablelookup( "redux/attachmentTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_STATS( col, localvar, ret )		tablelookup( "redux/statsTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_PERKS( col, localvar, ret )		tablelookup( "mp/perkTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_CAMOS( col, localvar, ret )		tablelookup( "mp/camoTable.csv", col, localVarString( "loadout" + localvar + "Camo" ), ret )
#define GET_PRO_PERK( idx )							CAC_LOOKUP_PERKS( 1, localVarString( "loadoutPerk" + idx ), 8 )

#define GET_ATTACHMENT_INDEX( weapon, idx )			CAC_LOOKUP_STATS( 4, weapon, 11 + int( idx ) )

#define UPDATE_CAC_FOCUS \
		setLocalVarString "loadoutPrimaryAttachment2" ( "none" ); \
		setLocalVarString "loadoutSecondaryAttachment2" ( "none" ); \
		setLocalVarString "loadoutStreak1" ( "none" ); \
		setLocalVarString "loadoutStreak2" ( "none" ); \
		setLocalVarString "loadoutStreak3" ( "none" ); \
		setLocalVarString "loadoutDeathStreak" ( "none" ); \
		setLocalVarString "loadoutPrimary" ( localVarString( "loadout_primary" ) ); \
		setLocalVarString "loadoutPrimaryAttachment" ( GET_ATTACHMENT_INDEX( localVarString( "loadout_primary" ), localVarString( "loadout_primary_attachment" ) ) ); \
		setLocalVarString "loadoutPrimaryCamo" ( localVarString( "loadout_primary_camo" ) ); \
		setLocalVarString "loadoutSecondary" ( localVarString( "loadout_secondary" ) ); \
		setLocalVarString "loadoutSecondaryAttachment" ( GET_ATTACHMENT_INDEX( localVarString( "loadout_secondary" ), localVarString( "loadout_secondary_attachment" ) ) ); \
		setLocalVarString "loadoutSecondaryCamo" ( localVarString( "loadout_secondary_camo" ) ); \
		setLocalVarString "loadoutEquipment" ( localVarString( "loadout_lethal" ) ); \
		setLocalVarString "loadoutPerk1" ( localVarString( "loadout_perk1" ) ); \
		setLocalVarString "loadoutPerk2" ( localVarString( "loadout_perk2" ) ); \
		setLocalVarString "loadoutPerk3" ( localVarString( "loadout_perk3" ) ); \
		setLocalVarString "loadoutOffhandSecondary" ( localVarString( "loadout_tactical" ) ); \
		setLocalVarString "loadoutClassName" ( "Created Class" );

#define UPDATE_CLASS_FOCUS( itemIndex ) \
		setLocalVarInt "classIndex" itemIndex; \
		setLocalVarString "loadoutPrimary" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 0, "weapon" ) ); \
		setLocalVarString "loadoutPrimaryAttachment" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 0, "attachment", 0 ) ); \
		setLocalVarString "loadoutPrimaryAttachment2" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 0, "attachment", 1 ) ); \
		if ( localVarString( "loadoutPrimaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutPrimaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutPrimaryCamo" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 0, "camo" ) ); \
		setLocalVarString "loadoutSecondary" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 1, "weapon" ) ); \
		setLocalVarString "loadoutSecondaryAttachment" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 1, "attachment", 0 ) ); \
		setLocalVarString "loadoutSecondaryAttachment2" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 1, "attachment", 1 ) ); \
		if ( localVarString( "loadoutSecondaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutSecondaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutSecondaryCamo" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "weaponSetups", 1, "camo" ) ); \
		setLocalVarString "loadoutEquipment" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "perks", 0 ) ); \
		setLocalVarString "loadoutPerk1" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "perks", 1 ) ); \
		setLocalVarString "loadoutPerk2" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "perks", 2 ) ); \
		setLocalVarString "loadoutPerk3" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "perks", 3 ) ); \
		setLocalVarString "loadoutStreak1" ( getPlayerData( "killstreaks", 0 ) ); \
		setLocalVarString "loadoutStreak2" ( getPlayerData( "killstreaks", 1 ) ); \
		setLocalVarString "loadoutStreak3" ( getPlayerData( "killstreaks", 2 ) ); \
		setLocalVarString "loadoutOffhandSecondary" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "specialGrenade" ) ); \
		setLocalVarString "loadoutClassName" ( getPlayerData( "customClasses", localVarInt( "classIndex" ), "name" ) );