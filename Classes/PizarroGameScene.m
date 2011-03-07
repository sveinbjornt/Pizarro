//
//  HelloWorldLayer.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/15/11.
//  Copyright Corrino Software 2011. All rights reserved.
//

// Import the interfaces
#import "PizarroGameScene.h"
#import "Circle.h"
#import "Square.h"
#import "Triangle.h"
#import "FontManager.h"
#import "BouncingBall.h"
#import "CCNode+Cleanup.m"
#import "chipmunk.h"
#import "SimpleAudioEngine.h"
#import "Common.c"
#import "MainMenuScene.h"
#import "GameCenterManager.h"
#import "ScoreManager.h"
#import "MenuButtonSprite.h"
#import "GParams.h"

#pragma mark Chipmunk Callbacks

int lastPlayedIndex = 0;
int pentatonicCount = 0;

static void UpdateShape(void* ptr, void* unused)
{	
	cpShape* shape = (cpShape*)ptr;	
	CCNode *sprite = shape->data;
	
	if(sprite)
	{
		cpBody* body = shape->body;
		
		[sprite setPosition:cpv(body->p.x, body->p.y)];
		//[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

static void PlayBallCollisionSound (int level)
{
	if (!SOUND_ENABLED)
		return;
	
	int mod = RandomBetween(-level, level);
	
	int lp = lastPlayedIndex;
	
	lastPlayedIndex += mod + RandomBetween(-2, 2);
	while (lastPlayedIndex < 1)
		lastPlayedIndex = 7 + lastPlayedIndex;
	while (lastPlayedIndex > 7)
		lastPlayedIndex = 1 + (lastPlayedIndex - 8);
	
	// Pentatonic count achievemtn
	if (lastPlayedIndex <= lp || (lp - lastPlayedIndex) > 1)
		pentatonicCount = 0;
	else
	{
		pentatonicCount++;
		if (pentatonicCount >= 6)
		{
			[ScoreManager reportAchievementWithIdentifier: kGameCenterMinorPentatonicAchievement];
			pentatonicCount = 0;
		}
	}
	
	[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"piano%d.wav", lastPlayedIndex] pitch:1.0f pan:0.0f gain:0.1f];
	
}


static void CollisionBallExpansionCircle (cpArbiter *arb, cpSpace *space, void *data)
{
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	BouncingBall *bball = (BouncingBall *)a->data;
	[bball hilight];
	
	Shape *shape = b->data;
	shape.destroyed = YES;
	
	[(PizarroGameScene *)data collision];
	
	if (SOUND_ENABLED)
		[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch:0.891 pan:0.0f gain:0.3f];	
}

static void CollisionBallAndCircleOrWall (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	PlayBallCollisionSound([scene currentLevel]+1);
	
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	BouncingBall *bball = a->data;
	[bball hilight];
}

static void CollisionBallAndBall (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	PlayBallCollisionSound([scene currentLevel]+1);
	PlayBallCollisionSound([scene currentLevel]+2);
	
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	BouncingBall *aball = a->data, *bball = b->data;
	[aball hilight];
	[bball hilight];
}

#pragma mark -

// HelloWorld implementation
@implementation PizarroGameScene

@synthesize multiPlayer;


#pragma mark -
#pragma mark Instantiation

+(id) scene: (BOOL)multiPl
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	CGSize s = [[CCDirector sharedDirector] winSize];
	PizarroGameScene *layer = [[PizarroGameScene alloc] initWithColor: ccc4(255,255,255,255)  width: s.width height: s.height multiPlayer: multiPl];
	[layer autorelease];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
	CCLOG(@"Deallocing Pizarro Game Scene");
		
	[self destroyPhysicalSpace];
	
	[bounceBalls release];
	[shapes release];
	
	[surface release];
	
	[piano release];
	
	[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

- (id)initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h multiPlayer: (BOOL)mp
{
	if ((self = [super initWithColor: color width: w height: h])) 
	{		
		CCLOG(@"Creating Pizarro Game Scene");
		// White, touch-sensitive layer
		self.isTouchEnabled = YES;
		self.color = kWhiteColor;
		self.opacity = 255;
		
		multiPlayer = mp;
		
		CCLOG(@"Multiplayer: %d", multiPlayer);
		
		// Setup
		[self setupGameVariables];
		[self setupHUD];
		[self setupGame];
		//[self updateCurrentShape];
				
		// Music and sound
		int bassLineNum = [[NSUserDefaults standardUserDefaults] integerForKey: kLastBassLine] + 1;
		if (bassLineNum > kNumBassLines)
			bassLineNum = 1;
		[[NSUserDefaults standardUserDefaults] setInteger: bassLineNum forKey: kLastBassLine];
		CCLOG(@"Bass line is %d", bassLineNum);
		NSString *musicFile = [NSString stringWithFormat: @"bassline%d.mp3", bassLineNum];
		
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: musicFile loop: YES];
		
	
		piano = [[Instrument alloc] initWithName: @"piano" numberOfNotes: 7 tempo: 0.1];
		
		// Increase mana bar
		manaIncreaseTime = NOW;
		[self schedule: @selector(manaIncreaseTicker:) interval: 1.0/60];
		
		// Start game
		
		if (SHOW_TUTORIAL)
		{
			tutorialStep = kTutorialStep1;
			[self showTutorialStep: tutorialStep];
		}
		else
			[self startGame];
	}
	
	return self;
}

#pragma mark -
#pragma mark Setup

-(void)setupGameVariables
{
	// Prep vars for new game
	score = 0;
	level = 1;
	percentageFilled = 0.0f;
	
	mana = 0;
	newMana = kStartingMana;
	oldMana = 0;
	
	flawless = YES;
	timeRemaining = kStartingTime;
	gameOver = NO;
	currShapeIndex = 0;
	currentShapeClass = [Circle class];//[Circle class];
	
	currentTutorialNode = nil;
}

-(void)setupHUD
{	
	// BACKGROUND
	CCSprite *bg;
	if (multiPlayer)
		bg = [CCSprite spriteWithFile: [GParams spriteFileName: kGameScreenMultiplayerBackgroundSprite]];
	else
		bg = [CCSprite spriteWithFile: [GParams spriteFileName: kGameScreenBackgroundSprite]];

	bg.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	bg.position = kGameScreenCenterPoint;
	[self addChild: bg z: 100];	
	
	// game backing texture
	bgRenderTexture = [BGRenderTexture renderTextureWithWidth: [GParams gameBoxWidth: multiPlayer] height: [GParams gameBoxHeight: multiPlayer]];
	[bgRenderTexture setPosition: kGameBoxCenterPoint];
	[bgRenderTexture clear];
	bgRenderTexture.sprite.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	//[[bgRenderTexture sprite] setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
	[self addChild: bgRenderTexture z: 90];
	
	// TIMER
	[self updateTimer];
	
	// LEVEL
	[self updateLevel];
	
	// SCORE
	if (!multiPlayer)
	{
		CCLabelTTF *scoreL = [CCLabelTTF labelWithString: @"SCORE" dimensions: [GParams timeLabelSize] alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: [GParams HUDFontSize]];
		scoreL.color = ccc3(0,0,0);
		scoreL.position = [GParams scoreLPoint];
		[self addChild: scoreL z: 1001];
		[self updateScore];
	}
	
	// MANA BAR
	manaBar = [[[ManaBar alloc] init] autorelease];
	manaBar.position = ccp(4,7);
	manaBar.percentage = 0.0f;
	[self addChild: manaBar z: 99];
	
	if (multiPlayer)
		manaBar.visible = NO;
	
	
	// Pause button
	MenuButtonSprite *pauseMenuItem = [MenuButtonSprite itemFromNormalSprite: [CCSprite spriteWithFile: [GParams spriteFileName: kInGameMenuButtonOffSprite]] 
															  selectedSprite: [CCSprite spriteWithFile: [GParams spriteFileName: kInGameMenuButtonOnSprite]] 
																	  target: self 
																	selector: @selector(pauseGame)];
	pauseMenu = [CCMenu menuWithItems: pauseMenuItem, nil];
	pauseMenu.position = [GParams menuPauseButtonPoint];
	[self addChild: pauseMenu z: 100];
}

-(void)setupGame
{
	//surface matrix
	int h = IPAD ? 66 : 28; // 1848
	int w = IPAD ? 95 : 45; // 4275

	surface = [[SurfaceMatrix alloc] initWithWidth: w height: h];
	
	// Array of objects
	shapes = [[NSMutableArray alloc] initWithCapacity: kMaxShapes];
	bounceBalls = [[NSMutableArray alloc] initWithCapacity: kMaxBounceBalls];
	
	// Timers
	[self schedule: @selector(tick:) interval: 1.0/60.0f];
	[self schedule: @selector(step:) interval: 1.0/240.0f];
	[self schedule: @selector(timeTicker:) interval: 1.0];
	//[self schedule: @selector(symbolTicker:) interval: 2.0];
	
	// Physics engine
	[self setupChipmunk];
}

-(void)setupChipmunk
{	
	cpInitChipmunk();
	
	space = cpSpaceNew();	
	space->gravity = cpv(0,0); // zero gravity
	space->elasticIterations = 0;
	
	// Add collision handlers	
	cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, &CollisionBallExpansionCircle, NULL, self);  // collision between expanding shape and bouncing ball
	cpSpaceAddCollisionHandler(space, 1, 0, NULL, NULL, &CollisionBallAndCircleOrWall, NULL, self); // collision between finished circles or walls and a bouncing ball
	cpSpaceAddCollisionHandler(space, 1, 1, NULL, NULL, &CollisionBallAndBall, NULL, self); 
	
	[self createPhysicalBox];
}

-(void)createPhysicalBox
{
	CGPoint lp1,lp2;
	
	// Create the square shape by making 4 lines: floor, ceiling, left, right
		
	// Floor
	floorBody = cpBodyNew(kWallMass, kWallInertia);
	
	floorBody->p = cpv(0, 0);
	
	lp1 = cpv([GParams gameBoxXOffset: multiPlayer] - kWallThickness, 
			  [GParams gameBoxYOffset: multiPlayer] - kWallThickness + kPhysicalBoxOffset);
	lp2 = cpv([GParams gameBoxXOffset: multiPlayer] + [GParams gameBoxWidth: multiPlayer] + kWallThickness, 
			  [GParams gameBoxYOffset: multiPlayer] - kWallThickness + kPhysicalBoxOffset);
	
	floorShape = cpSegmentShapeNew(floorBody, lp1, lp2, kWallThickness);
	
	floorShape->e = kWallElasticity;
	floorShape->u = kWallFriction;
	floorShape->collision_type = kWallCollisionType;
	floorShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, floorShape);
	
	
	// Ceiling
	ceilingBody = cpBodyNew(kWallMass, kWallInertia);
	
	ceilingBody->p = cpv(0, 0);
	
	lp1 = cpv([GParams gameBoxXOffset: multiPlayer] - kWallThickness, 
			  [GParams gameBoxYOffset: multiPlayer] + [GParams gameBoxHeight: multiPlayer] + kWallThickness - kPhysicalBoxOffset);
	lp2 = cpv([GParams gameBoxXOffset: multiPlayer] + [GParams gameBoxWidth: multiPlayer] + kWallThickness, 
			  [GParams gameBoxYOffset: multiPlayer] + [GParams gameBoxHeight: multiPlayer] + kWallThickness - kPhysicalBoxOffset);
	
	ceilingShape = cpSegmentShapeNew(ceilingBody, lp1, lp2, kWallThickness);
	
	ceilingShape->e = kWallElasticity;
	ceilingShape->u = kWallFriction;
	ceilingShape->collision_type = kWallCollisionType;
	ceilingShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, ceilingShape);
	
	
	
	// Left side
	
	leftBody = cpBodyNew(kWallMass, kWallInertia);
	
	leftBody->p = cpv(0, 0);
	
	lp1 = cpv([GParams gameBoxXOffset: multiPlayer] - kWallThickness + kPhysicalBoxOffset, 
			  [GParams gameBoxYOffset: multiPlayer] - kWallThickness );
	lp2 = cpv([GParams gameBoxXOffset: multiPlayer] - kWallThickness + kPhysicalBoxOffset, 
			  [GParams gameBoxYOffset: multiPlayer] + [GParams gameBoxHeight: multiPlayer] + kWallThickness);
	
	leftShape = cpSegmentShapeNew(leftBody, lp1, lp2, kWallThickness);
	
	leftShape->e = kWallElasticity;
	leftShape->u = kWallFriction;
	leftShape->collision_type = kWallCollisionType;
	leftShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, leftShape);
	
	
	
	// Right side
	
	rightBody = cpBodyNew(kWallMass, kWallInertia);
	
	rightBody->p = cpv(0, 0);
	
	lp1 = cpv([GParams gameBoxXOffset: multiPlayer] + [GParams gameBoxWidth: multiPlayer] + kWallThickness - kPhysicalBoxOffset, 
			  [GParams gameBoxYOffset: multiPlayer] - kWallThickness );
	lp2 = cpv([GParams gameBoxXOffset: multiPlayer] + [GParams gameBoxWidth: multiPlayer] + kWallThickness - kPhysicalBoxOffset, 
			  [GParams gameBoxYOffset: multiPlayer] + [GParams gameBoxHeight: multiPlayer] + kWallThickness);
	
	rightShape = cpSegmentShapeNew(rightBody, lp1, lp2, kWallThickness);
	
	rightShape->e = kWallElasticity;
	rightShape->u = kWallFriction;
	rightShape->collision_type = kWallCollisionType;
	rightShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, rightShape);
	
	// If multiplayer, we add the ball drag sources as objects
	
	if (multiPlayer)
	{
		srcBallBody1 = cpBodyNew(kWallMass, kWallInertia);
		srcBallBody1->p = [GParams multiPlayerSrcBallPoint1];
		
		cpSpaceAddBody(space, srcBallBody1);
		
		srcBallShape1 = cpCircleShapeNew(srcBallBody1, [GParams multiPlayerSrcBallRadius], cpvzero);
		srcBallShape1->e = kWallElasticity;
		srcBallShape1->u = kWallFriction;	
		srcBallShape1->collision_type = kWallCollisionType;
		srcBallShape1->group = kWallShapeGroup;
		
		cpSpaceAddShape(space, srcBallShape1);
		
		
		srcBallBody1 = cpBodyNew(kWallMass, kWallInertia);
		srcBallBody1->p = [GParams multiPlayerSrcBallPoint2];
		
		cpSpaceAddBody(space, srcBallBody1);
		
		srcBallShape1 = cpCircleShapeNew(srcBallBody1, [GParams multiPlayerSrcBallRadius], cpvzero);
		srcBallShape1->e = kWallElasticity;
		srcBallShape1->u = kWallFriction;	
		srcBallShape1->collision_type = kWallCollisionType;
		srcBallShape1->group = kWallShapeGroup;
		
		cpSpaceAddShape(space, srcBallShape1);
	}
}

-(void)destroyPhysicalSpace
{
	// floor
	cpBodyDestroy(floorBody);
	cpBodyFree(floorBody);
	
	cpShapeDestroy(floorShape);
	cpShapeFree(floorShape);
	
	// ceiling
	cpBodyDestroy(ceilingBody);
	cpBodyFree(ceilingBody);
	
	cpShapeDestroy(ceilingShape);
	cpShapeFree(ceilingShape);
	
	// left
	
	cpBodyDestroy(leftBody);
	cpBodyFree(leftBody);
	
	cpShapeDestroy(leftShape);
	cpShapeFree(leftShape);
	
	// right
	
	cpBodyDestroy(rightBody);
	cpBodyFree(rightBody);
	
	cpShapeDestroy(rightShape);
	cpShapeFree(rightShape);
	
	if (multiPlayer)
	{
//		cpBodyDestroy(srcBallBody1);
//		cpBodyFree(srcBallBody1);
//		
//		cpShapeDestroy(srcBallShape1);
//		cpShapeFree(srcBallShape1);
//		
//		cpBodyDestroy(srcBallBody2);
//		cpBodyFree(srcBallBody2);
//		
//		cpShapeDestroy(srcBallShape2);
//		cpShapeFree(srcBallShape2);
	}
		
	cpSpaceFree(space);

}

#pragma mark -
#pragma mark Pause


-(void)pauseGame
{
	[self pauseGameWithAnimation: YES];
}

-(void)pauseGameWithAnimation: (BOOL)animated
{	
	for (Shape *s in shapes)
	{
		if (s.expanding && !s.destroyed)
			[self endExpansionOfShape: s];
	}
	
	if (animated)
		[[CCDirector sharedDirector] pushScene: [CCTransitionSlideInL transitionWithDuration: 0.35 scene: [MainMenuScene scenePausedForScene: (CCScene *)self.parent]]];	
	else
		[[CCDirector sharedDirector] pushScene: [MainMenuScene scenePausedForScene: (CCScene *)self.parent]];
}


#pragma mark -
#pragma mark Tutorial 

-(void)showTutorialStep: (int)stepNum
{
	if (currentTutorialNode != nil)
	{
		lastTutorialNode = currentTutorialNode;
		
		[lastTutorialNode runAction: [CCSequence actions: 
									  [CCMoveBy actionWithDuration: 0.33 position: ccp(-420, 0)],
									  [CCCallFunc actionWithTarget: lastTutorialNode selector: @selector(dispose)],
									  nil]];
	}
	
	currentTutorialNode = [CCNode node];
	BOOL tutorialOver = NO;
	
	switch (stepNum)
	{
		case kTutorialStep1:
		{			
			CCLabelTTF *welcome = [CCLabelTTF labelWithString: @"WELCOME TO PIZARRO" fontName: kTutorialFont fontSize: kWelcomeToPizarroFontSize];
			CGPoint p = kGameBoxCenterPoint;
			p.y += 100;
			welcome.position = p;
			welcome.color = kBlackColor;
			[currentTutorialNode addChild: welcome];
			
			NSString *expl = @"The objective of the game is\nto cover 80% of the\nsurface area in each level\nby creating circles.";
			CCLabelTTF *text = [CCLabelTTF labelWithString: expl
												dimensions: CGSizeMake(400,140) 
												 alignment: UITextAlignmentLeft
												  fontName: kTutorialFont 
												  fontSize: kTutorialFontSize];
			
			text.position = kGameBoxCenterPoint;
			text.color = kBlackColor;
			[currentTutorialNode addChild: text];
			
			CCLabelTTF *press = [CCLabelTTF labelWithString: @"PRESS TO CONTINUE -->" fontName: kTutorialFont fontSize: kTutorialFontSize];
			p = kGameBoxCenterPoint;
			p.y = 45;
			press.position = p;
			press.color = kBlackColor;
			[currentTutorialNode addChild: press];
		}
		break;
			
		case kTutorialStep2:
		{						
			NSString *expl = @"You create circles by pressing\nthe screen and holding.\nThe longer you hold, the bigger the circle.\n<-- Creating circles uses up energy (green bar left)";
			CCLabelTTF *text = [CCLabelTTF labelWithString: expl
												dimensions: CGSizeMake(400,200) 
												 alignment: UITextAlignmentLeft
												  fontName: kTutorialFont 
												  fontSize: kTutorialFontSize];
			CGPoint p = kGameBoxCenterPoint;
			p.y += 20;
			text.position = p;
			text.color = kBlackColor;
			[currentTutorialNode addChild: text];
			
			CCSprite *tutorialCircle = [CCSprite spriteWithFile: [GParams spriteFileName: kTutorialCircleSprite]];
			tutorialCircle.position = ccp(412,200);
			[currentTutorialNode addChild: tutorialCircle];
			[tutorialCircle runAction: [CCRepeatForever actionWithAction: [CCSequence actions:
											
																		   [CCScaleTo actionWithDuration: 0.5 scale: 1.25],
																		   [CCScaleTo actionWithDuration: 0.5 scale: 1.0],
																		   
																		   nil]]];
			
			
			CCLabelTTF *press = [CCLabelTTF labelWithString: @"PRESS TO CONTINUE -->" fontName: kTutorialFont fontSize: kTutorialFontSize];
			p = kGameBoxCenterPoint;
			p.y = 45;
			press.position = p;
			press.color = kBlackColor;
			[currentTutorialNode addChild: press];
		}
		break;
			
		case kTutorialStep3:
		{						
			NSString *expl = @"Each level contains one or more bouncing red balls.\n\nIf a circle you're creating collides with a red bouncing ball, it disappears.";
			CCLabelTTF *text = [CCLabelTTF labelWithString: expl
												dimensions: CGSizeMake(400,200) 
												 alignment: UITextAlignmentLeft
												  fontName: kTutorialFont 
												  fontSize: kTutorialFontSize];
			CGPoint p = kGameBoxCenterPoint;
			p.y += 20;
			text.position = p;
			text.color = kBlackColor;
			[currentTutorialNode addChild: text];
			
			CCSprite *bball = [CCSprite spriteWithFile: [GParams spriteFileName: kBouncingBallSprite]];
			bball.position = ccp(235,195);
			[currentTutorialNode addChild: bball];
			
			[bball runAction: [CCRepeatForever actionWithAction: [CCSequence actions:
																		   
																		   [CCScaleTo actionWithDuration: 0.5 scale: 1.25],
																		   [CCScaleTo actionWithDuration: 0.5 scale: 1.0],
																		   
																		   nil]]];
			
			CCLabelTTF *press = [CCLabelTTF labelWithString: @"PRESS TO CONTINUE -->" fontName: kTutorialFont fontSize: kTutorialFontSize];
			p = kGameBoxCenterPoint;
			p.y = 45;
			press.position = p;
			press.color = kBlackColor;
			[currentTutorialNode addChild: press];
		}
		break;
			
		case kTutorialStep4:
		{						
			NSString *expl = @"If you run out of energy (left) or time (top right), you lose the game.\n\nEvery time you complete a level, you get more energy and time.";
			CCLabelTTF *text = [CCLabelTTF labelWithString: expl
												dimensions: CGSizeMake(400,200) 
												 alignment: UITextAlignmentLeft
												  fontName: kTutorialFont 
												  fontSize: kTutorialFontSize];
			CGPoint p = kGameBoxCenterPoint;
			p.y += 20;
			text.position = p;
			text.color = kBlackColor;
			[currentTutorialNode addChild: text];
			
			CCLabelTTF *press = [CCLabelTTF labelWithString: @"PRESS TO CONTINUE -->" fontName: kTutorialFont fontSize: kTutorialFontSize];
			p = kGameBoxCenterPoint;
			p.y = 45;
			press.position = p;
			press.color = kBlackColor;
			[currentTutorialNode addChild: press];
		}
		break;
			
		case kTutorialStep5:
		{						
			NSString *expl = @"You should now be ready to play.";
			CCLabelTTF *text = [CCLabelTTF labelWithString: expl
												dimensions: CGSizeMake(400,200) 
												 alignment: UITextAlignmentLeft
												  fontName: kTutorialFont 
												  fontSize: kTutorialFontSize];
			CGPoint p = kGameBoxCenterPoint;
			p.y += 20;
			text.position = p;
			text.color = kBlackColor;
			[currentTutorialNode addChild: text];
			
			CCLabelTTF *enjoy = [CCLabelTTF labelWithString: @"ENJOY PIZARRO!"
												   fontName:  kTutorialFont
												   fontSize: kEnjoyPizarroFontSize];
			
			enjoy.position = kGameBoxCenterPoint;
			enjoy.color = kBlackColor;
			[currentTutorialNode addChild: enjoy];
			
			CCLabelTTF *press = [CCLabelTTF labelWithString: @"PRESS TO START GAME -->" fontName: kTutorialFont fontSize: kTutorialFontSize];
			p = kGameBoxCenterPoint;
			p.y = 45;
			press.position = p;
			press.color = kBlackColor;
			[currentTutorialNode addChild: press];
		}
		break;
			
		case kTutorialStep6:
		{
			[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: NO] forKey: kShowTutorial];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			tutorialOver = YES;
			tutorialStep = kTutorialStepNone;
			[self startGame];
		}
		break;
	}
	
	if (!tutorialOver)
	{
		float pitch = [Instrument bluesPitchForIndex: RandomBetween(0, 6)];
		if (SOUND_ENABLED)
			[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch: pitch pan:0.0f gain:0.3f];
		
		inTransition = YES;
		CGPoint startPos = ccp(0,0);
		startPos.x += 420;
		currentTutorialNode.position = startPos;
		[self addChild: currentTutorialNode z: 91];
		
		[currentTutorialNode runAction: [CCMoveBy actionWithDuration: 0.33 position: ccp(-420, 0)]];
		[self runAction: [CCSequence actions:
								[CCDelayTime actionWithDuration: 0.33],
								[CCCallFunc actionWithTarget: self selector: @selector(endTransition)],
						  nil]];
	}
}

#pragma mark -
#pragma mark HUD

-(void)updateLevel
{
	[self removeChild: levelLabel cleanup: YES];
	
	if (multiPlayer)
		return;
	
	NSString *levelStr = [NSString stringWithFormat: @"%d", level];
	levelLabel = [CCLabelTTF labelWithString: levelStr fontName: kHUDFont fontSize: [GParams levelLabelFontSize]];
	levelLabel.color = kBlackColor;
	levelLabel.position =  [GParams levelLabelPoint];
	//levelLabel.rotation = -45.0f;
	[self addChild: levelLabel z: 1001];
}

-(void)updateScore
{
	[self removeChild: scoreLabel cleanup: YES];
	
	if (multiPlayer)
		return;
	
	NSString *scoreStr = [NSString stringWithFormat: @"%d", score];
	scoreLabel = [CCLabelTTF labelWithString: scoreStr dimensions: [GParams timeLabelSize] alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: [GParams HUDFontSize]];
	scoreLabel.color = kBlackColor;
	CGPoint p = [GParams scoreLabelPoint];
	p.x += scoreLabel.contentSize.width/2;
	scoreLabel.position = p;
	[self addChild: scoreLabel z: 1001];
}

-(void)updateTimer
{
	[self removeChild: timeLabel cleanup: YES];
	
	if (multiPlayer)
		return;
	
	int min, sec;
	min = timeRemaining/60;
	sec = timeRemaining - (min*60);
		
	NSString *timeStr = [NSString stringWithFormat: @"%.2d:%.2d", min, sec];
	timeLabel = [CCLabelTTF labelWithString: timeStr dimensions: [GParams timeLabelSize] alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: [GParams HUDFontSize]];
	
	if (timeRemaining > kTimeLow)
		timeLabel.color = kBlackColor; // black
	else
		timeLabel.color = ccc3(180,0,0); // red
	
	timeLabel.position =  [GParams timeLabelPoint];
	[self addChild: timeLabel z: 1001];
	
	if (timeRemaining <= kTimeLow && SOUND_ENABLED)
	{
		int index = ((kTimeLow - timeRemaining) / 2);
		if (index > 6)
			index = 6;
		
		float pitch = [Instrument bluesPitchForIndex: index];
		
		[[SimpleAudioEngine sharedEngine] playEffect: @"piano1.wav" pitch: pitch pan:0.0f gain:0.54f];
	}
}

-(void)updateCurrentShape
{
	[self removeChild: shapeLabel cleanup: YES];
		
	shapeLabel = [CCLabelTTF labelWithString: [currentShapeClass textSymbol] fontName: kHUDFont fontSize: [currentShapeClass textSymbolSizeForHUD]];
	shapeLabel.position =  ccp(330, 297);
	shapeLabel.color = kBlackColor;
	[self addChild: shapeLabel z: 1001];	
}


//#pragma mark -
//#pragma mark Drawing
//
//-(void)draw
//{
//	[super draw];
//
////	if (currentCircle != nil)
////		ccDrawPoint(currentCircle.position);
//	
//	//[self drawGameSquare];
//	glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	glDisableClientState(GL_COLOR_ARRAY);
//
//	
//	for (int x = 0; x < surface.width; x++)
//	{
//		for (int y = 0; y < surface.height; y++)
//		{
//			if ([surface valueAtPointX: x Y: y] == 1)
//			{
//				glColor4ub(255,0,0,255);
//			}
//			else
//				glColor4ub(0,0,255,255);
//			
//			CGPoint p = CGPointMake((x * kMatrixUnitSize) + [GParams matrixXOffset], (y * kMatrixUnitSize) + [GParams matrixYOffset]);
//			
//			glPointSize(1);
//			glEnable(GL_POINT_SMOOTH);
//			
//			glVertexPointer(2, GL_FLOAT, 0, &p);	
//			glDrawArrays(GL_POINTS, 0, 1);
//			
//		}
//	}
//	
//	// restore default state
//	glEnableClientState(GL_COLOR_ARRAY);
//	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
//	glEnable(GL_TEXTURE_2D);
//}

#pragma mark -
#pragma mark Tickers

-(void)timeTicker: (ccTime)dt
{
	if (inTransition || tutorialStep != kTutorialStepNone)
		return;
	
	timeRemaining--;
	[self updateTimer];
}

-(void)symbolTicker: (ccTime)dt
{
	if (inTransition)
		return;
	
	currShapeIndex++;
	if (currShapeIndex >= kNumShapeKinds)
		currShapeIndex = 0;
	
	currentShapeClass = [Circle class];
	[self updateCurrentShape];
}

-(void)manaIncreaseTicker: (ccTime)dt
{
	float fractionOfTimeElapsed = ((NOW - manaIncreaseTime) *2);
	if (fractionOfTimeElapsed > 1.0f)
		fractionOfTimeElapsed = 1.0f;
	
	float diff = newMana - oldMana;
		
	[manaBar setManaLevel: oldMana + (diff * fractionOfTimeElapsed)];
}

-(void)tick: (ccTime)dt
{
	if (inTransition || tutorialStep != kTutorialStepNone || gameOver)
		return;
	
	// OK, let's check if we're advancing up level
	if (percentageFilled >= kSurfaceReqPerLevel)
	{
		inTransition = YES;
		
		// Give bonus points for each additional percentage point covered
		
		float extraPerc = percentageFilled - kSurfaceReqPerLevel;
		int bonus = extraPerc * 10 + level;
		score += bonus;
		
		//Shape *lastShape = [shapes lastObject];
		//[self noteBlastAtPoint: lastShape.position afterDelay: 0.1];
		
		[self runAction: [CCSequence actions:
						  [CCDelayTime actionWithDuration: 0.15],
						  [CCCallFunc actionWithTarget: self selector: @selector(advanceLevel)], nil]];
		
		return;
	}
	
	if (mana <= 0 || timeRemaining <= 0)
	{
		// OK, he's out of time or mana, but if he's currently covering enough area,
		// then we let it slide
		
		int addedShapes = 0;
		for (Shape *shape in shapes)
		{
			if (shape.expanding && !shape.destroyed)
			{
				[self endExpansionOfShape: shape];
				addedShapes++;
			}
		}
		
		if (!addedShapes)
			[self gameOver];
		else if (addedShapes >= 4)
		{
			[ScoreManager reportAchievementWithIdentifier: kGameCenterTouchmasterAchievement];
		}

		return;
	}
	
	// Go through each shape
	//
	// We ignore all shapes that aren't flagged as destroyed or expanding
	//
	//  If it's flagged as destroyed, we make it smaller 
	//  If it's destroyed and very small, we remove it
	
	// If it's an expanding shape, we increase its size
	// and subtract from player's mana
	
	for (int i = [shapes count]-1; i >= 0; i--)
	{
		Shape *currentShape = [shapes objectAtIndex: i];
		
		if (!currentShape.destroyed && !currentShape.expanding)
			continue;
		
		if (currentShape.destroyed)
		{
			NSTimeInterval timeSinceDestroyed = NOW - currentShape.ended;
			NSTimeInterval ttl = 0.3;
			
			float fraction = (float) 1.0 - (timeSinceDestroyed / ttl);
			currentShape.size =  (float)fraction * currentShape.fullSize;
			
			if (currentShape.size <= 1)
			{
				[self removeShape: currentShape];
			}
			else
			{
				cpCircleShape *sh = (cpCircleShape *)currentShape.cpShape;
				sh->r = currentShape.size/2;
			}
		}
		else
		{
//			1260
//			6270
			NSTimeInterval timeSinceTouch = NOW - currentShape.created;
			float diamSec = IPAD ? kCircleExpansionDiameterPerSecond * 2.0 : kCircleExpansionDiameterPerSecond;
			currentShape.size = timeSinceTouch * diamSec;
			
			mana -= 1.0f/60.0f;
			manaBar.percentage = (float)mana/kFullMana;
			
			cpCircleShape *sh = (cpCircleShape *)currentShape.cpShape;
			sh->r = currentShape.size/2;
		
		}
	}
}

-(void)step: (ccTime)dt
{
	// Update physics engine
	cpSpaceStep(space, 1.0f/240.0f);
	cpSpaceHashEach(space->activeShapes, &UpdateShape, nil);
}

#pragma mark -
#pragma mark Blast

-(void)levelBlast: (NSUInteger)lvl atPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay
{
	NSString *levelStr = [NSString stringWithFormat: @"Level %d", lvl];
	CCLabelTTF *levelBlast = [CCLabelTTF labelWithString: levelStr fontName: kLevelBlastFont fontSize: [GParams levelBlastFontSize]];
	levelBlast.position = p;
	levelBlast.scale = 0.0;
	levelBlast.opacity = 255.0;
	levelBlast.color = kBlackColor;
	[self addChild: levelBlast z: 1000];
	
	[piano playWithInterval: 0.3 afterDelay: delay + 0.4 chords: @"1,2,3",  @"1,2,4", @"1,2,5", nil];
	
	[levelBlast runAction: [CCSequence actions: 
							[CCDelayTime actionWithDuration: delay],
							[CCScaleTo actionWithDuration: 0.33 scale: 1.0],
							[CCDelayTime actionWithDuration: 1.33],
							[CCScaleTo actionWithDuration: 0.33 scale: 0.0],
							[CCCallFunc actionWithTarget: levelBlast selector: @selector(dispose)], 
							nil]];
}

-(void)percentageBlast: (NSUInteger)s atPoint: (CGPoint)p
{
	NSString *scoreStr = [NSString stringWithFormat: @"%d%%", s];
	
//	CCLabelAtlas *scoreBlast = [CCLabelAtlas labelWithString: scoreStr 
//												  charMapFile:@"percentblast_spriteatlas.png" itemWidth:85 itemHeight:100 startCharMap:'0'];

	CCLabelBMFont *scoreBlast = [CCLabelBMFont labelWithString: scoreStr fntFile: @"font.fnt"];
	
	
	float startScale = (IPAD || CC_CONTENT_SCALE_FACTOR() > 1) ? 0.4 : 0.20;
	float endScale = (IPAD || CC_CONTENT_SCALE_FACTOR() > 1) ? 1.0 : 0.6;
//	CCLabelTTF *scoreBlast = [CCLabelTTF labelWithString: scoreStr fontName: kPercentageBlastFont fontSize: kPercentageBlastFontSize];
	scoreBlast.position = p;
	scoreBlast.scale = startScale;
	scoreBlast.opacity = 255.0;
//	scoreBlast.spacing = -70;
//	scoreBlast.color = kWhiteColor;
	[self addChild: scoreBlast z: 1000];
	
	[scoreBlast runAction: [CCSequence actions: 
							
							[CCScaleTo actionWithDuration: 0.4 scale: endScale],
							[CCCallFunc actionWithTarget: scoreBlast selector: @selector(dispose)], 
							nil]];
	
	//	[scoreBlast runAction: [CCSequence actions: 
	//							
	//							[CCFadeIn actionWithDuration: 0.2],
	//							[CCFadeTo actionWithDuration: 0.2 opacity: 0.0], 
	//							nil]];
	
//	CCLabelTTF *scoreBlast2 = [CCLabelTTF labelWithString: scoreStr fontName: kPercentageBlastFont fontSize: kPercentageBlastFontSize];
//	scoreBlast2.position = p;
//	scoreBlast2.scale = 0.4;
//	scoreBlast2.opacity = 255.0;
//	scoreBlast2.color = kBlackColor;
//	[self addChild: scoreBlast2 z: 999];
//	
//	[scoreBlast2 runAction: [CCSequence actions: 
//							 
//							 [CCScaleTo actionWithDuration: 0.4 scale: 1.0],
//							 [CCCallFunc actionWithTarget: scoreBlast2 selector: @selector(dispose)], 
//							 nil]];
	
	//	[scoreBlast2 runAction: [CCSequence actions: 
	//							
	//							[CCFadeIn actionWithDuration: 0.2],
	//							[CCFadeTo actionWithDuration: 0.2 opacity: 0.0], 
	//							nil]];
	
}


-(void)gameOverBlastAfterDelay: (NSTimeInterval)delay
{
	NSString *gameOverStr = [NSString stringWithFormat: @"GAME OVER"];
	CCLabelTTF *gameOverBlast = [CCLabelTTF labelWithString: gameOverStr fontName: kGameOverBlastFont fontSize: [GParams gameOverFontSize] ];
	CGPoint p1 = kGameScreenCenterPoint;
	p1.y += 40;
	gameOverBlast.position = p1;
	gameOverBlast.scale = 0.0;
	gameOverBlast.opacity = 255.0;
	gameOverBlast.color = kWhiteColor;
	[self addChild: gameOverBlast z: 100001];
		
	[gameOverBlast runAction: [CCSequence actions: 
							[CCDelayTime actionWithDuration: delay],
							[CCScaleTo actionWithDuration: 0.33 scale: 1.0],
							//[CCDelayTime actionWithDuration: 1.66],
							//[CCScaleTo actionWithDuration: 0.33 scale: 0.0],
							//[CCCallFunc actionWithTarget: gameOverBlast selector: @selector(dispose)], 
							nil]];
	
	NSString *scoreStr = [NSString stringWithFormat: @"SCORE: %d", score];
	CCLabelTTF *finalScoreLabel = [CCLabelTTF labelWithString: scoreStr fontName: kHUDFont fontSize: [GParams HUDFontSize]];
	finalScoreLabel.opacity = 0.0f;
	CGPoint p = kGameScreenCenterPoint;
	if (IPAD)
		p.y -= 60;
	else
		p.y -= 10;
	finalScoreLabel.color = kWhiteColor;
	finalScoreLabel.position = p;
	[self addChild: finalScoreLabel z: 100002];
	
	[finalScoreLabel runAction: [CCSequence actions: 
							   [CCDelayTime actionWithDuration: delay + 0.33],
							   [CCFadeIn actionWithDuration: 0.33],
							   //[CCDelayTime actionWithDuration: 1.66],
							   //[CCScaleTo actionWithDuration: 0.33 scale: 0.0],
							   //[CCCallFunc actionWithTarget: gameOverBlast selector: @selector(dispose)], 
							   nil]];
	
}

-(void)noteBlastAtPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay
{
	//♪♪♫
	
	CCLabelTTF *noteBlast = [CCLabelTTF labelWithString: @"♫" fontName: kNoteBlastFont fontSize: kNoteBlastFontSize];
	noteBlast.position = p;
	noteBlast.scale = 0.0;
	noteBlast.opacity = 255.0;
	noteBlast.color = kBlackColor;
	[self addChild: noteBlast z: 1001];
	
	[noteBlast runAction: [CCSequence actions: 
							   [CCDelayTime actionWithDuration: delay],
								[CCMoveBy actionWithDuration: 1.0 position: ccp(0, 200)],
							   [CCDelayTime actionWithDuration: 1.33],
							   //[CCScaleTo actionWithDuration: 0.33 scale: 0.0],
							   [CCCallFunc actionWithTarget: noteBlast selector: @selector(dispose)], 
							   nil]];
}

#pragma mark -
#pragma mark Shapes and Physics

-(Shape *)createShapeAtPoint: (CGPoint)p forTouch: (UITouch *)touch
{
	if ([shapes count] == kMaxShapes)
	{
		CCLOG(@"Max shape count reached");
		return nil;
	}
	
	CCLOG(@"Creating shape at point %f,%f", p.x,p.y);
	
	// Create shape and add it to scene
	Shape *shape = [[[currentShapeClass alloc] init] autorelease];
	shape.position = p;
	shape.touch = touch;
	[shape addToSpace: space];
	[shapes addObject: shape];
	[self addChild: shape z: 98];
	
	return shape;
	//[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch:1.0f pan:0.0f gain:0.3f];
}

-(void)endExpansionOfShape: (Shape *)shape
{	
	// Failure, shape too small
	if (shape.size < kMinimumShapeSize)
	{
		CCLOG(@"Shape is less than minimum size, removing");
		shape.destroyed = YES;
		shape.ended = NOW;
		
		if (SOUND_ENABLED)
			[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch:0.891 pan:0.0f gain:0.3f];
	}
	else
	{
		CCLOG(@"Successful expansion");
		shape.expanding = NO;
		shape.fullSize = shape.size;

		int filledSq = [surface updateWithShape: shape];
	
		//CCLOG([surface description]);
		
		shape.cpShape->collision_type = 0;
		
		//
		//int value = (filledSq + (level * 20)) * (float)shape.fullSize/100;
		float sqDivisor = IPAD ? 30 : 10;
		float value = (float) filledSq / sqDivisor;
		if (filledSq == 0)
			value = 0;
		else if (value < 1)
			value = 1;
		
		if (value)
			value += level;
		
		float divisor = IPAD ? 320 : 80;
		float mult = (float)shape.fullSize/divisor;
		if (mult < 1.0f)
			mult = 1.0f;
		
		value *= mult;
		
		
//		CCLOG(@"Score filledSq: %d + shapesize: %f, level: %d", filledSq, (float)shape.fullSize/100, level);
		CCLOG(@"Value: %f", value);
		score += value;
		
		[bgRenderTexture drawShape: shape];
		
//		[bgRenderTexture begin];
//		[currentShape drawFilledShape];
//		[bgRenderTexture end];
		
		percentageFilled = [surface percentageFilled];
		
		[self updateScore];
		[self percentageBlast: percentageFilled atPoint: shape.position];
		
		int size = shape.size;
		int index = size % 7;
		float pitch = [Instrument bluesPitchForIndex: index];
		if (SOUND_ENABLED)
			[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch: pitch pan:0.0f gain:0.3f];
	}

}

-(void)removeShape: (Shape *)shape
{
	if (shape != nil)
	{
		CCLOG(@"Removing shape at point %f,%f", shape.position.x,shape.position.y);
		cpSpaceRemoveBody(space, shape.cpBody);
		cpBodyDestroy(shape.cpBody);
		cpBodyFree(shape.cpBody);
		
		cpShapeDestroy(shape.cpShape);
		cpShapeFree(shape.cpShape);
		cpSpaceRemoveShape(space, shape.cpShape);
		
		[shapes removeObjectIdenticalTo: shape];
		[self removeChild: shape cleanup: YES];
	}
}

-(void)addBouncingBallAtPoint: (CGPoint)p withVelocity: (CGPoint)movementVector
{
	BouncingBall *bounceBall = [BouncingBall spriteWithFile: [GParams spriteFileName: kBouncingBallSprite]];
	bounceBall.size = IPAD ? 40: 20;
	bounceBall.position = p;
	bounceBall.opacity = 0.0f;
	[bounceBall runAction: [CCFadeIn actionWithDuration: 0.15]];
	
	[bounceBall addToSpace: space];
	[bounceBall pushWithVector: movementVector];
	
	[bounceBalls addObject: bounceBall];
	
	[self addChild: bounceBall];
}

-(void)removeAllShapes
{
	// Clear all shapes from our databank
	for (int i = [shapes count]-1; i >= 0; i--)
	{
		[self removeShape: [shapes objectAtIndex: i]];
	}
	
	// Remove bouncing balls
	for (BouncingBall *b in bounceBalls)
		[self removeShape: (Shape *)b]; // this is dirty
	
	[shapes removeAllObjects];
	[bounceBalls removeAllObjects];
}

#pragma mark -
#pragma mark Level transitions / Game state changes

-(void)startGame
{
		inTransition = YES;
		[self levelBlast: level atPoint: kGameBoxCenterPoint afterDelay: 1.0];
		[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(startLevel)] withDelay: 3.1]];;
}

-(void)startLevel
{	
	// Set mana bar increase flow going
	mana = newMana;
	[self unschedule: @selector(manaIncreaseTicker:)];
	
	// Decide on number of balls for level
	
	int numBalls = 0;
	
	if (level <= 4)
		numBalls = 1;
	else if (level >= 5 && level < 10)
		numBalls = 2;
	else if (level >= 10)
		numBalls = 1 + (level / 5);	
	
	if (numBalls > kMaxBounceBalls)
		numBalls = kMaxBounceBalls;
	
	// Decide how much energy is in the physical system
	
	float energy = 13500 + (level * 2900);

	float energyPerBall = energy / (numBalls - (numBalls * 0.10));
	
	// Create the balls and set them going
	for (int i = 0; i < numBalls; i++)
	{
		// Define starting point
		CGPoint startingPoint = kGameScreenCenterPoint;
		int mod = RandomBetween(0, 1);
		mod = mod ? -1 : 1;
		
		startingPoint.x += (mod * 35 + RandomBetween(5, 10)) * i;
		startingPoint.y += (mod * 25 + RandomBetween(5, 10)) * i;
		
		// Define movement vector
		float x = RandomBetween(0, energyPerBall);
		float y = energyPerBall - x;
		
		float xmod = RandomBetween(0, 1);
		xmod = xmod ? -1 : 1;
		x *= xmod;
		
		float ymod = RandomBetween(0, 1);
		ymod = mod ? -1 : 1;
		y *= ymod;
		
		if (IPAD)
		{
			y *= 2.13;
			x *= 2.13;
		}
		
//		float x = (5800 + (level * 700 ) - (numBalls * 2200)) * mod;
//		float y = (5800 + (level * 700 ) - (numBalls * 2200)) * mod;
		
		// Add ball
		[self addBouncingBallAtPoint: startingPoint withVelocity: cpv(x,y)];
	}
	
	[self updateLevel];
	
	[self runAction: [CCCallFunc actionWithTarget: self selector: @selector(endTransition)]];
}

-(void)advanceLevel
{
	inTransition = YES;
	
	// CHECK FOR ACHIEVEMENTS
	
	if (flawless)
	{
		switch ([shapes count])
		{
			case 1:
			{
				CCLOG(@"Finished w. one shape");
				[ScoreManager reportAchievementWithIdentifier: kGameCenterLevelInOneAchievement];
			}
			break;
				
			case 2:
			{
				CCLOG(@"Finished w. two shapes");
				[ScoreManager reportAchievementWithIdentifier: kGameCenterLevelInTwoAchievement];
			}
			break;
				
			case 3:
			{
				CCLOG(@"Finished w. three shapes");
				[ScoreManager reportAchievementWithIdentifier: kGameCenterLevelInThreeAchievement];
			}
			break;
		}
	}
	
	
	
	[self removeAllShapes];
		
	// Clear surface
	[bgRenderTexture clear];
	[surface clear]; 
	
	level += 1;
	
	// Check for level achievements
	switch (level)
	{
		case 5:
		{
			CCLOG(@"Got to level 5");
			[ScoreManager reportAchievementWithIdentifier: kGameCenterLevel5Achievement];
		}
		break;
			
		case 10:
		{
			CCLOG(@"Got to level 10");
			[ScoreManager reportAchievementWithIdentifier: kGameCenterLevel10Achievement];
		}
		break;
			
		case 15:
		{
			CCLOG(@"Got to level 15");
			[ScoreManager reportAchievementWithIdentifier: kGameCenterLevel15Achievement];
		}
		break;
			
		case 20:
		{
			CCLOG(@"Got to level 20");
			[ScoreManager reportAchievementWithIdentifier: kGameCenterLevel20Achievement];
		}
		break;
			
		case 25:
		{
			CCLOG(@"Got to level 25");
			[ScoreManager reportAchievementWithIdentifier: kGameCenterLevel25Achievement];
		}
		break;
	}
	
	if (percentageFilled >= 95.0f)
	{
		CCLOG(@"Got to level 25");
		[ScoreManager reportAchievementWithIdentifier: kGameCenterOverkillAchievement];
	}

	percentageFilled = 0.0f;
	
	if (flawless)
		[ScoreManager reportAchievementWithIdentifier: kGameCenterFlawlessAchievement];
		
	// Add to time
	timeRemaining += kTimePerLevel;
	[self updateTimer];
	
	oldMana = mana;
	newMana = mana + kManaPerLevel;
	if (newMana > kFullMana)
		newMana = kFullMana;
	
	manaIncreaseTime = NOW;
	[self schedule: @selector(manaIncreaseTicker:) interval: 1.0/60];
	
	[piano playWithInterval: 0.22 afterDelay: 0 chords: @"1,2,5", @"1,2,5", @"1,2,4", @"1,2,3", nil];
		
	[self levelBlast: level atPoint: kGameBoxCenterPoint afterDelay: 1.0];
	[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(startLevel)] withDelay: 3.1]];;
}

-(int)currentLevel
{
	return level;
}

-(void)gameOver
{
	inTransition = YES;
	gameOver = YES;
	
	[self removeAllShapes];
	
	// Unschedule tickers
	
	[self unschedule: @selector(tick:)];
	[self unschedule: @selector(step:)];
	[self unschedule: @selector(timeTicker:)];
	
	//[bgRenderTexture goBlack];
	gameOverCircle = [[[GameOverCircle alloc] init] autorelease];
	gameOverCircle.position = kGameScreenCenterPoint;
	[self addChild: gameOverCircle z: 100000];
	[gameOverCircle runAction: [CCSequence actions:	[CCDelayTime actionWithDuration: 0.1],
												[CCCallFunc actionWithTarget: gameOverCircle selector: @selector(startExpanding)],
						  nil]];
	
	[piano playWithInterval: 0.4 afterDelay: 0 chords: @"1,2,5", @"1,2,5", @"1,2,5", @"1,2,4", @"1,2,4", @"1,2,3", @"1,2,3", nil]; 
	[self gameOverBlastAfterDelay: 0.2];
	
	// Submit score to Game Center
	if ([GameCenterManager isGameCenterAvailable] && GAMECENTER_ENABLED)
		[[GameCenterManager sharedManager] authenticateLocalUserAndReportScore: score level: level];
	
	
	[self runAction: [CCSequence actions:
					  
					  [CCDelayTime actionWithDuration: 1.2],
					  [CCCallFunc actionWithTarget: self selector: @selector(endTransition)],
					  
					  nil]];
}

-(void)collision
{
	flawless = NO;
}

-(void)endTransition
{
	inTransition = NO;
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{	
	if (inTransition || tutorialStep != kTutorialStepNone)
		return;
	
	if (gameOver)
	{
		[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInL transitionWithDuration: 0.35 scene: [MainMenuScene scene]]];
		return;
	}
	
	NSArray *tchs = [touches allObjects];
	
	for (UITouch *touch in tchs)
	{
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		if (multiPlayer)
		{
			if (ccpDistance(location, [GParams multiPlayerSrcBallPoint1]) <  [GParams multiPlayerSrcBallRadius])
			{
				Shape *s = [self createShapeAtPoint: location forTouch: touch];
				s.owner = kPlayer1;
				s.color = ccc3(0,100,0);
				s.opacity = 200;
			}
			else if (ccpDistance(location, [GParams multiPlayerSrcBallPoint2]) <  [GParams multiPlayerSrcBallRadius])
			{
				Shape *s = [self createShapeAtPoint: location forTouch: touch];
				s.owner = kPlayer2;
				s.color = ccc3(0,0,100);
				s.opacity = 200;
			}
		}
		else
		{
			if (CGRectContainsPoint(kGameBoxRect, location))
			{
				[self createShapeAtPoint: location forTouch: touch];
			}
		}
	}
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (inTransition || !multiPlayer)
		return;

	NSArray *tchs = [touches allObjects];
	
	for (UITouch *touch in tchs)
	{
		for (Shape *s in shapes)
		{
			if (touch == s.touch && s.expanding && !s.destroyed)
			{
				CGPoint location = [touch locationInView: [touch view]];
				location = [[CCDirector sharedDirector] convertToGL: location];
				
				s.position = location;
				s.cpBody->p = location;
				//[s setPosition: location];
			}
		}
	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{			
	if (inTransition || gameOver)
		return;
	
	if (tutorialStep != kTutorialStepNone)
	{
		tutorialStep += 1;
		[self showTutorialStep: tutorialStep];
	}
	
	NSArray *tchs = [touches allObjects];
	
	for (UITouch *touch in tchs)
	{
		for (int i = [shapes count]-1; i >= 0; i--)
		{
			Shape *s = [shapes objectAtIndex: i];
			
			if (touch == s.touch && s.expanding && !s.destroyed)
			{
				[self endExpansionOfShape: s];
			}
		}
	}
}

@end
