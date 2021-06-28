/*
 *  Constants.h
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/15/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */


// Game Info
#define kGameName               @ "PIZARRO"
#define kGameVersion            1.1
#define kGameReleaseYear        2011
#define kGameDeveloper          @ "Corrino Software"
#define kGameProgramming        @ "Sveinbjorn Thordarson"
#define kGameGraphics           @ "Magnus David Magnusson"
#define kGameDeveloperWebsite   @ "http://www.corrino-software.com"
#define kGameFullVersionURL     @ "http://itunes.apple.com/app/pizarro/id421359392?mt=8"

// High scores
#define kSavedHighscoreFilename     @ "PizzaroLocalHighscore"
#define kSavedHighscorePlistKey     @ "LocalHighscore"
#define kSavedGKScoreSuffix         @ ".pizarroScore"
#define kSavedGKAchievementSuffix   @ ".pizarroAchievement"

// GAME CENTER

// leaderboards

#define kGameCenterScoreCategory        @ "Pizarro_Phone_Score"
#define kGameCenterLevelCategory        @ "Pizarro_Phone_Level"

#define kGameCenter_IPAD_ScoreCategory  @ "Pizarro_Pad_Score"
#define kGameCenter_IPAD_LevelCategory  @ "Pizarro_Pad_Level"

#define kGameCenterScoreCategoryFree    @ "PizarroFreePhoneScore"
#define kGameCenterLevelCategoryFree    @ "PizarroFreePhoneLevel"

#define kGameCenter_IPAD_ScoreCategoryFree  @ "PizarroFreePhoneScore"
#define kGameCenter_IPAD_LevelCategoryFree  @ "PizarroFreePhoneLevel"


// achievements

#define kGameCenterLevelInOneAchievement    @ "Pizarro_Achievement_LevelInOne"
#define kGameCenterLevelInTwoAchievement    @ "Pizarro_Achievement_LevelInTwo"
#define kGameCenterLevelInThreeAchievement  @ "Pizarro_Achievement_LevelInThree"

#define kGameCenterLevel5Achievement    @ "Pizarro_Achievement_Level5"
#define kGameCenterLevel10Achievement   @ "Pizarro_Achievement_Level10"
#define kGameCenterLevel15Achievement   @ "Pizarro_Achievement_Level15"
#define kGameCenterLevel20Achievement   @ "Pizarro_Achievement_Level20"
#define kGameCenterLevel25Achievement   @ "Pizarro_Achievement_Level25"
#define kGameCenterLevel30Achievement   @ "Pizarro_Achievement_Level30"

#define kGameCenterMinorPentatonicAchievement   @ "Pizarro_Achievement_MinorPentatonic"
#define kGameCenterOverkillAchievement          @ "Pizarro_Achievement_Overkill"
#define kGameCenterTouchmasterAchievement       @ "Pizarro_Achievement_Touchmaster"
#define kGameCenterFlawlessAchievement          @ "Pizarro_Achievement_Flawless"

///// GAMEPLAY ///////

// Mana

#define kFullMana               10.0f
#define kSurfaceReqPerLevel     80.0f
#define kStartingTime           60.0f

#define kManaPerLevel           (kFullMana / 3) + (level * (kFullMana / 60))

#define kTimePerLevel           15.0f
#define kTimeLow                15.0f
#define kManaPercentageLow      0.30

// Time


// Shapes
#define kMinimumShapeSize                   15
#define kNumShapeKinds                      3
#define kCircleExpansionDiameterPerSecond   170.0f

// Limits
#define kMaxShapes              65535
#define kMaxTouches             4
#define kMaxBounceBalls         8

// PHYSICS ENGINE CONSTANTS

#define kWallThickness              20
#define kWallCollisionType          0
#define kWallElasticity             1.0f
#define kWallFriction               0.0f
#define kWallMass                   INFINITY
#define kWallInertia                INFINITY
#define kWallShapeGroup             100
#define kPhysicalBoxOffset          4


// Surface matrix
#define kMatrixUnitSize             10


// Game box

#define kGameScreenWidth            [[CCDirector sharedDirector] winSize].width
#define kGameScreenHeight           [[CCDirector sharedDirector] winSize].height

#define kGameScreenCenterPoint      CGPointMake([[CCDirector sharedDirector] winSize].width / 2, [[CCDirector sharedDirector] winSize].height / 2)
#define kGameBoxCenterPoint         CGPointMake([GParams gameBoxXOffset: multiPlayer] + ([GParams gameBoxWidth: multiPlayer] / 2), [GParams gameBoxYOffset: multiPlayer] + ([GParams gameBoxHeight: multiPlayer] / 2))
#define kGameOverPoint              CGPointMake([[CCDirector sharedDirector] winSize].width / 2, [[CCDirector sharedDirector] winSize].height * (float)5 / 9)

#define kGameBoxRect                CGRectMake([GParams gameBoxXOffset: multiPlayer], [GParams gameBoxYOffset: multiPlayer], [GParams gameBoxWidth: multiPlayer], [GParams gameBoxHeight: multiPlayer])


// Font

#define kHUDFont                    @ "RedStateBlueState BB"
#define kMainMenuFont               @ "RedStateBlueState BB"
#define kPercentageBlastFont        @ "RedStateBlueState BB"
#define kGameOverBlastFont          @ "RedStateBlueState BB"
#define kLevelBlastFont             @ "RedStateBlueState BB"
#define kTutorialFont               @ "RedStateBlueState BB"
#define kNoteBlastFont              @ "Verdana"

#define kHUDFontSize                42
#define kLevelBlastFontSize         78
#define kLevelLabelFontSize         17
#define kPercentageBlastFontSize    64
#define kGameOverBlastFontSize      84
#define kMainMenuTitleFontSize      84
#define kMainMenuMenuFontSize       44
#define kSettingsFontSize           36
#define kResumeGameMenuFontSize     52
#define kGameModeMenuFontSize       52
#define kNoteBlastFontSize          64

#define kWelcomeToPizarroFontSize   45
#define kTutorialFontSize           28
#define kEnjoyPizarroFontSize       52


// Sprite files

#define kBouncingBallSprite         @ "bouncingball"
#define kBouncingBallHilightSprite  @ "bouncingball_hilight"

#define kGameScreenBackgroundSprite @ "bg"

#define kMainMenuBackgroundSprite   @ "mainscreen_bg"

#define kGameIconSprite             @ "mainscreen_icon"

#define kCheckBoxOnSprite           @ "checkbox"
#define kCheckBoxOffSprite          @ "checkbox-nocheck"

#define kManaBarRedSprite           @ "manabar_red"
#define kManaBarRedTopSprite        @ "manabar_red_top"
#define kManaBarGreenSprite         @ "manabar_green"
#define kManaBarGreenTopSprite      @ "manabar_green_top"

#define kInGameMenuButtonOffSprite  @ "menu_button_black"
#define kInGameMenuButtonOnSprite   @ "menu_button_white"

#define kTutorialButtonOffSprite    @ "tutorial_button_white"
#define kTutorialButtonOnSprite     @ "tutorial_button_black"

#define kScoresButtonOffSprite      @ "scores_button_off"
#define kScoresButtonOnSprite       @ "scores_button_on"

#define kCompanyLogoSprite          @ "corrino_logo"

#define kTutorialCircleSprite       @ "tutorial_circle"

#define kManSilhouetteSprite        @ "mode_silhouette"

#define kGameScreenMultiplayerBackgroundSprite      @ "bg-twoplayer"

// Audio and music files

#define kMainMenuMusicFile      @ "mainmenu_music.mp3"
#define kTrumpetSoundEffect     @ "trumpet.wav"
#define kBassSoundEffect        @ "bass.wav"

#define kNumBassLines           4
#define kStartingBassLine       kNumBassLines

// Multiplayer

#define kSinglePlayer           0
#define kPlayer1                1
#define kPlayer2                2

// Settings

#define kMusicEnabled           @ "MusicEnabled"
#define kSoundEnabled           @ "SoundEnabled"
#define kGameCenterEnabled      @ "GameCenterEnabled"
#define kLastBassLine           @ "LastBassLine"
#define kShowTutorial           @ "ShowTutorial"
#define kShowAdForFullVersion   @ "ShowFullVersionAd"

// Tutorial

#define kTutorialStepNone   0
#define kTutorialStep1      1
#define kTutorialStep2      2
#define kTutorialStep3      3
#define kTutorialStep4      4
#define kTutorialStep5      5
#define kTutorialStep6      6

// Colors

#define kBlackColor         ccc3(0, 0, 0)
#define kWhiteColor         ccc3(255, 255, 255)
#define kRedColor           ccc3(180, 0, 0)

// Convenience

#define NOW                 [NSDate timeIntervalSinceReferenceDate]
#define RETINA_DISPLAY      (CC_CONTENT_SCALE_FACTOR() == 2.0)
#define MUSIC_ENABLED       [[[NSUserDefaults standardUserDefaults] valueForKey : kMusicEnabled] boolValue]
#define SOUND_ENABLED       [[[NSUserDefaults standardUserDefaults] valueForKey : kSoundEnabled] boolValue]
#define GAMECENTER_ENABLED  [[[NSUserDefaults standardUserDefaults] valueForKey : kGameCenterEnabled] boolValue]
#define SHOW_TUTORIAL       [[[NSUserDefaults standardUserDefaults] valueForKey : kShowTutorial] boolValue]
#define SHOW_FULLVERSION_AD [[[NSUserDefaults standardUserDefaults] valueForKey : kShowAdForFullVersion] boolValue]

#define IPAD                UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
