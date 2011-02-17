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
		
		// Menu at bottom
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
		
		
		// Moving background
		bg1 = [CCSprite spriteWithFile: @"mainscreen_bg.png"];
		bg1.position = kMainMenuBackgroundPoint;
		[self addChild: bg1];
//		[bg1 runAction: [CCRepeatForever actionWithAction: [CCMoveBy actionWithDuration: 0.05 position: ccp(-1,0)]]];
		
		bg2 = [CCSprite spriteWithFile: @"mainscreen_bg.png"];
		CGPoint p = kMainMenuBackgroundPoint;
		p.x += kGameScreenWidth;
		bg2.position = p;
		[self addChild: bg2];
//		[bg2 runAction: [CCRepeatForever actionWithAction: [CCMoveBy actionWithDuration: 0.05 position: ccp(-1,0)]]];
		
		
		// Shifting letters and icon
		letters = [[NSMutableArray alloc] initWithCapacity: kNumNameLetters];
		for (int i = 0; i < kNumNameLetters; i++)
		{
			MMLetterSprite *n = [MMLetterSprite spriteWithFile: [NSString stringWithFormat: @"n%d.png", i+1]];
			CGPoint pos = kMainMenuFirstLetterPoint;
			pos.x += kMainMenuLetterSpacing * i;
			n.position = pos;
			n.originalPosition = pos;
			[letters addObject: n];
			[self addChild: n];
		}
		
		icon = [MMLetterSprite spriteWithFile: @"mainscreen_icon.png"];
		icon.position = kMainMenuIconPoint;
		icon.originalPosition = kMainMenuIconPoint;
		[self addChild: icon];
		[letters addObject: icon];
		
		
		// Tickers
		[self schedule: @selector(tick:) interval: kAnimationInterval];
		[self schedule: @selector(bgMovetick:) interval: kBackgroundMovementInterval];
		
		
		// Background music
		//[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"mainmenu_music.mp3"];
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
	for (MMLetterSprite *letter in letters)
	{	
		if ([letter numberOfRunningActions] != 0)
			continue;
		
		CGPoint moveVector = CGPointMake(RandomBetween(-1, 1), RandomBetween(-1, 1));
		float angle = RandomBetween(-1, 1);
		
		// Make sure we don't rotate too far
		if (letter.rotation > 15)
			angle = -1;
		if (letter.rotation < -15)
			angle = 1;
		
		if (ccpDistance(letter.originalPosition, letter.position) > 7)
		{
			CGPoint mVec = ccpSub(letter.originalPosition, letter.position);			
			mVec.x /= 4;
			mVec.y /= 4;
			moveVector = mVec;
		}
		
		[letter runAction: [CCMoveBy actionWithDuration: kAnimationInterval position: moveVector]];
		[letter runAction: [CCRotateBy actionWithDuration: kAnimationInterval angle: angle]];
	}
}

-(void)bgMovetick: (ccTime)dt
{
	float y = bg1.position.y;
	
	CGPoint bgCenterPt = kMainMenuBackgroundPoint;
	if (bg1.position.x == bgCenterPt.x - kGameScreenWidth)
	{
		bgCenterPt.y = y;
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
		bgCenterPt.y = y;
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
	state = kCreditsState;
	
	[self shiftOut];
	[self showCredits];
	
//	[[CCDirector sharedDirector] pushScene:[CreditsMenu scene]];
}

-(void)shiftOut
{
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		
		CGPoint p = kMainMenuLetterShiftVector;
		p.x -= i * 13;
		CGPoint dest = ccpAdd(letter.originalPosition, p);
		
		[letter stopAllActions];
		[letter runAction: [CCMoveBy actionWithDuration: 0.3 position: p]];
		[letter runAction: [CCScaleTo actionWithDuration: 0.3 scale: 0.8]];
		letter.originalPosition = dest;
		//[letter runAction: [CCRepeatForever actionWithAction: [CCDelayTime actionWithDuration: 1.0]]];
	}
		
	[bg1 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,-130)]];
	[bg2 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,-130)]];
	[menu runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,-130)]];
}

-(void)shiftIn
{
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		
		CGPoint p = kMainMenuLetterShiftVector;
		p.x = (-1) * p.x;
		p.y = (-1) * p.y;
		p.x += i * 13;
		CGPoint dest = ccpAdd(letter.originalPosition, p);
		
		[letter stopAllActions];
		[letter runAction: [CCMoveBy actionWithDuration: 0.3 position: p]];
		[letter runAction: [CCScaleTo actionWithDuration: 0.3 scale: 1.0]];
		letter.originalPosition = dest;
		//[letter runAction: [CCRepeatForever actionWithAction: [CCDelayTime actionWithDuration: 1.0]]];
	}
		
	[bg1 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
	[bg2 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
	[menu runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
}

#pragma mark -

-(void)showSettings
{
	
}

#pragma mark -

-(void)showCredits
{
	creditsLogo = [CCSprite spriteWithFile: @"corrino_logo.png"];
	creditsLogo.position = ccp(-185, 205);
	[self addChild: creditsLogo];
	[creditsLogo runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(40, 205)]];
	
	NSString *credits = @"A\nCORRINO SOFTWARE\nGAME\n\nCREATED BY\nSVEINBJORN THORDARSON & MAGNUS DAVID MAGNUSSON";
	
	creditsLabel = [CCLabelTTF labelWithString: credits dimensions:CGSizeMake(390,225) alignment: UITextAlignmentCenter fontName: kHUDFont fontSize: 32];
	creditsLabel.position = ccp(-185, 140);
	[self addChild: creditsLabel];
	[creditsLabel runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(205, 140)]];
}

-(void)hideCredits
{
	[creditsLogo runAction: [CCSequence actions: [CCMoveBy actionWithDuration: 0.3 position: ccp(-185, 0)],
							 [CCCallFunc actionWithTarget: creditsLogo selector: @selector(dispose)], nil]];
	[creditsLabel runAction: [CCSequence actions: [CCMoveBy actionWithDuration: 0.3 position: ccp(-185, 0)],
							 [CCCallFunc actionWithTarget: creditsLabel selector: @selector(dispose)], nil]];
	
}

#pragma mark -

-(void)playTrumpet
{
	float pitches[] = { 1.0, 0.891, 0.75 };
	float pitch =  pitches[RandomBetween(0, 2)];
	[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch: pitch pan:0.0f gain:0.3f];
	
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (currTouch != nil)
		return;
	
	float scaleNormal = 1.0, scaleLarge = 1.5; 
	if (state != kMainState)
	{
		scaleNormal = 0.8;
		scaleLarge = 1.2;
	}
	
    currTouch = [touches anyObject];
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	BOOL playedNote = NO;
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			NSLog(@"Hit letter");
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: scaleLarge]];
			[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", i+1] pitch:1.0f pan:0.0f gain:0.3f];
			playedNote = YES;
		}
		else
		{
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: scaleNormal]];
		}

	}
	
	if (!playedNote && CGRectContainsPoint([icon rect], location))
	{
		[icon runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.2]];
		[self playTrumpet];
		playedNote = YES;
	}
	
	if (!playedNote)
	{
		switch (state)
		{
			case kCreditsState:
				[self shiftIn];
				[self hideCredits];
				state = kMainState;
				break;
			
			case kSettingsState:
				[self shiftIn];
				[self hideSettings];
				state = kSettingsState;
				break;
		}
	}
	
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (currTouch == nil)
		return;
	
	float scaleNormal = 1.0, scaleLarge = 1.5; 
	if (state != kMainState)
	{
		scaleNormal = 0.8;
		scaleLarge = 1.2;
	}
	
	
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	BOOL playedNote = NO;
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			NSLog(@"Hit letter");
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: scaleLarge]];
			[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", i+1] pitch:1.0f pan:0.0f gain:0.3f];
			playedNote = YES;
		}
		else
		{
			[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: scaleNormal]];
		}
		
	}
	
	if (!playedNote && CGRectContainsPoint([icon rect], location))
	{
		[icon runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.2]];
		[self playTrumpet];
		playedNote = YES;
	}
		
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSLog(@"Touch ended");
	currTouch = nil;
	
	float scaleNormal = 1.0, scaleLarge = 1.5; 
	if (state != kMainState)
	{
		scaleNormal = 0.8;
		scaleLarge = 1.2;
	}
	
	for (int i = 0; i < kNumNameLetters; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		[letter runAction: [CCScaleTo actionWithDuration: 0.1 scale: scaleNormal]];
	}
	[icon runAction: [CCScaleTo actionWithDuration: 0.1 scale: 1.0]];
	
}



@end
