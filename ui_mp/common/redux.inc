#define WHITE						1 1 1
#define BLACK						0 0 0
#define EXISTS( var )				localVarString( var ) != ""
#define LOCALISE( string )			"@" + string
#define true						1
#define false						0

#define CHOICE_GAMEPAD_Y			8 // getting lazy here :D
#define CHOICE_X_START				-50
#define CHOICE_Y_START				20
#define CHOICE_X_SIZE				250
#define CHOICE_Y_SIZE				32
#define CHOICE_X_SPACING			( CHOICE_X_SIZE + 4 )
#define CHOICE_Y_SPACING			( CHOICE_Y_SIZE + 4 )
#define CHOICE_ROW( idx )			( ( idx - 0 ) % 24 )
#define CHOICE_COL( idx )			( ( idx - 0 - ( ( idx - 0 ) % 24 ) ) / 24 )
#define CHOICE_Y_TEXTALIGN			0

#define CHOICE_X( idx ) 			( CHOICE_X_START + CHOICE_X_SPACING * CHOICE_COL( idx ) )
#define CHOICE_Y( idx ) 			( CHOICE_Y_START + CHOICE_Y_SPACING * CHOICE_ROW( idx ) )
#define CHOICE_ORIGIN( idx )		CHOICE_X( idx ) CHOICE_Y( idx )
#define CHOICE_RECT( idx )			CHOICE_ORIGIN( idx ) 250 CHOICE_Y_SIZE 1 1

#define CREATE_SHADER( position, texture, colour ) \
		CREATE_SHADER_VIS( position, texture, colour, 1 )

#define CREATE_SHADER_VIS( position, texture, colour, visibility ) \
		CREATE_SHADER_EX( position, texture, colour, visibility, ; )

#define CREATE_SHADER_EX( position, texture, colour, visibility, extra ) \
		itemDef \
		{ \
			style 			WINDOW_STYLE_SHADER \
			rect 			position; \
			forecolor 		colour \
			exp 			material ( texture ) \
			visible 		when ( visibility ) \
			decoration 		\
			extra			\
		}

#define CREATE_TEXT( position, string, color, visibility, extras ) \
		itemDef \
		{ \
			rect 			position; \
			style 			1 \
			forecolor 		color \
			exp 			text ( string ) \
			visible 		when ( visibility ) \
			textfont		UI_FONT_DEFAULT \
			decoration \
			extras \
		}

#define REDUX_BACK_WIDGET \
		CREATE_SHADER( -68.5 460 284 20 1 0, "white", 0 0 0 1 ) \
		CREATE_SHADER_VIS( -52 463 14 14 1 0, "button_ps3_circle", 1 1 1 1, dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 1 ) \
		CREATE_SHADER_VIS( -52 463 14 14 1 0, "button_b", 1 1 1 1, dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 0 ) \
		CREATE_SHADER_VIS( -57 465 20 10 1 0, "white", 1 1 1 0.65, !dvarBool( "gpad_enabled" ) ) \
		CREATE_TEXT( -57 465 20 10 1 0, "ESC", 0 0 0 1, !dvarBool( "gpad_enabled" ), textfont 6; textscale 0.2; textstyle 0; textalign ITEM_ALIGN_MIDDLE_CENTER ) \
		CREATE_TEXT( -68.5 460 284 20 1 0, "Back", 1 1 1 1, 1, textfont 0; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT; textalignx 36 )

#define REDUX_INGAME_MENU( create_sub ) \
		name 						MENU_NAME \
		rect 						0 0 640 480 4 4 \
		forecolor 					1 1 1 1
		focuscolor 					1 1 1 1 \
		blurworld 					7 \
		execKey "f" \
		{ \
			open "popup_friends"; \
		} \
		onOpen \
		{ \
			if ( create_sub ) \
			{ \
				open MENU_NAME"_r"; \
			} \
			REDUX_ANIMATE_OPEN; \
		} \
		onRequestClose \
		{ \
			if ( create_sub ) \
			{ \
				close MENU_NAME"_r"; \
			} \
			REDUX_ANIMATE_CLOSE; \
		} \
		CREATE_SHADER( 215 -4 -40 640 1 0, "gradient_fadein", 0 0 0 0.5 ) \
		CREATE_SHADER_EX( -68 -4 284 640 1 0, "white", 0 0 0 0.8, 1, border 1; bordersize 0.5; bordercolor 1 1 1 0.1 ) \
		CREATE_TEXT( -50 ( CHOICE_Y_START - 17 ) 0 0 1 1, MENU_TITLE, 1 1 1 1, 1, textfont 9; textscale 0.35; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		CREATE_SHADER( -50 ( CHOICE_Y_START - 7 ) 250 0.25 1 1, "white", 1 1 1 0.1 ) \
		REDUX_BACK_WIDGET

#define REDUX_INGAME_SUB \
		name 						MENU_NAME##"_r" \
		rect 						0 0 640 480 4 4 \
		forecolor 					1 1 1 1 \
		visible 					when ( menuisopen( MENU_NAME ) ) \
		decoration \
		onOpen \
		{ \
			REDUX_ANIMATE_SUB_OPEN; \
		} \
		onRequestClose \
		{ \
			REDUX_ANIMATE_SUB_CLOSE; \
		} \
		CREATE_SHADER( 0 0 854 480 0 0, "gradient_fadein", 0 0 0 0.4 )

#define REDUX_ANIMATE_OPEN \
		lerp x "from" -200 "to" 0 "over" 0.1; \
		lerp alpha "from" 0 "to" 1 "over" 0.1;

#define REDUX_ANIMATE_CLOSE \
		lerp alpha "from" 1 "to" 0 "over" 0.1; \
		lerp x "from" 0 "to" -200 "over" 0.1;

#define REDUX_ANIMATE_SUB_OPEN \
		lerp x "from" 200 "to" 0 "over" 0.1; \
		lerp alpha "from" 0 "to" 1 "over" 0.1;

#define REDUX_ANIMATE_SUB_CLOSE \
		lerp alpha "from" 1 "to" 0 "over" 0.1; \
		lerp x "from" 0 "to" 200 "over" 0.1;

#define REDUX_BUTTON( idx, string, action_ ) \
		REDUX_BUTTON_VIS( idx, string, action_, 1 )

#define REDUX_BUTTON_VIS( idx, string, action_, visibility ) \
		REDUX_BUTTON_ALL( idx, string, action_, visibility, ;, ;, 0 )

#define REDUX_BUTTON_ALL( idx, string, action_, visibility, focus, leavefocus, disable_ ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 32 CHOICE_Y_SIZE 1 1, "white", 0 0 0 0, visibility && dvarBool( "gpad_enabled" ), origin 218 0; group idx; exp forecolor r ( 0 ); exp forecolor g ( 0 ); exp forecolor b ( 0 ); ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 16 16 1 1, "button_ps3_cross", 1 1 1 0, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 1, origin 226 CHOICE_GAMEPAD_Y; group idx ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 16 16 1 1, "button_a", 1 1 1 0, visibility && dvarBool( "gpad_enabled" ) && dvarInt( "gpad_style" ) == 0, origin 226 CHOICE_GAMEPAD_Y; group idx ) \
		itemDef \
		{ \
			rect 					CHOICE_RECT( idx ) \
			type 					ITEM_TYPE_BUTTON \
			style					WINDOW_STYLE_FILLED \
			background      		"white" \
			visible 				when ( visibility ) \
			border					1 \
			bordercolor				1 1 1 0.05 \
			bordersize				0.25 \
			backcolor				1 1 1 0.01 \
			textfont 				0 \
			textaligny 				CHOICE_Y_TEXTALIGN \
			textalignx 				8 \
			textscale 				0.275 \
			textstyle 				3 \
			textalign 				ITEM_ALIGN_MIDDLE_LEFT \
			exp text				( string ) \
			disabled				when ( disable_ ) \
			disablecolor			1 1 1 0.5 \
			onFocus \
			{ \
				if ( !( disable_ ) ) \
				{ \
					setItemColor 			self backcolor 1 1 1 0.09; \
					setItemColor 			self bordercolor 1 1 1 0.25; \
					setItemColor 			idx backcolor 0 0 0 0.9; \
					setItemColor 			idx forecolor 1 1 1 1; \
					focus; \
				} \
				else \
				{ \
					setItemColor 			self backcolor 1 1 1 0.03; \
					focus; \
				} \
			} \
			leaveFocus \
			{ \
				setItemColor 			self backcolor 1 1 1 0.01; \
				setItemColor 			self bordercolor 1 1 1 0.05; \
				setItemColor 			idx backcolor 0 0 0 0; \
				setItemColor 			idx forecolor 0 0 0 0; \
				leavefocus; \
			} \
			action \
			{ \
				if ( !( disable_ ) ) \
				{ \
					action_; \
				} \
			} \
		}

#define REDUX_SEPARATOR( idx ) \
		REDUX_SEPARATOR_VIS( idx, 1 )

#define REDUX_SEPARATOR_VIS( idx, visibility ) \
		CREATE_SHADER_VIS( CHOICE_ORIGIN( idx ) 250 4 1 1, "gradient_center", 1 1 1 0.05; origin 0 0, visibility )

#define REDUX_GENERIC_FEEDER( index, action_, data ) \
		itemDef \
		{ \
			rect 					CHOICE_ORIGIN( 0 ) CHOICE_X_SIZE 400 1 1 \
			visible 				1 \
			forecolor 				WHITE 1 \
			outlinecolor 			1 1 1 0.2 \
			type 					6 \
			textalignx 				6 \
			textscale 				0.275 \
			feeder 					index \
			elementWidth 			CHOICE_X_SIZE \
			elementHeight 			18 \
			data \		
			doubleClick \		
			{ \		
				play 				"mouse_click"; \
				action_; \
			} \
		}

#define INGAME_FACTION_ICON( pos, alpha ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Allies" ), 1 1 1 alpha, localVarString( "ui_team" ) == "marines" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Axis" ), 1 1 1 alpha, localVarString( "ui_team" ) == "opfor" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Allies" ), 1 1 1 alpha, team( "name" ) == "TEAM_FREE" && localVarString( "ui_team" ) == "marines" ) \
		CREATE_SHADER_VIS( pos, dvarstring( "g_TeamIcon_Axis" ), 1 1 1 alpha, team( "name" ) == "TEAM_FREE" && localVarString( "ui_team" ) == "opfor" )

#define REDUX_GAME_WIDGET \
		itemDef \
		{ \
			name "fullmap_border" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			border 1 \
			bordersize 0.666667 \
			forecolor 1 1 1 1 \
			bordercolor 1 1 1 0.35 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 0.05 \
			background "minimap_scanlines" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_map" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 181 \
			forecolor 1 1 1 1 \
			background "compass_map_default" \
			type 8 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_friendlies" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 185 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_enemies" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 188 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_objectives" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 182 \
			forecolor 1 1 1 1 \
			background "objective_line" \
			type 8 \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_sentries" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 189 \
			forecolor 1 1 1 1 \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			name "fullmap_player" \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			ownerdraw 183 \
			forecolor 1 1 1 1 \
			background "compassping_player" \
			type 8 \
			textscale 0.55 \
			exp forecolor a ( 1 - radarJamIntensity() ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.64 0.74 0.71 1 \
			background "white" \
			textscale 0.55 \
			exp forecolor a ( radarJamIntensity() ) \
			visible when ( radarIsJammed() && !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 1 \
			background "ac130_overlay_grain" \
			textscale 0.55 \
			exp forecolor a ( radarJamIntensity() ) \
			visible when ( radarIsJammed() && !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 1 \
			background "stencil_base" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 1 1 1 1 \
			background "scanlines_stencil" \
			textscale 0.55 \
			exp rect y ( ( 135 - 240 ) + ( ( 240 * 2 ) * ( 1 - ( ( milliseconds() ) % 4000 ) / 4000 ) ) ) \
			visible when ( !isEMPJammed() ) \
		} \
		itemDef \
		{ \
			rect -260 135 240 240 3 1 \
			decoration \
			visible 1 \
			style 3 \
			forecolor 0.89 0.98 0.95 1 \
			background "stencil_fill" \
			textscale 0.55 \
			visible when ( !isEMPJammed() ) \
		} \		
		INGAME_FACTION_ICON( -90 -20 96 96 3 1, 0.2 ) \
		CREATE_TEXT( 0 0 0 20 3 1, getMapName(), 1 1 1 1, 1, textfont 9; textalignx 8; textscale 0.35; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT ) \
		CREATE_TEXT( 0 20 0 20 3 1, gametypeName(), 1 1 1 0.85, 1, textfont 6; textalignx 8; textscale 0.2; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT ) \
		CREATE_TEXT( -150 35 150 40 3 1, gametypeDescription(), 1 1 1 0.65, 1, textfont 0; textalignx 8; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_TOP_RIGHT )


#define CHANGE_CLASS_ACTION	\
		if ( localVarString( "ui_team" ) == "marines" ) \
		{ \
			scriptmenuresponse "changeclass_marines"; \
		} \
		if ( localVarString( "ui_team" ) == "opfor" ) \
		{ \
			scriptmenuresponse "changeclass_opfor"; \
		}


#define REDUX_BIND( idx, string, bind ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 55 CHOICE_Y_SIZE 1 1, "white", 0 0 0 0, 1, origin 195 0; group idx; exp forecolor r ( 0 ); exp forecolor g ( 0 ); exp forecolor b ( 0 ); ) \
		CREATE_TEXT( CHOICE_RECT( idx ), "KEYBINDING", 1 1 1 0.25, 1, textfont 0; textalignx 8; textaligny 5; textscale 0.2; textstyle 3; textalign ITEM_ALIGN_TOP_LEFT ) \
		CREATE_TEXT( CHOICE_RECT( idx ), string, 1 1 1 1, 1, textfont 0; textalignx 8; textaligny 4.5; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		itemDef \
		{ \
			rect 					CHOICE_RECT( idx ) \
			type 					ITEM_TYPE_BIND \
			style					WINDOW_STYLE_FILLED \
			background      		"white" \
			border					1 \
			bordercolor				1 1 1 0.05 \
			bordersize				0.25 \
			backcolor				1 1 1 0.01 \
			textfont 				0 \
			textalignx 				-10 \
			textscale 				0.275 \
			textstyle 				3 \
			textalign 				ITEM_ALIGN_MIDDLE_RIGHT \
			dvar					bind \
			visible					1 \
			onFocus \
			{ \
				setItemColor 			self backcolor 1 1 1 0.09; \
				setItemColor 			self bordercolor 1 1 1 0.25; \
				setItemColor 			idx backcolor 0 0 0 0.9; \
				setItemColor 			idx forecolor 1 1 1 1; \
				focus; \
			} \
			leaveFocus \
			{ \
				setItemColor 			self backcolor 1 1 1 0.01; \
				setItemColor 			self bordercolor 1 1 1 0.05; \
				setItemColor 			idx backcolor 0 0 0 0; \
				setItemColor 			idx forecolor 0 0 0 0; \
				leavefocus; \
			} \
		}

#define REDUX_SLIDER( idx, string, dvar, dvar_min, dvar_max, dvar_default, action_, show_value ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 55 CHOICE_Y_SIZE 1 1, "white", 0 0 0 0, 1, origin 195 0 ) \
		CREATE_TEXT( CHOICE_RECT( idx ), "SLIDER", 1 1 1 0.25, 1, textfont 0; textalignx 8; textaligny 5; textscale 0.2; textstyle 3; textalign ITEM_ALIGN_TOP_LEFT ) \
		CREATE_TEXT( CHOICE_RECT( idx ), string, 1 1 1 1, 1, textfont 0; textalignx 8; textaligny 4.5; textscale 0.275; textstyle 3; textalign ITEM_ALIGN_MIDDLE_LEFT ) \
		CREATE_TEXT( CHOICE_RECT( idx ), dvarInt( dvar ), 1 1 1 0.65, show_value, textalignX -30; textalignY -2; textfont 0; textscale 0.175; textalign ITEM_ALIGN_BOTTOM_RIGHT ) \
		itemDef \
		{ \
			rect 					CHOICE_RECT( idx ) \
			style					WINDOW_STYLE_FILLED \
			background      		"white" \
			border					1 \
			bordercolor				1 1 1 0.05 \
			bordersize				0.25 \
			backcolor				1 1 1 0.01 \
			visible					1 \
			decoration \
		} \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) -10 10 1 1, "ui_arrow_right", 1 1 1 0.25, 1, origin 228 12 ) \
		CREATE_SHADER_EX( CHOICE_ORIGIN( idx ) 10 10 1 1, "ui_arrow_right", 1 1 1 0.25, 1, origin 234 12 ) \
		itemDef \
		{ \
			rect CHOICE_ORIGIN( idx ) 95.5 12 1 1 \
			origin 126 9 \
			forecolor 1 1 1 1 \
			type ITEM_TYPE_SLIDER \
			dvarFloat dvar dvar_default dvar_min dvar_max \
			visible 1 \
			action \
			{ \
				action_; \
			} \
		}