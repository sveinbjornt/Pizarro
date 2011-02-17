//
//  MenuScene.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 1/20/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MainMenuScene.h"
#import "Constants.h"
//#import "SettingsMenu.h"
//#import "CreditsMenu.h"
#import "Common.c"


#define kAnimationInterval				1.0f / 2.0f
#define kBackgroundMovementInterval		1.0f / 20.0f

@implementation MainMenuScene

- (id)init
{
	if ((self = [super init])) 
	{
		//		CCMenuItem *menuItem1 = [CCMenuItemFont itemFromString:@"New Game" target:self selector:@selector(onPlay:)];
		//		CCMenuItem *menuItem2 = [CCMenuItemFont itemFromString:@"How To Play" target:self selector:@selector(onTutorial:)];
		//		CCMenuItem *menuItem3 = [CCMenuItemFont itemFromString:@"Settings" target:self selector:@selector(onSettings:)];
		//		CCMenuItem *menuItem4 = [CCMenuItemFont itemFromString:@"High Scores" target:self selector:@selector(onHighScores:)];
		//		CCMenuItem *menuItem5 = [CCMenuItemFont itemFromString:@"Credits" target:self selector:@selector(onCredits:)];
		//		
		//		CCMenu *menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, nil];
		//		[menu alignItemsVertically];
		//		[self addChild:menu];
		
		bg1 = [CCSprite spriteWithFile: @"mainscreen_bg.png"];
		bg1.position = kMainMenuBackgroundPoint;
		[self addChild: bg1];
		
		bg2 = [CCSprite spriteWithFile: @"mainscreen_bg.png"];
		CGPoint p = kMainMenuBackgroundPoint;
		p.x += kGameScreenWidth;
		bg2.position = p;
		[self addChild: bg2];
		
		icon = [CCSprite spriteWithFile: @"mainscreen_icon.png"];
		icon.position = kMainMenuIconPoint;
		[self addChild: icon];
		
		letters = [[NSMutableArray alloc] initWithCapacity: kNumNameLetters];
		for (int i = 0; i < kNumNameLetters; i++)
		{
			NSString *imgName = [NSString stringWithFormat: @"n%d.png", i+1];
			NSLog(imgName);
			CCSprite *n = [CCSprite spriteWithFile: imgName];
			CGPoint pos = kMainMenuFirstLetterPoint;
			pos.x += kMainMenuLetterSpacing * i;
			n.position = pos;
			
			[self addChild: n];
		}
		
		
		[self schedule: @selector(tick:) interval: kAnimationInterval];
		[self schedule: @selector(bgMovetick:) interval: kBackgroundMovementInterval];
	}
	return self;
}

+(id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuScene *layer = [MainMenuScene node];
	layer.color = ccc3(0,0,0);
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark -

-(void)tick: (ccTime)dt
{
	for (CCNode *child in self.children)
	{
		if (child == bg1 || child == bg2)
			continue; 
		
		CGPoint moveVector = CGPointMake(RandomBetween(-1, 1), RandomBetween(-1, 1));
		float angle = RandomBetween(-1, 1);
		
		[child runAction: [CCMoveBy actionWithDuration: kAnimationInterval position: moveVector]];
		[child runAction: [CCRotateBy actionWithDuration: kAnimationInterval angle: angle]];
	}
}

-(void)bgMovetick: (ccTime)dt
{
	
	
	
	
	CGPoint bgCenterPt = kMainMenuBackgroundPoint;
	if (bg1.position.x == bgCenterPt.x - kGameScreenWidth)
	{
		bgCenterPt.x += kGameScreenWidth;
		bg1.position = bgCenterPt;
	}
	else
	{
		CGPoint bg1Pt = bg1.position;
		bg1Pt.x -= 1;
		bg1.position = bg1Pt;
	}

	
	bgCenterPt = kMainMenuBackgroundPoint;
	if (bg2.position.x == bgCenterPt.x - kGameScreenWidth)
	{
		bgCenterPt.x += kGameScreenWidth;
		bg2.position = bgCenterPt;
	}
	else
	{
		CGPoint bg2Pt = bg2.position;
		bg2Pt.x -= 1;
		bg2.position = bg2Pt;
	}

}

- (void)onPlay:(id)sender
{
	NSLog(@"on play");
	//	[[CCDirector sharedDirector] replaceScene: [CCTransitionFlipX transitionWithDuration: kSceneTransitionDuration scene: [AcheronGameScene scene]]];
}

- (void)onSettings:(id)sender
{
	NSLog(@"on settings");
	//[[Director sharedDirector] replaceScene:[SettingsScene node]];
	//	[[CCDirector sharedDirector] pushScene:[SettingsMenu scene]];
}

- (void)onTutorial:(id)sender
{
	
}

- (void)onHighScores:(id)sender
{
//	[[GameCenterManager sharedManager] authenticateLocalUserForLeaderboard];
}

- (void)onCredits:(id)sender
{
	NSLog(@"on about");
//	[[CCDirector sharedDirector] pushScene:[CreditsMenu scene]];
}


@end
