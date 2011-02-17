//
//  MenuScene.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 1/20/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MainMenuScene.h"
#import "Constants.h"
#import "PizarroGameScene.h"
//#import "SettingsMenu.h"
//#import "CreditsMenu.h"
#import "Common.c"
#import "SimpleAudioEngine.h"

#define kAnimationInterval				1.0f / 2.0f
#define kBackgroundMovementInterval		1.0f / 20.0f

@implementation MainMenuScene

- (id)init
{
	if ((self = [super init])) 
	{
		self.isTouchEnabled = YES;
		
		[CCMenuItemFont setFontName: kHUDFont];
		[CCMenuItemFont setFontSize: kMainMenuMenuFontSize];

		CCMenuItemFont *menuItem1 = [CCMenuItemFont itemFromString:@"Play" target:self selector:@selector(onPlay:)];
		CCMenuItemFont *menuItem2 = [CCMenuItemFont itemFromString:@"Settings" target:self selector:@selector(onSettings:)];
		CCMenuItemFont *menuItem3 = [CCMenuItemFont itemFromString:@"Credits" target:self selector:@selector(onCredits:)];
		menuItem1.color = ccc3(0,0,0);
		menuItem2.color = ccc3(0,0,0);
		menuItem3.color = ccc3(0,0,0);
		
		menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
		[menu alignItemsHorizontallyWithPadding: 35.0f];
		[self addChild:menu z: 1000];
		menu.position = kMainMenuMenuPoint;
		
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
			MMLetterSprite *n = [MMLetterSprite spriteWithFile: [NSString stringWithFormat: @"n%d.png", i+1]];
			CGPoint pos = kMainMenuFirstLetterPoint;
			pos.x += kMainMenuLetterSpacing * i;
			n.position = pos;
			[letters addObject: n];
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
		if (child == bg1 || child == bg2 || child == menu)
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
	
	
	[[CCDirector sharedDirector] replaceScene: [CCTransitionMoveInR	 transitionWithDuration: 0.7 scene: [PizarroGameScene scene]]];
}

- (void)onSettings:(id)sender
{
	NSLog(@"on settings");
	//[[Director sharedDirector] replaceScene:[SettingsScene node]];
	//	[[CCDirector sharedDirector] pushScene:[SettingsMenu scene]];
}

- (void)onCredits:(id)sender
{
	NSLog(@"on about");
//	[[CCDirector sharedDirector] pushScene:[CreditsMenu scene]];
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (currTouch != nil)
		return;
	
    currTouch = [touches anyObject];
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	NSLog(@"Touch began");
	
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			NSLog(@"Hit letter");
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.5]];
			[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", i+1] pitch:1.0f pan:0.0f gain:0.3f];
		}
		else
		{
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.0]];
		}

	}
	
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (currTouch == nil)
		return;
	
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			NSLog(@"Hit letter");
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.5]];
			[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", i+1] pitch:1.0f pan:0.0f gain:0.3f];
		}
		else
		{
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.0]];
		}
		
	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSLog(@"Touch ended");
	currTouch = nil;
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.0]];
	}
	
}



@end
