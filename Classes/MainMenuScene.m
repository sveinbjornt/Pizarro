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
#import "Common.c"
#import "SimpleAudioEngine.h"
#import "Instrument.h"

#define kAnimationInterval					1.0f / 2.0f
#define kBackgroundMovementInterval		1.0f / 20.0f

#pragma mark -

@implementation MainMenuScene
@synthesize pausedScene, paused;

-(void)dealloc
{
	[letters release];
	[piano release];
	[super dealloc];
}

+(id)scene
{
	CCScene *scene = [CCScene node];	
	
	MainMenuScene *layer = [[MainMenuScene alloc] initWithPause: NO];
	layer.color = ccc3(0,0,0);

	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id)scenePausedForScene: (CCScene *)gameScene;
{
	CCScene *scene = [CCScene node];	

	MainMenuScene *layer = [[MainMenuScene alloc] initWithPause: YES];
	layer.color = ccc3(0,0,0);
	layer.pausedScene = gameScene;
	
	[scene addChild: layer];
	
	return scene;
}

- (id)initWithPause: (BOOL)p
{
	if ((self = [super init])) 
	{
		self.isTouchEnabled = YES;
		self.paused = p;
		
		// Create and set up all sprite objects and menus
		[self createMainMenu];
		[self createBackground];
		[self createLetterAndLogo];
		
		// Tickers
		[self schedule: @selector(tick:) interval: kAnimationInterval];
		[self schedule: @selector(bgMovetick:) interval: kBackgroundMovementInterval];
		
		// Background music
		if (!paused)
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"mainmenu_music.mp3"];
		
		// Create instrument
		piano = [[Instrument alloc] initWithName: @"piano" numberOfNotes: 7 tempo: 0.07];
		piano.delegate = self;
		piano.selector = @selector(notePressed:);
		
		if (!paused)
			[self shiftInWithDuration: 0.3f];
		else
			[self showPausedMenu];

		//
		//[piano playSequence: @"1,2, ,3,4, ,5,6,7"];
		
		//[piano playSequence: @"7, , ,7, ,6, ,5, ,4, , , , ,3, , ,2, , ,1, , ,2, ,1, ,2, ,1"];
		
		//[piano playSequence: @"7, ,6,5, ,4,3, ,2,1, ,2,1, ,2,1, ,3,4"];
	}
	return self;
}

#pragma mark -
#pragma mark Set up menu scene

-(void)createMainMenu
{
	// Menu at bottom
	[CCMenuItemFont setFontName: kMainMenuFont];
	[CCMenuItemFont setFontSize: kMainMenuMenuFontSize];
	
	//NSString *playStr = paused ? @"New Game" : @"Play";
	
	CCMenuItemFont *menuItem1 = [CCMenuItemFont itemFromString: @"Play" target:self selector:@selector(onPlay:)];
	CCMenuItemFont *menuItem2 = [CCMenuItemFont itemFromString: @"Settings" target:self selector:@selector(onSettings:)];
	CCMenuItemFont *menuItem3 = [CCMenuItemFont itemFromString: @"Credits" target:self selector:@selector(onCredits:)];
	menuItem1.color = ccc3(0,0,0);
	menuItem2.color = ccc3(0,0,0);
	menuItem3.color = ccc3(0,0,0);
	
	menu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
	[menu alignItemsHorizontallyWithPadding: 35.0f];
	[self addChild:menu z: 1000];
	
//	if (paused)
//		menu.position = kMainMenuMenuPoint;
//	else
		menu.position = ccpAdd(kMainMenuMenuPoint, ccp(0,-130));
	
	CCMenuItemSprite *scoresMenuItem = [CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"scores_button.png"] 
															   selectedSprite: [CCSprite spriteWithFile: @"scores_button.png"]
																	   target: [[UIApplication sharedApplication] delegate] 
																	 selector: @selector(loadLeaderboard)];
	if (!paused)
	{
		scoresMenu = [CCMenu menuWithItems: scoresMenuItem, nil];
		scoresMenu.position = ccp(-45,320+35);
		[self addChild: scoresMenu];
	}
}

-(void)createBackground
{
	// Moving background
	bg1 = [CCSprite spriteWithFile: kMainMenuBackgroundSprite];
//	if (paused)
//		bg1.position = kMainMenuBackgroundPoint;
//	else
		bg1.position = ccpAdd(kMainMenuBackgroundPoint, ccp(0,-130));
	[self addChild: bg1];

	bg2 = [CCSprite spriteWithFile: kMainMenuBackgroundSprite];
	CGPoint p = kMainMenuBackgroundPoint;
	p.x += kGameScreenWidth;
//	if (paused)
//		bg2.position = p;
//	else
		bg2.position = ccpAdd(p, ccp(0,-130));
	[self addChild: bg2];
}

-(void)createLetterAndLogo
{
	// Shifting letters and icon
	letters = [[NSMutableArray alloc] initWithCapacity: [kGameName length]];
	for (int i = 0; i < [kGameName length]; i++)
	{
		NSString *letter = [NSString stringWithFormat: @"%c", [kGameName characterAtIndex: i]];
		MMLetterLabel *n = [MMLetterLabel labelWithString: letter fontName: kMainMenuFont fontSize: kMainMenuTitleFontSize];
		
		
		
		
//		MMLetterSprite *n = [MMLetterSprite spriteWithFile: [NSString stringWithFormat: @"n%d.png", i+1]];
		CGPoint pos = kMainMenuFirstLetterPoint;
		pos.x += kMainMenuLetterSpacing * i;
		
		CGPoint p = kMainMenuLetterShiftVector;
		p.x -= i * 13;
		CGPoint dest = ccpAdd(pos, p);
		
		n.position = dest;
		n.originalPosition = dest;
		
		[letters addObject: n];
		[self addChild: n];
	}
	
	icon = [MMLetterSprite spriteWithFile: kGameIconSprite];
	icon.position = kMainMenuIconPoint;
	icon.originalPosition = kMainMenuIconPoint;
	[self addChild: icon];
	[letters addObject: icon];
	
}

#pragma mark -
#pragma mark Timers

-(void)tick: (ccTime)dt
{
	for (MMLetterLabel *letter in letters)
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

#pragma mark -
#pragma mark Main menu button actions

-(void)onPlay:(id)sender
{	
	if (inTransition)
		return;
	
	inTransition = YES;
	
	//[piano playSequence: @"7, ,1,3,4,3,4,3"];
	[self performSelector: @selector(trumpetPressed) withObject: nil afterDelay: 0.63];
	
	if (paused)
	{
		[pausedScene cleanup];
		
		// tell CCDirector to remove GameScene from the stack
		[[CCDirector sharedDirector] removeSceneFromStack: pausedScene];		
	}
	
	[self runAction: [CCSequence actions:
					  
					  [CCCallFunc actionWithTarget: self selector: @selector(shiftOut)],
					  //[CCDelayTime actionWithDuration: 0.15],
					  [CCCallFuncO actionWithTarget: [CCDirector sharedDirector] 
										   selector: @selector(replaceScene:) 
											 object: [CCTransitionSlideInR transitionWithDuration: 0.35 scene: [PizarroGameScene scene]]],
					  nil]];
}

-(void)onSettings:(id)sender
{
	if (inTransition)
		return;
	
	inTransition = YES;
	state = kSettingsState;
	
	[piano playSequence: @"1,3,2,4,3,5,7"];
	
	[self performSelector: @selector(trumpetPressed) withObject: nil afterDelay: 0.5];
	[self shiftOut];
	[self showSettings];	
}

-(void)onCredits:(id)sender
{
	if (inTransition)
		return;
	
	inTransition = YES;
	state = kCreditsState;
		
	[piano playSequence: @"1,2,3,4,5,6,7"];

	[self performSelector: @selector(trumpetPressed) withObject: nil afterDelay: 0.5];
	[self shiftOut];
	[self showCredits];	
}

-(void)onResume:(id)sender
{
	if (inTransition)
		return;
	
	inTransition = YES;
	[self performSelector: @selector(trumpetPressed) withObject: nil afterDelay: 0.3];
	[self shiftOut];
	[[CCDirector sharedDirector] popSceneWithTransition: [CCTransitionSlideInR class] duration: 0.35f];
}

#pragma mark -
#pragma mark Shift In/Out transitions

-(void)shiftOutWithDuration: (NSTimeInterval)duration
{
	inTransition = YES;
	
	if (!paused)
	{
		for (int i = 0; i < [kGameName length]; i++)
		{
			MMLetterLabel *letter = [letters objectAtIndex: i];
			
			CGPoint p = kMainMenuLetterShiftVector;
			p.x -= i * 13;
			CGPoint dest = ccpAdd(letter.originalPosition, p);
			
			[letter stopAllActions];
			[letter runAction: [CCMoveBy actionWithDuration: duration position: p]];
			[letter runAction: [CCScaleTo actionWithDuration: duration scale: 0.8]];
			letter.originalPosition = dest;
			//[letter runAction: [CCRepeatForever actionWithAction: [CCDelayTime actionWithDuration: 1.0]]];
		}
		[scoresMenu runAction: [CCMoveTo actionWithDuration: duration position: ccp(-45,480+35)]];
	}
	else
	{
		[resumeMenu runAction: [CCFadeOut actionWithDuration: 0.25]];
	}

	
	[bg1 runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,-130)]];
	[bg2 runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,-130)]];
	[menu runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,-130)]];
	[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(endTransition)] withDelay: duration + 0.2]];
}

-(void)shiftOut
{
	[self shiftOutWithDuration: 0.3];
}

-(void)shiftInWithDuration: (NSTimeInterval)duration
{
	inTransition = YES;
	
	if (!paused)
	{
		for (int i = 0; i < [kGameName length]; i++)
		{
			MMLetterLabel *letter = [letters objectAtIndex: i];
			
			CGPoint p = kMainMenuLetterShiftVector;
			p.x = (-1) * p.x;
			p.y = (-1) * p.y;
			p.x += i * 13;
			CGPoint dest = ccpAdd(letter.originalPosition, p);
			
			[letter stopAllActions];
			[letter runAction: [CCMoveBy actionWithDuration: duration position: p]];
			[letter runAction: [CCScaleTo actionWithDuration: duration scale: 1.0]];
			letter.originalPosition = dest;
			//[letter runAction: [CCRepeatForever actionWithAction: [CCDelayTime actionWithDuration: 1.0]]];
			
			
		}
		[scoresMenu runAction: [CCMoveTo actionWithDuration: duration position: ccp(45,320-35)]];
	}
	else
	{
		[resumeMenu runAction: [CCFadeIn actionWithDuration: 0.25]];
	}
	[bg1 runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,130)]];
	[bg2 runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,130)]];
	[menu runAction: [CCMoveBy actionWithDuration: duration position: ccp(0,130)]];
	
	
	piano.tempo = 0.07;
	[piano playSequence: @"7,6,5,4,3,2,1"];
	[self performSelector: @selector(trumpetPressed) withObject: nil afterDelay: duration + 0.2];
	
	[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(endTransition)] withDelay: duration + 0.2]];
}

-(void)shiftIn
{
	[self shiftInWithDuration: 0.3];
}

-(void)endTransition
{
	inTransition = NO;
}

#pragma mark -
#pragma mark Paused menu

-(void)showPausedMenu
{
	[CCMenuItemFont setFontName: kMainMenuFont];
	[CCMenuItemFont setFontSize: kResumeGameMenuFontSize];
		
	CCMenuItemFont *menuItem1 = [CCMenuItemFont itemFromString: @"RESUME GAME" target:self selector:@selector(onResume:)];
	resumeMenu = [CCMenu menuWithItems:menuItem1, nil];
	[self addChild: resumeMenu z: 1000];
	resumeMenu.position = ccpAdd(kResumeGameMenuPoint, ccp(-340,0));
	
	[resumeMenu runAction:  [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.35 position: kResumeGameMenuPoint] rate: 4.0f]];
	
	[bg1 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
	[bg2 runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
	[menu runAction: [CCMoveBy actionWithDuration: 0.3 position: ccp(0,130)]];
}

#pragma mark -
#pragma mark Settings

-(void)showSettings
{	
	musicLabel = [CCLabelTTF labelWithString: @"Music" fontName: kMainMenuFont fontSize: 32];
	musicLabel.position = ccp(-185, 200);
	[self addChild: musicLabel z: 1001];
	[musicLabel runAction: [CCMoveTo actionWithDuration: 0.5 position: ccp(170, 200)]];
	
	soundLabel = [CCLabelTTF labelWithString: @"Sound" fontName: kMainMenuFont fontSize: 32];
	soundLabel.position = ccp(-185, 160);
	[self addChild: soundLabel z: 1001];
	[soundLabel runAction: [CCMoveTo actionWithDuration: 0.4 position: ccp(165, 150)]];
	
	gameCenterLabel = [CCLabelTTF labelWithString: @"Game Center" fontName: kMainMenuFont fontSize: 32];
	gameCenterLabel.position = ccp(-185, 120);
	[self addChild: gameCenterLabel z: 1001];
	[gameCenterLabel runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(125, 100)]];
	
	
	CCMenuItem *musicOnItem = [CCMenuItemImage itemFromNormalImage: kCheckBoxOnSprite
													 selectedImage: kCheckBoxOnSprite
															target:nil
														  selector:nil];
	
	CCMenuItem *musicOffItem = [CCMenuItemImage itemFromNormalImage: kCheckBoxOffSprite
													  selectedImage: kCheckBoxOffSprite
															 target:nil
														   selector:nil];
	
	CCMenuItem *soundOnItem = [CCMenuItemImage itemFromNormalImage:kCheckBoxOnSprite
													 selectedImage:kCheckBoxOnSprite
															target:nil
														  selector:nil];
	
	CCMenuItem *soundOffItem = [CCMenuItemImage itemFromNormalImage:kCheckBoxOffSprite
													  selectedImage:kCheckBoxOffSprite
															 target:nil
														   selector:nil];
	
	CCMenuItem *gameCenterOnItem = [CCMenuItemImage itemFromNormalImage:kCheckBoxOnSprite
														  selectedImage:kCheckBoxOnSprite
																 target:nil
															   selector:nil];
	
	CCMenuItem *gameCenterOffItem = [CCMenuItemImage itemFromNormalImage:kCheckBoxOffSprite
														   selectedImage:kCheckBoxOffSprite
																  target:nil
																selector:nil];
	
	ExpandingMenuItemToggle *toggleSound = [ExpandingMenuItemToggle itemWithTarget: [[UIApplication sharedApplication] delegate] selector:@selector(toggleSound) items:
									 soundOffItem,
									 soundOnItem,
									 nil];
	toggleSound.selectedIndex = SOUND_ENABLED;
	
	ExpandingMenuItemToggle *toggleMusic = [ExpandingMenuItemToggle itemWithTarget: [[UIApplication sharedApplication] delegate] selector:@selector(toggleMusic) items:
									 musicOffItem,
									 musicOnItem,
									 nil];
	toggleMusic.selectedIndex = MUSIC_ENABLED;
		
	ExpandingMenuItemToggle *toggleGameCenter = [ExpandingMenuItemToggle itemWithTarget: [[UIApplication sharedApplication] delegate] selector:@selector(toggleGameCenter) items:
										  gameCenterOffItem,
										  gameCenterOnItem,
										  nil];
	toggleGameCenter.selectedIndex = GAMECENTER_ENABLED;
	
	settingsMenu = [CCMenu menuWithItems: toggleMusic, toggleSound, toggleGameCenter, nil];
	[settingsMenu alignItemsVerticallyWithPadding: 10.0f];
	settingsMenu.position = ccp(-185,150);
	[self addChild: settingsMenu];
	[settingsMenu runAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(240,150)]];

}

-(void)hideSettings
{
	[musicLabel runAction: [CCSequence actions: [CCMoveTo actionWithDuration: 0.25 position: ccp(-185, 200)],
							 [CCCallFunc actionWithTarget: musicLabel selector: @selector(dispose)], nil]];
	[soundLabel runAction: [CCSequence actions: [CCMoveTo actionWithDuration: 0.35 position: ccp(-185, 150)],
							[CCCallFunc actionWithTarget: soundLabel selector: @selector(dispose)], nil]];
	[gameCenterLabel runAction: [CCSequence actions: [CCMoveTo actionWithDuration: 0.45 position: ccp(-185, 100)],
							[CCCallFunc actionWithTarget: gameCenterLabel selector: @selector(dispose)], nil]];
	[settingsMenu runAction: [CCSequence actions: [CCMoveTo actionWithDuration: 0.5 position: ccp(-185, 120)],
								 [CCCallFunc actionWithTarget: settingsMenu selector: @selector(dispose)], nil]];
}

#pragma mark -
#pragma mark Credits

-(void)showCredits
{
	creditsLogo = [CCSprite spriteWithFile: @"corrino_logo.png"];
	creditsLogo.position = ccp(-278, 205);
	[self addChild: creditsLogo];
	[creditsLogo runAction: [CCMoveTo actionWithDuration: 0.45 position: ccp(40, 205)]];
	//[creditsLogo runAction: [CCRepeatForever actionWithAction: [CCRotateBy actionWithDuration: 0.1 angle: -10]]]; 
	
	NSString *creditsStr = [NSString stringWithFormat: @"A\n%@\nGAME", kGameDeveloper];
	NSString *createdByStr = [NSString stringWithFormat: @"CREATED BY\n%@ & %@", kGameProgramming, kGameGraphics];
	
	creditsLabel = [CCLabelTTF labelWithString: creditsStr dimensions:CGSizeMake(390,200) alignment: UITextAlignmentCenter fontName: kMainMenuFont fontSize: 32];
	creditsLabel.position = ccp(-278, 140);
	[self addChild: creditsLabel];
	[creditsLabel runAction: [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.45 position: ccp(205, 140)] rate:4.0f]];
	
	createdByLabel = [CCLabelTTF labelWithString: createdByStr dimensions:CGSizeMake(390,150) alignment: UITextAlignmentCenter fontName: kMainMenuFont fontSize: 32];
	createdByLabel.position = ccp(-185, 50);
	[self addChild: createdByLabel];
	 [createdByLabel runAction: [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(205, 50)] rate:4.0f]];
}

-(void)hideCredits
{
	[creditsLogo runAction: [CCSequence actions: [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(-278, 205)] rate:4.0f],
							 [CCCallFunc actionWithTarget: creditsLogo selector: @selector(dispose)], nil]];
	[creditsLabel runAction: [CCSequence actions: [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.3 position: ccp(-278, 140)] rate:4.0f],
							 [CCCallFunc actionWithTarget: creditsLabel selector: @selector(dispose)], nil]];
	[createdByLabel runAction: [CCSequence actions: [CCEaseIn actionWithAction: [CCMoveTo actionWithDuration: 0.45 position: ccp(-185, 50)] rate:4.0f],
							  [CCCallFunc actionWithTarget: createdByLabel selector: @selector(dispose)], nil]];
	
}

#pragma mark -
#pragma mark Instruments 

-(void)trumpetPressed
{
	float pitch =  [Instrument bluesPitchForIndex: RandomBetween(0, 6)];
	
	if (SOUND_ENABLED)
		[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch: pitch pan:0.0f gain:0.3f];	
		
	[icon runAction: [CCSequence actions:
											   [CCScaleTo actionWithDuration: 0.1 scale: 1.2],
											   [CCScaleTo actionWithDuration: 0.2 scale: 1.0],
											   nil]];
}

-(void)notePressed: (NSNumber *)num
{
	int note = [num intValue]-1;
	
	float scaleNormal = 1.0, scaleLarge = 1.5;
	if (state != kMainState)
	{
		scaleNormal = 0.8;
		scaleLarge = 1.2;
	}
	
	[[letters objectAtIndex: note] runAction: [CCSequence actions:
						[CCScaleTo actionWithDuration: 0.1 scale: scaleLarge],
						[CCScaleTo actionWithDuration: 0.1 scale: scaleNormal],
											   nil]];
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (inTransition || currTouch != nil)
		return;
		
    currTouch = [touches anyObject];
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	BOOL playedNote = NO;
	for (int i = 0; i < [kGameName length]; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			[piano playNote: i+1];
			playedNote = YES;
		}
	}
	
	if (!playedNote && CGRectContainsPoint([icon rect], location))
	{
		[self trumpetPressed];
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
				state = kMainState;
				break;
		}
		
	}
	
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (inTransition || currTouch == nil)
		return;

	
	CGPoint location = [currTouch locationInView: [currTouch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	BOOL playedNote = NO;
	for (int i = 0; i < [kGameName length]; i++)
	{
		MMLetterSprite *letter = [letters objectAtIndex: i];
		if (CGRectContainsPoint([letter rect], location))
		{
			[piano playNote: i+1];
			playedNote = YES;
		}
		
	}
	
	if (!playedNote && CGRectContainsPoint([icon rect], location))
	{
		[self trumpetPressed];
		playedNote = YES;
	}
		
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	currTouch = nil;
}



@end
