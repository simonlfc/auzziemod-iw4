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
		REDUX_BUTTON_ALL( idx, "@" + tablelookup( "redux/statsTable.csv", 4, weapon, 3 ), CAC_SELECT_WEAPON( weapon );, tablelookup( "redux/statsTable.csv", 4, weapon, 2 ) == localVarString( "cac_type" ), setLocalVarString "cac_current_focus" ( weapon );, ;, ; )
		
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