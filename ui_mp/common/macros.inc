// common macros
#define PREPROC_SHADER( prect, pshader, pcolor ) \
		PREPROC_SHADER_VIS( prect, pshader, pcolor, 1 )

#define PREPROC_SHADER_VIS( prect, pshader, pcolor, pvisible ) \
		PREPROC_SHADER_ALL( prect, pshader, pcolor, pvisible, ; )

#define PREPROC_SHADER_ALL( prect, pshader, pcolor, pvisible, pextra ) \
		itemDef \
		{ \
			style 					3 \
			rect 					prect \
			forecolor 				pcolor \
			exp 					material ( pshader ) \
			visible 				when ( pvisible ) \
			decoration 				\
			pextra \
		}

#define PREPROC_CAC_TEXT( prect, ptext, pfont, pscale, pcolour ) \
		PREPROC_TEXT_ALL( prect, ptext, pfont, pscale, 0, 4, 0, 4, pcolour, 1 )

#define PREPROC_CAC_TEXT_VIS( prect, ptext, pfont, pscale, pcolour, vis ) \
		PREPROC_TEXT_ALL( prect, ptext, pfont, pscale, 0, 4, 0, 4, pcolour, vis )

#define PREPROC_TEXT( prect, ptext, pfont, pscale, pstyle, palign, pcolour ) \
		PREPROC_TEXT_VIS( prect, ptext, pfont, pscale, pstyle, palign, pcolour, 1 )

#define PREPROC_TEXT_VIS( prect, ptext, pfont, pscale, pstyle, palign, pcolour, pvisible ) \
		PREPROC_TEXT_ALL( prect, ptext, pfont, pscale, pstyle, palign, 0, 0, pcolour, pvisible )

#define PREPROC_TEXT_ALL( prect, ptext, pfont, pscale, pstyle, palign, paligny, palignx, pcolour, pvisible ) \
		itemDef \
		{ \
			rect 					prect \
			visible 				when ( pvisible ) \
			forecolor 				pcolour \
			textfont 				pfont \
			textalign 				palign \
			textaligny				paligny \
			textalignx				palignx \
			textscale 				pscale \
			textstyle				pstyle \
			exp 					text ( ptext ) \
			decoration 				\
			autowrapped				\
		}

// specific macros
#define IW4_TITLE( ptext ) \
		itemDef \
		{ \
			rect 					0 0 272 28 1 1 \
			visible 				1 \
			forecolor 				1 1 1 1 \
			textfont 				9 \
			textalign 				6 \
			textalignx 				-60 \
			textscale 				0.5 \
			text 					ptext \
			decoration 				\
		}

#define IW4_GLOW \
		PREPROC_SHADER_ALL( 0 0 640 480 4 4, "mockup_bg_glow", 1 1 1 0, 1, exp forecolor a ( ( ( sin ( milliseconds( ) / 1500 ) + 1 ) * 0.25 ) + 0.25 ) ) \
		PREPROC_SHADER_ALL( 0 0 640 480 4 4, "mockup_bg_glow", 1 1 1 0, 1, exp forecolor a ( ( ( sin ( milliseconds( ) / 480 ) + 1 ) * 0.25 ) + 0.25 ) )

// menu setups
#define IW4_INGAME_SETUP \
		focuscolor 					1 1 1 1 \
		blurworld 					7 \
		execKey "f" \
		{ \
			open "popup_friends"; \
		} \
		onEsc \
		{ \
			scriptmenuresponse "back"; \
		}

// choices
#ifndef CHOICE_X_START				
#define CHOICE_X_START				-64				
#endif

#ifndef CHOICE_Y_START				
#define CHOICE_Y_START				28				
#endif

#ifndef CHOICE_TEXTALIGN				
#define CHOICE_TEXTALIGN			6				
#endif

#ifndef CHOICE_TEXTALIGN_X				
#define CHOICE_TEXTALIGN_X			-60				
#endif

#define CHOICE_ROW( itemIndex )		( ( itemIndex - 0 ) % 20 )
#define CHOICE_COL( itemIndex )		( ( itemIndex - 0 - ( ( itemIndex - 0 ) % 20 ) ) / 20 )

#define CHOICE_X( itemIndex ) 		( CHOICE_X_START + 250 * CHOICE_COL( itemIndex ) )
#define CHOICE_Y( itemIndex ) 		( CHOICE_Y_START + 20 * CHOICE_ROW( itemIndex ) )
#define CHOICE_ORIGIN( itemIndex )	CHOICE_X( itemIndex ) CHOICE_Y( itemIndex )
#define CHOICE_RECT( itemIndex )	CHOICE_ORIGIN( itemIndex ) 336 20 1 1

#define CHOICE_BUTTON( itemIndex, textArg, actionArg ) \
		CHOICE_BUTTON_ALL( itemIndex, textArg, actionArg, ;, ;, 1, ; )

#define CHOICE_BUTTON_VIS( itemIndex, textArg, actionArg, visArg ) \
		CHOICE_BUTTON_ALL( itemIndex, textArg, actionArg, ;, ;, visArg, ; )

#define CHOICE_BUTTON_FOCUS_VIS( itemIndex, textArg, actionArg, onFocusArg, leaveFocusArg, visArg ) \
		CHOICE_BUTTON_ALL( itemIndex, textArg, actionArg, onFocusArg, leaveFocusArg, visArg, ; )

#define CHOICE_BUTTON_FOCUS( itemIndex, textArg, actionArg, onFocusArg, leaveFocusArg ) \
		CHOICE_BUTTON_ALL( itemIndex, textArg, actionArg, onFocusArg, leaveFocusArg, 1, ; )

#define CHOICE_BUTTON_ALL( itemIndex, textArg, actionArg, onFocusArg, leaveFocusArg, visArg, extraArgs ) \
		itemDef \
		{ \
			rect 					CHOICE_RECT( itemIndex ) \
			style 					1 \
			type 					1 \
			foreColor 				1 1 1 1 \
			disableColor 			0.6 0.55 0.55 1 \
			background 				"menu_button_selection_bar"	 \
			textAlign 				CHOICE_TEXTALIGN \
			textAlignX 				CHOICE_TEXTALIGN_X \
			textAlignY 				0 \
			textScale 				0.375 \
			textFont 				UI_FONT_NORMAL \
			exp 					text ( textArg ) \
			visible 				when ( visArg ) \
			extraArgs 				\
			CHOICE_SCRIPTS( itemIndex, actionArg, onFocusArg, leaveFocusArg ) \
		}

#define CHOICE_FRIENDS \
		CHOICE_BUTTON( 17, "@PLATFORM_FRIENDS_CAPS", open "popup_friends"; )

#define CHOICE_BACK \
		CHOICE_BUTTON( 18, "@PLATFORM_BACK_CAPS", scriptMenuResponse "back"; )

#define CHOICE_SCRIPTS( itemIndex, actionArg, onFocusArg, leaveFocusArg ) \
		onFocus \
		{ \
			onFocusArg 				\
			play 					"mouse_over"; \
			setItemColor 			self backcolor 0 0 0 1; \
			setLocalVarBool 		"ui_menuAButton" 1; \
		} \
		leaveFocus \
		{ \
			leaveFocusArg 			\
			setLocalVarBool 		"ui_menuAButton" ( 1 ); \
			setItemColor 			self backcolor 0 0 0 0; \
		} \
		action \
		{ \
			play 					"mouse_click"; \
			actionArg 				\
		}

#define CHOICE_SEPARATOR( itemIndex ) \
		CHOICE_SEPARATOR_VIS( itemIndex, 1 ) \

#define CHOICE_SEPARATOR_VIS( itemIndex, visArg ) \
		itemDef \
		{ \
			rect 					CHOICE_ORIGIN( itemIndex ) 216 0.5 1 1 \
			origin 					64 0 \
			style 					3 \
			foreColor 				1 1 1 1 \
			background 				"gradient_fadein" \
			textScale 				0.55 \
			visible 				when ( visArg ) \
			decoration 				\
		}

#define CHOICE_DEFAULT_CLASS( itemIndex, textArg, classArg ) \
		CHOICE_BUTTON_ALL( itemIndex, textArg, scriptmenuresponse classArg, UPDATE_DEFAULT_CLASS_FOCUS( itemIndex, textArg ), ;, 1, ; )
		
#define CHOICE_CUSTOM_CLASS( itemIndex, classArg ) \
		CHOICE_BUTTON_ALL( itemIndex, getplayerdata( "customClasses", ( itemIndex - 5 ), "name" ), scriptmenuresponse classArg, UPDATE_CLASS_FOCUS( itemIndex ), ;, 1, ; )

#define UPDATE_CAC_FOCUS \
		setLocalVarString "loadoutPrimaryAttachment2" ( "none" ); \
		setLocalVarString "loadoutSecondaryAttachment2" ( "none" ); \
		setLocalVarString "loadoutSecondaryCamo" ( "none" ); \
		setLocalVarString "loadoutStreak1" ( "none" ); \
		setLocalVarString "loadoutStreak2" ( "none" ); \
		setLocalVarString "loadoutStreak3" ( "none" ); \
		setLocalVarString "loadoutDeathStreak" ( "none" ); \
		setLocalVarString "loadoutPrimary" ( localVarString( "cacPrimary" ) ); \
		setLocalVarString "loadoutPrimaryAttachment" ( localVarString( "cacPrimaryAttachment" ) ); \
		setLocalVarString "loadoutPrimaryCamo" ( localVarString( "cacPrimaryCamo" ) ); \
		setLocalVarString "loadoutSecondary" ( localVarString( "cacSecondary" ) ); \
		setLocalVarString "loadoutSecondaryAttachment" ( localVarString( "cacSecondaryAttachment" ) ); \
		setLocalVarString "loadoutEquipment" ( localVarString( "cacEquipment" ) ); \
		setLocalVarString "loadoutPerk1" ( localVarString( "cacPerk1" ) ); \
		setLocalVarString "loadoutPerk2" ( localVarString( "cacPerk2" ) ); \
		setLocalVarString "loadoutPerk3" ( localVarString( "cacPerk3" ) ); \
		setLocalVarString "loadoutOffhandSecondary" ( localVarString( "cacOffhandSecondary" ) ); \
		setLocalVarString "loadoutClassName" ( "Created Class" );

#define UPDATE_CLASS_FOCUS( itemIndex ) \
		setLocalVarInt "classIndex" ( itemIndex - 5 ); \
		setLocalVarString "loadoutPrimary" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 0, "weapon" ) ); \
		setLocalVarString "loadoutPrimaryAttachment" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 0, "attachment", 0 ) ); \
		setLocalVarString "loadoutPrimaryAttachment2" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 0, "attachment", 1 ) ); \
		if ( localvarstring( "loadoutPrimaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutPrimaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutPrimaryCamo" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 0, "camo" ) ); \
		setLocalVarString "loadoutSecondary" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 1, "weapon" ) ); \
		setLocalVarString "loadoutSecondaryAttachment" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 1, "attachment", 0 ) ); \
		setLocalVarString "loadoutSecondaryAttachment2" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 1, "attachment", 1 ) ); \
		if ( localvarstring( "loadoutSecondaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutSecondaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutSecondaryCamo" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "weaponSetups", 1, "camo" ) ); \
		setLocalVarString "loadoutEquipment" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "perks", 0 ) ); \
		setLocalVarString "loadoutPerk1" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "perks", 1 ) ); \
		setLocalVarString "loadoutPerk2" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "perks", 2 ) ); \
		setLocalVarString "loadoutPerk3" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "perks", 3 ) ); \
		setLocalVarString "loadoutStreak1" ( getplayerdata( "killstreaks", 0 ) ); \
		setLocalVarString "loadoutStreak2" ( getplayerdata( "killstreaks", 1 ) ); \
		setLocalVarString "loadoutStreak3" ( getplayerdata( "killstreaks", 2 ) ); \
		setLocalVarString "loadoutDeathStreak" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "perks", 4 ) ); \
		setLocalVarString "loadoutOffhandSecondary" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "specialGrenade" ) ); \
		setLocalVarString "loadoutClassName" ( getplayerdata( "customClasses", localvarint( "classIndex" ), "name" ) );

#define UPDATE_DEFAULT_CLASS_FOCUS( itemIndex, textArg ) \
		setLocalVarString "loadoutPrimary" ( tablelookup( "mp/classTable.csv", 0, "loadoutPrimary", itemIndex + 1 ) ); \
		setLocalVarString "loadoutPrimaryAttachment" ( tablelookup( "mp/classTable.csv", 0, "loadoutPrimaryAttachment", itemIndex + 1 ) ); \
		setLocalVarString "loadoutPrimaryAttachment2" ( tablelookup( "mp/classTable.csv", 0, "loadoutPrimaryAttachment2", itemIndex + 1 ) ); \
		if ( localvarstring( "loadoutPrimaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutPrimaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutPrimaryCamo" ( tablelookup( "mp/classTable.csv", 0, "loadoutPrimaryCamo", itemIndex + 1 ) ); \
		setLocalVarString "loadoutSecondary" ( tablelookup( "mp/classTable.csv", 0, "loadoutSecondary", itemIndex + 1 ) ); \
		setLocalVarString "loadoutSecondaryAttachment" ( tablelookup( "mp/classTable.csv", 0, "loadoutSecondaryAttachment", itemIndex + 1 ) ); \
		setLocalVarString "loadoutSecondaryAttachment2" ( tablelookup( "mp/classTable.csv", 0, "loadoutSecondaryAttachment2", itemIndex + 1 ) ); \
		if ( localvarstring( "loadoutSecondaryAttachment2" ) == "" ) \
		{ \
			setLocalVarString "loadoutSecondaryAttachment2" ( "none" ); \
		} \
		setLocalVarString "loadoutSecondaryCamo" ( tablelookup( "mp/classTable.csv", 0, "loadoutSecondaryCamo", itemIndex + 1 ) ); \
		setLocalVarString "loadoutEquipment" ( tablelookup( "mp/classTable.csv", 0, "loadoutEquipment", itemIndex + 1 ) ); \
		setLocalVarString "loadoutPerk1" ( tablelookup( "mp/classTable.csv", 0, "loadoutPerk1", itemIndex + 1 ) ); \
		setLocalVarString "loadoutPerk2" ( tablelookup( "mp/classTable.csv", 0, "loadoutPerk2", itemIndex + 1 ) ); \
		setLocalVarString "loadoutPerk3" ( tablelookup( "mp/classTable.csv", 0, "loadoutPerk3", itemIndex + 1 ) ); \
		setLocalVarString "loadoutStreak1" ( tablelookup( "mp/classTable.csv", 0, "loadoutStreak1", itemIndex + 1 ) ); \
		setLocalVarString "loadoutStreak2" ( tablelookup( "mp/classTable.csv", 0, "loadoutStreak2", itemIndex + 1 ) ); \
		setLocalVarString "loadoutStreak3" ( tablelookup( "mp/classTable.csv", 0, "loadoutStreak3", itemIndex + 1 ) ); \
		setLocalVarString "loadoutDeathStreak" ( tablelookup( "mp/classTable.csv", 0, "loadoutDeathStreak", itemIndex + 1 ) ); \
		setLocalVarString "loadoutOffhandSecondary" ( tablelookup( "mp/classTable.csv", 0, "loadoutOffhand", itemIndex + 1 ) ); \
		setLocalVarString "loadoutClassName" ( textArg );