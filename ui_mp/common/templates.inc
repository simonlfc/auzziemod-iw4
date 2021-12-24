#define IW4_INGAME \
        IW4_INGAME_SETUP \
        PREPROC_SHADER( 0 0 640 480 4 4, "white", 0 0 0 0.4 ) \
		IW4_GLOW \
        PREPROC_SHADER( -64 0 280 480 1 0, "gradient_fadein_fadebottom", 0 0 0 0.25 ) \
        IW4_TITLE( MENU_TITLE )

#define C_OFF_Y 0
#define C_OFF_X 0
#define CONST_CAC_ITEM_NUM 10

#define IW4_LOADOUT( var ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 28 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 1 1 1 0.25 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 28 + C_OFF_Y ) 272 20 3 1, localvarstring( var + "ClassName" ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) -272 100 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) -272 18 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 48 + C_OFF_Y ) 272 18 3 1, "@" + tablelookup( "mp/statsTable.csv", 4, localvarstring( var + "Primary" ), 3 ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) -272 100 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) -272 18 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -272 + C_OFF_X ) ( 148 + C_OFF_Y ) 272 18 3 1, "@" + tablelookup( "mp/statsTable.csv", 4, localvarstring( var + "Secondary" ), 3 ), 9, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 268 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 304 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 340 + C_OFF_Y ) -272 36 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 248 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 1 1 1 0.1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 248 + C_OFF_Y ) -272 20 3 1, "gradient_fadein", 0 0 0 0.35 ) \
		PREPROC_CAC_TEXT( ( -248 + C_OFF_X ) ( 248 + C_OFF_Y ) 272 20 3 1, "@" + tablelookup( "mp/perkTable.csv", 1, localvarstring( var + "Equipment" ), 2 ), 2, .375, 1 1 1 1 ) \
		PREPROC_CAC_TEXT( ( -116 + C_OFF_X ) ( 248 + C_OFF_Y ) 272 20 3 1, locstring( "@MPUI_N_XN", "@" + tablelookup( "mp/statsTable.csv", 4, localvarstring( var + "OffhandSecondary" ), 3 ), int( tablelookup( "mp/statsTable.csv", 4, localvarstring( var + "OffhandSecondary" ), 5 ) ) ), 2, .375, 1 1 1 1 ) \
		PREPROC_SHADER( ( -272 + C_OFF_X ) ( 268 + C_OFF_Y ) -272 1 3 1, "gradient_fadein", 0 0 0 0.5 )

#define CAC_POPUP \
		focuscolor 1 1 1 1 \
		fullscreen 0 \
		popup \
		onEsc \
		{ \
			close "loadout_select"; \
		} \
		itemDef \
		{ \
			rect -1004 -584 1708 960 2 2 \
			decoration \
			style 1 \
			forecolor 1 1 1 1 \
			backcolor 0 0 0 0.35 \
			background "white" \
			textscale 0.55 \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect -1004 -584 1708 960 2 2 \
			decoration \
			visible 1 \
			style 1 \
			forecolor 1 1 1 1 \
			backcolor 1 1 1 1 \
			background "xpbar_stencilbase" \
			textscale 0.55 \
		} \
		itemDef \
		{ \
			rect 0 0 854 184 1 1 \
			decoration \
			visible 1 \
			style 1 \
			forecolor 1 1 1 1 \
			backcolor 0.5 0.5 0.5 1 \
			background "white" \
			textscale 0.55 \
			exp rect h ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
		} \
		itemDef \
		{ \
			rect 0 0 1708 480 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 0.75 \
			background "mw2_popup_bg_fogstencil" \
			textscale 0.55 \
			exp rect x ( 0 - ( ( float( milliseconds( ) % 60000 ) / 60000 ) * ( 854 ) ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 -1708 -480 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.85 0.85 0.85 1 \
			background "mw2_popup_bg_fogscroll" \
			textscale 0.55 \
			exp rect x ( 0 - ( ( float( milliseconds( ) % 60000 ) / 60000 ) * ( 854 ) ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 854 0 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 1 \
			background "mockup_popup_bg_stencilfill" \
			textscale 0.55 \
			exp rect h ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
		} \
		itemDef \
		{ \
			rect 0 0 -1708 -480 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 0.75 \
			background "mw2_popup_bg_fogstencil" \
			textscale 0.55 \
			exp rect x ( ( - 854 ) + ( ( float( milliseconds( ) % 50000 ) / 50000 ) * ( 854 ) ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 -1708 -480 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.85 0.85 0.85 1 \
			background "mw2_popup_bg_fogscroll" \
			textscale 0.55 \
			exp rect x ( ( - 854 ) + ( ( float( milliseconds( ) % 50000 ) / 50000 ) * ( 854 ) ) ) \
		} \
		itemDef \
		{ \
			rect 0 0 854 0 1 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 0 \
			background "small_box_lightfx" \
			textscale 0.55 \
			exp rect h ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
		} \
		itemDef \
		{ \
			rect -96 -32 32 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_tl" \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect -64 -32 854 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_t" \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect 790 -32 32 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_tr" \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect 853 0 32 0 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_r" \
			exp rect h ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect 790 0 32 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_br" \
			exp rect y ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect -64 0 854 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_b" \
			exp rect y ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect -96 0 32 32 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_bl" \
			exp rect y ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		itemDef \
		{ \
			rect -96 0 32 0 1 1 \
			style 3 \
			decoration \
			forecolor 0 0 0 1 \
			background "drop_shadow_l" \
			exp rect h ( 4 + CONST_CAC_ITEM_NUM * 20 ) \
			visible when ( !localvarint( "ui_centerPopup" ) ) \
		} \
		PREPROC_SHADER( 0 -25 280 25 1 1, "black", 0 0 0 1 ) \
		PREPROC_SHADER( 0 -25 280 25 1 1, "gradient_fadein", 1 1 1 0.2 ) \
		PREPROC_TEXT_ALL( 3 -25 280 25 1 1, localVarString( "cac_type" ), 9, 0.375, 0, 4, 3, 64, 1 1 1 1, 1 )