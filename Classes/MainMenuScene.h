//
//  MainMenuScene.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MMLetterSprite.h"
#import "MMLetterLabel.h"
#import "ExpandingMenuItemToggle.h"
#import "Instrument.h"


#define kMainState		0
#define kCreditsState	1
#define kSettingsState	2
#define kGameModeState	3

@interface MainMenuScene : CCLayerColor
{
	UITouch			*currTouch;
	NSMutableArray	*letters;
	NSMutableArray	*scoreLetters;
	
	CCSprite *bg1,	*bg2;
	
	MMLetterSprite	*icon;
	
	CCMenu			*menu, *scoresMenu, *settingsMenu, *resumeMenu;
	
	int				state;
	
	// Free version ad for full version
#if IAD_ENABLED == 1
	CCMenu			*getFullVersionMenu;
#endif
	
	// Settings
	CCLabelTTF		*musicLabel, *soundLabel, *gameCenterLabel;
	CCMenu			*tutorialMenu;
	
	// Credits
	MMLetterLabel	*creditsLabel, *createdByLabel;
	CCSprite		*creditsLogo;
	
	// Game mode
	CCLabelTTF		*singlePlayerMenu, *multiPlayerMenu;
	
	Instrument		*piano;
	
	BOOL			inTransition, paused;
	
	CCScene			*pausedScene;
	
}
@property (readwrite,assign) BOOL paused;
@property (readwrite,assign) CCScene *pausedScene;

+(id)scene;
+(id)scenePausedForScene: (CCScene *)gameScene;
-(id)initWithPause: (BOOL)p;

-(void)createMainMenu;
-(void)createBackground;
-(void)createLetterAndLogo;

-(void)startGame:(BOOL)multiPlayer;

-(void)showGameModeSelection;
-(void)hideGameModeSelection;

-(void)showSettings;
-(void)hideSettings;

-(void)showCredits;
-(void)hideCredits;

-(void)showPausedMenu;

-(void)shiftOutWithDuration: (NSTimeInterval)duration;
-(void)shiftOut;
-(void)shiftInWithDuration: (NSTimeInterval)duration;
-(void)shiftIn;



@end
