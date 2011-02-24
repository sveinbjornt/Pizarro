/*
 *  Constants.h
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/15/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */


// Game Info
#define kGameName				@"Pizarro"
#define	kGameVersion			1.0
#define kGameReleaseYear		2011
#define kGameDeveloper			@"Corrino Software"
#define kGameProgramming		@"Sveinbjorn Thordarson"
#define kGameGraphics			@"Magnus David Magnusson"

// High scores
#define kSavedHighscoreFilename		@"PizzaroLocalHighscore"
#define kSavedHighscorePlistKey		@"LocalHighscore"
#define kSavedGKScoreSuffix			@".pizarroScore"

// GAME CENTER

// leaderboards
#define kGameCenterScoreCategory	@"Pizarro_Phone_Score"
#define kGameCenterLevelCategory	@"Pizarro_Phone_Level"

// achievements
#define kGameCenterLevelInOneAchievement	@"Pizarro_Achievement_LevelInOne"


///// GAMEPLAY ///////

// Mana
#define kFullMana				10.0
#define kStartingMana			10.0
#define kManaPercentageLow		0.25
#define kManaPerLevel			(kFullMana/3) + (level * (kFullMana/45))

// Time
#define kStartingTime			60.0f
#define kTimePerLevel			15.0f
#define kTimeLow				20.0f

#define kSurfaceReqPerLevel		80.0f

// Shapes
#define kMinimumShapeSize					15
#define kNumShapeKinds						3
#define kCircleExpansionDiameterPerSecond	170.0f

// Limits
#define kMaxShapes				65535
#define kMaxTouches				4
#define kMaxBounceBalls			8

// PHYSICS ENGINE CONSTANTS

#define kWallThickness				20
#define kWallCollisionType			0
#define kWallElasticity				1.0f
#define kWallFriction				0.0f
#define kWallMass					INFINITY
#define kWallInertia				INFINITY
#define kWallShapeGroup				100


// Surface matrix

#define kMatrixWidth				45
#define kMatrixHeight				28
#define kMatrixUnitSize				10


// Game box

#define kGameBoxWidth				450
#define kGameBoxHeight				280

#define kGameBoxXOffset				26
#define kGameBoxYOffset				3

#define kGameScreenWidth			480
#define kGameScreenHeight			320

#define kGameScreenCenterPoint		CGPointMake([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2)
#define kGameBoxCenterPoint			CGPointMake(kGameBoxXOffset + (kGameBoxWidth/2), kGameBoxYOffset + (kGameBoxHeight/2)) 
#define kGameOverPoint				CGPointMake([[CCDirector sharedDirector] winSize].width/2, [[CCDirector sharedDirector] winSize].height * (float)5/9)

#define kGameBoxRect				CGRectMake(kGameBoxXOffset, kGameBoxYOffset, kGameBoxWidth, kGameBoxHeight)


// Font

#define kHUDFont					@"RedStateBlueState BB"
#define kMainMenuFont				@"RedStateBlueState BB"
#define kPercentageBlastFont		@"RedStateBlueState BB"
#define kGameOverBlastFont			@"RedStateBlueState BB"
#define kLevelBlastFont				@"RedStateBlueState BB"
#define kTutorialFont				@"RedStateBlueState BB"
#define kNoteBlastFont				@"Verdana"

#define kHUDFontSize				42
#define kLevelBlastFontSize			78
#define kPercentageBlastFontSize	64
#define kGameOverBlastFontSize		84
#define kMainMenuTitleFontSize		84
#define kMainMenuMenuFontSize		44
#define kSettingsFontSize			36
#define kResumeGameMenuFontSize		52
#define kNoteBlastFontSize			64

#define kWelcomeToPizarroFontSize	45
#define kTutorialFontSize			28

// Menu settings

#define kMainMenuBackgroundPoint	CGPointMake([[CCDirector sharedDirector] winSize].width/2, 65)
#define kMainMenuMenuPoint			CGPointMake([[CCDirector sharedDirector] winSize].width/2, 42)
#define kMainMenuIconPoint			CGPointMake(385, 220)
#define kMenuPauseButtonPoint		CGPointMake(36, 290)
#define kMainMenuFirstLetterPoint	CGPointMake(54, 190)
#define kMainMenuLetterSpacing		50
#define kMainMenuLetterShiftVector	CGPointMake(-20, 90)
#define kMainMenuScoresButtonPoint	CGPointMake(45, 320-35)
#define kResumeGameMenuPoint		CGPointMake(182, 180)

// Sprite files

#define kBouncingBallSprite	@"bouncingball.png"
#define kBouncingBallHilightSprite @"bouncingball_hilight.png"

#define kGameScreenBackgroundSprite @"bg.png"

#define kMainMenuBackgroundSprite @"mainscreen_bg.png"

#define kGameIconSprite @"mainscreen_icon.png"

#define kCheckBoxOnSprite	@"checkbox.png"
#define kCheckBoxOffSprite	@"checkbox-nocheck.png"

#define kManaBarRedSprite		@"manabar_red.png"
#define kManaBarRedTopSprite	@"manabar_red_top.png"
#define kManaBarGreenSprite		@"manabar_green.png"
#define kManaBarGreenTopSprite	@"manabar_green_top.png"

#define kInGameMenuButtonOffSprite	@"menu_button_black.png"
#define kInGameMenuButtonOnSprite	@"menu_button_white.png"

#define kCompanyLogoSprite	@"corrino_logo.png"

#define kTutorialCircleSprite @"tutorial_circle.png"

// Audio files

#define kTrumpetSoundEffect	@"trumpet.wav"

#define kNumBassLines		3
#define	kStartingBassLine	kNumBassLines

// Settings

#define kMusicEnabled		@"MusicEnabled"
#define kSoundEnabled		@"SoundEnabled"
#define kGameCenterEnabled	@"GameCenterEnabled"
#define kLastBassLine		@"LastBassLine"
#define kShowTutorial		@"ShowTutorial"

// Tutorial

#define kTutorialStepNone	0
#define kTutorialStep1		1
#define kTutorialStep2		2
#define kTutorialStep3		3
#define kTutorialStep4		4
#define kTutorialStep5		5
#define kTutorialStep6		6

// Colors

#define kBlackColor			ccc3(0,0,0)
#define kWhiteColor			ccc3(255,255,255)
#define kRedColor			ccc3(180,0,0)

// Convenience 

#define NOW					[NSDate timeIntervalSinceReferenceDate]
#define RETINA_DISPLAY		(CC_CONTENT_SCALE_FACTOR() == 2.0)
#define MUSIC_ENABLED		[[[NSUserDefaults standardUserDefaults] valueForKey: kMusicEnabled] boolValue]
#define SOUND_ENABLED		[[[NSUserDefaults standardUserDefaults] valueForKey: kSoundEnabled] boolValue]
#define GAMECENTER_ENABLED	[[[NSUserDefaults standardUserDefaults] valueForKey: kGameCenterEnabled] boolValue]
#define SHOW_TUTORIAL		[[[NSUserDefaults standardUserDefaults] valueForKey: kShowTutorial] boolValue]


