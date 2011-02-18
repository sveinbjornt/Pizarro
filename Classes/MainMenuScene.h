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

@interface MainMenuScene : CCLayerColor
{
	UITouch			*currTouch;
	NSMutableArray	*letters;
	
	CCSprite *bg1,	*bg2;
	
	MMLetterSprite	*icon;
	
	CCMenu			*menu;
	
	int				state;
	
	// Settings
	CCLabelTTF		*musicLabel, *soundLabel, *gameCenterLabel;
	CCMenu			*settingsMenu;
	
	
	// Credits
	CCLabelTTF		*creditsLabel;
	CCSprite		*creditsLogo;
	
	Instrument		*piano;
	
}

+(id)scene;

-(void)createMainMenu;
-(void)createBackground;
-(void)createLetterAndLogo;


-(void)showSettings;
-(void)hideSettings;

-(void)showCredits;
-(void)hideCredits;



-(void)shiftOut;
-(void)shiftIn;


@end
