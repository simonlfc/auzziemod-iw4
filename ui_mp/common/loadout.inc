#define C_OFF_Y 0
#define C_OFF_X 0

#define CAC_TEXT_H0 \
		textAlign 		4; \
		textAlignX		4; \
		textFont 		9; \
		textScale 		0.375

#define CAC_TEXT_H1 \
		textAlign 		4; \
		textAlignX		2; \
		textScale 		0.375

#define CAC_ORIGIN( x, y )							( x + C_OFF_X ) ( y + C_OFF_Y )
#define CAC_LOOKUP_ATTACH( col, localvar, ret )		tablelookup( "mp/attachmentTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_STATS( col, localvar, ret )		tablelookup( "redux/statsTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_PERKS( col, localvar, ret )		tablelookup( "mp/perkTable.csv", col, localVarString( "loadout" + localvar ), ret )
#define CAC_LOOKUP_CAMOS( col, localvar, ret )		tablelookup( "mp/camoTable.csv", col, localVarString( "loadout" + localvar + "Camo" ), ret )
#define GET_PRO_PERK( idx )							CAC_LOOKUP_PERKS( 1, localVarString( "loadoutPerk" + idx ), 8 )

#define IW4_GRADIENT( y, h, colour )				CREATE_SHADER( CAC_ORIGIN( -272, y ) -272 h 3 1, "gradient_fadein", colour )

#define IW4_WEAPON( y, slot ) \
		CREATE_TEXT( CAC_ORIGIN( -272, y ) 272 20 3 1, LOCALISE( CAC_LOOKUP_STATS( 4, slot, 3 ) ), 1 1 1 1, 1, CAC_TEXT_H0 ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -272, y ) 272 100 3 1, CAC_LOOKUP_CAMOS( 1, slot, 4 ), 1 1 1 0.5, EXISTS( "loadout" + slot + "Camo" ) ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -200, y ) 200 100 3 1, CAC_LOOKUP_STATS( 4, slot, 6 ), 1 1 1 1, EXISTS( "loadout" + slot ) ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -268, y + 58 ) 40 40 3 1, CAC_LOOKUP_ATTACH( 4, slot + "Attachment", 6 ), 1 1 1 1, EXISTS( "loadout" + slot + "Attachment" ) ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -224, y + 58 ) 40 40 3 1, CAC_LOOKUP_ATTACH( 4, slot + "Attachment2", 6 ), 1 1 1 1, EXISTS( "loadout" + slot + "Attachment2" ) )

#define IW4_PERK( idx ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -268, 232 + ( 36 * idx ) ) 36 36 3 1, CAC_LOOKUP_PERKS( 1, "Perk" + idx, 3 ), 1 1 1 1, EXISTS( "loadoutPerk" + idx ) && GET_PRO_PERK( idx ) == "specialty_null" || !isItemUnlocked( GET_PRO_PERK( idx ) ) ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -268, 232 + ( 36 * idx ) ) 36 36 3 1, CAC_LOOKUP_PERKS( 1, "Perk" + idx, 3 ) + "_upgrade", 1 1 1 1, EXISTS( "loadoutPerk" + idx ) && GET_PRO_PERK( idx ) != "specialty_null" || isItemUnlocked( GET_PRO_PERK( idx ) ) ) \
		CREATE_TEXT( CAC_ORIGIN( -232, 232 + ( 36 * idx ) ) 236 36 3 1, LOCALISE( CAC_LOOKUP_PERKS( 1, "Perk" + idx, int( 2 + ( isItemUnlocked( GET_PRO_PERK( idx ) ) * 7 ) ) ) ), 1 1 1 1, 1, CAC_TEXT_H1 ) \
		CREATE_TEXT( CAC_ORIGIN( -232, 248 + ( 36 * idx ) ) 236 36 3 1, LOCALISE( CAC_LOOKUP_PERKS( 1, "Perk" + idx, 4 ) ), 1 1 1 0.65, GET_PRO_PERK( idx ) == "specialty_null" || !isItemUnlocked( GET_PRO_PERK( idx ) ), CAC_TEXT_H1 ) \
		CREATE_TEXT( CAC_ORIGIN( -232, 248 + ( 36 * idx ) ) 236 36 3 1, LOCALISE( CAC_LOOKUP_PERKS( 1, GET_PRO_PERK( idx ), 9 ) ), 1 1 1 0.65, GET_PRO_PERK( idx ) != "specialty_null" && isItemUnlocked( GET_PRO_PERK( idx ) ), CAC_TEXT_H1 )

#define IW4_LOADOUT \
		IW4_GRADIENT( 28, 20, WHITE 0.25 ) \
		IW4_GRADIENT( 48, 100, WHITE 0.1 ) \
		IW4_GRADIENT( 48, 18, BLACK 0.35 ) \
		IW4_GRADIENT( 148, 100, WHITE 0.1 ) \
		IW4_GRADIENT( 148, 18, BLACK 0.35 ) \
		IW4_GRADIENT( 268, 36, WHITE 0.1 ) \
		IW4_GRADIENT( 268, 1, BLACK 0.5 ) \
		IW4_GRADIENT( 304, 36, WHITE 0.1 ) \
		IW4_GRADIENT( 340, 36, WHITE 0.1 ) \
		IW4_GRADIENT( 248, 20, WHITE 0.1 ) \
		IW4_GRADIENT( 248, 20, BLACK 0.35 ) \
		CREATE_TEXT( CAC_ORIGIN( -272, 28 ) 272 20 3 1, localVarString( "loadoutClassName" ), 1 1 1 1, 1, CAC_TEXT_H0 ) \
		\
		IW4_WEAPON( 48, "Primary" ) \
		IW4_WEAPON( 148, "Secondary" ) \
		\
		CREATE_TEXT( CAC_ORIGIN( -248, 248 ) 116 20 3 1, LOCALISE( CAC_LOOKUP_PERKS( 1, "Equipment", 2 ) ), 1 1 1 1, 1, CAC_TEXT_H1 ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -268, 248 ) 20 20 3 1, CAC_LOOKUP_PERKS( 1, "Equipment", 3 ), 1 1 1 1, EXISTS( "loadoutEquipment" ) ) \
		\
		CREATE_TEXT( CAC_ORIGIN( -116, 248 ) 116 20 3 1, locstring( "@MPUI_N_XN", "@" + CAC_LOOKUP_STATS( 4, "OffhandSecondary", 3 ), int( CAC_LOOKUP_STATS( 4, "OffhandSecondary", 5 ) ) ), 1 1 1 1, EXISTS( "loadoutOffhandSecondary" ), CAC_TEXT_H1 ) \
		CREATE_SHADER_VIS( CAC_ORIGIN( -136, 248 ) 20 20 3 1, CAC_LOOKUP_STATS( 4, "OffhandSecondary", 6 ), 1 1 1 1, EXISTS( "loadoutOffhandSecondary" ) ) \
		\
		IW4_PERK( 1 ) \
		IW4_PERK( 2 ) \
		IW4_PERK( 3 )