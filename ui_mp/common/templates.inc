#define IW4_INGAME \
        IW4_INGAME_SETUP \
        PREPROC_SHADER( 0 0 640 480 4 4, "white", 0 0 0 0.4 ) \
		IW4_GLOW \
        PREPROC_SHADER( -64 0 280 480 1 0, "gradient_fadein_fadebottom", 0 0 0 0.25 ) \
        IW4_TITLE( MENU_TITLE )

#ifndef C_OFF_Y
	#define C_OFF_Y 0
#endif

#ifndef C_OFF_X
	#define C_OFF_X 0
#endif

#define IW4_LOADOUT( var ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 28 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 1 1 1 0.25 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 28 + C_OFF_Y ) 272 20 3 1, localvarstring( var + "ClassName" ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) -272 100 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) -272 18 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) 272 18 3 1, "@" + tablelookup( "mp/statsTable.csv" , 4 , localvarstring( var + "Primary" ) , 3 ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) -272 100 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) -272 18 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) 272 18 3 1, "@" + tablelookup( "mp/statsTable.csv" , 4 , localvarstring( var + "Secondary" ) , 3 ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 268 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 304 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 340 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 248 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 248 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -248 + C_OFF_X ) ( 248 + C_OFF_Y ) 272 20 3 1, "@" + tablelookup( "mp/perkTable.csv" , 1 , localvarstring( var + "Equipment" ) , 2 ), 2, .375, 1 1 1 1 ) \
		PREPROC_CAC_TEXT( ( -116 + C_OFF_X ) ( 248 + C_OFF_Y ) 272 20 3 1, locstring( "@MPUI_N_XN" , "@" + tablelookup( "mp/statsTable.csv" , 4 , localvarstring( var + "OffhandSecondary" ) , 3 ) , int( tablelookup( "mp/statsTable.csv" , 4 , localvarstring( var + "OffhandSecondary" ) , 5 ) ) ), 2, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 268 + C_OFF_Y ) -272 1 3 1, "gradient_fadein", 0 0 0 0.5 )