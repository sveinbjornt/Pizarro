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

#pragma mark Chipmunk Callbacks

int lastPlayedIndex = 0;

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
	
	lastPlayedIndex += mod;
	while (lastPlayedIndex < 1)
		lastPlayedIndex = 7 + lastPlayedIndex;
	while (lastPlayedIndex > 7)
		lastPlayedIndex = 1 + (lastPlayedIndex - 8);
	
	[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"piano%d.wav", lastPlayedIndex] pitch:1.0f pan:0.0f gain:0.1f];
	
}


static void CollisionBallExpansionCircle (cpArbiter *arb, cpSpace *space, void *data)
{
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	Shape *shape = b->data;
	shape.destroyed = YES;
	
	if (SOUND_ENABLED)
		[[SimpleAudioEngine sharedEngine] playEffect: kTrumpetSoundEffect pitch:0.891 pan:0.0f gain:0.3f];	
}

static void CollisionBallAndCircleOrWall (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	PlayBallCollisionSound([scene currentLevel]+1);
	
}

static void CollisionBallAndBall (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	PlayBallCollisionSound([scene currentLevel]+1);
	PlayBallCollisionSound([scene currentLevel]+2);
}

#pragma mark -

// HelloWorld implementation
@implementation PizarroGameScene

#pragma mark -
#pragma mark Instantiation

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PizarroGameScene *layer = [PizarroGameScene layerWithColor: ccc4(255,255,255,255)];
	
	[layer setColor: kWhiteColor];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
	cpSpaceFree(space);
	[bounceBalls release];
	[shapeKinds release];
	[surface release];
	[shapes release];
	[piano release];
	[self removeAllChildrenWithCleanup: YES];
	[super dealloc];
}

- (id)initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	if ((self = [super initWithColor: color width: w height: h])) 
	{		
		// White, touch-sensitive layer
		self.isTouchEnabled = YES;
		self.color = kWhiteColor;
		self.opacity = 255;
		
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
	
	timeRemaining = kStartingTime;
	gameOver = NO;
	currShapeIndex = 0;
	currentShapeClass = [Circle class];//[Circle class];
	shapeKinds = [[NSArray arrayWithObjects: [Circle class], [Square class], [Triangle class], nil] retain];
}

-(void)setupHUD
{	
	// BACKGROUND
	CCSprite *bg = [CCSprite spriteWithFile: kGameScreenBackgroundSprite];
	bg.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	bg.position = kGameScreenCenterPoint;
	[self addChild: bg z: 100];	
	
	// game backing texture
	bgRenderTexture = [BGRenderTexture renderTextureWithWidth: kGameBoxWidth height: kGameBoxHeight];
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
	CCLabelTTF *scoreL = [CCLabelTTF labelWithString: @"SCORE" dimensions:CGSizeMake(140,40) alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: kHUDFontSize];
	scoreL.color = ccc3(0,0,0);
	scoreL.position =  ccp(133, 300);
	[self addChild: scoreL z: 1001];
	
	[self updateScore];
	
	// MANA BAR
	manaBar = [[[ManaBar alloc] init] autorelease];
	manaBar.position = ccp(4,7);
	manaBar.percentage = 0.0f;
	[self addChild: manaBar z: 99];
	
	// Pause button
	CCMenuItemSprite *pauseMenuItem = [CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: kInGameMenuButtonOffSprite] 
															  selectedSprite: [CCSprite spriteWithFile: kInGameMenuButtonOnSprite] 
																	  target: self 
																	selector: @selector(pauseGame)];
	pauseMenu = [CCMenu menuWithItems: pauseMenuItem, nil];
	pauseMenu.position = kMenuPauseButtonPoint;
	[self addChild: pauseMenu z: 10002];
}

-(void)pauseGame
{	
	[[CCDirector sharedDirector] pushScene: [CCTransitionSlideInL transitionWithDuration: 0.35 scene: [MainMenuScene scenePausedForScene: (CCScene *)self.parent]]];	
}

-(void)setupGame
{
	//surface matrix
	surface = [[SurfaceMatrix alloc] init];
	
	// Array of objects
	shapes = [[NSMutableArray alloc] initWithCapacity: kMaxShapes];
	bounceBalls = [[NSMutableArray alloc] initWithCapacity: kMaxBounceBalls];
	
	// Timers
	[self schedule: @selector(tick:) interval: 1.0/60];
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
	cpBody* floorBody = cpBodyNew(kWallMass, kWallInertia);
	
	floorBody->p = cpv(0, 0);
	
	lp1 = cpv(kGameBoxXOffset - kWallThickness, 
			  kGameBoxYOffset - kWallThickness);
	lp2 = cpv(kGameBoxXOffset + kGameBoxWidth + kWallThickness, 
			  kGameBoxYOffset- kWallThickness);
	
	cpShape* floorShape = cpSegmentShapeNew(floorBody, lp1, lp2, kWallThickness);
	
	floorShape->e = kWallElasticity;
	floorShape->u = kWallFriction;
	floorShape->collision_type = kWallCollisionType;
	floorShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, floorShape);
	
	
	
	// Ceiling
	cpBody* ceilingBody = cpBodyNew(kWallMass, kWallInertia);
	
	ceilingBody->p = cpv(0, 0);
	
	lp1 = cpv(kGameBoxXOffset - kWallThickness, 
			  kGameBoxYOffset + kGameBoxHeight + kWallThickness );
	lp2 = cpv(kGameBoxXOffset + kGameBoxWidth + kWallThickness, 
			  kGameBoxYOffset + kGameBoxHeight + kWallThickness);
	
	cpShape* ceilingShape = cpSegmentShapeNew(ceilingBody, lp1, lp2, kWallThickness);
	
	ceilingShape->e = kWallElasticity;
	ceilingShape->u = kWallFriction;
	ceilingShape->collision_type = kWallCollisionType;
	ceilingShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, ceilingShape);
	
	
	
	// Left side
	
	cpBody* leftBody = cpBodyNew(kWallMass, kWallInertia);
	
	leftBody->p = cpv(0, 0);
	
	lp1 = cpv(kGameBoxXOffset - kWallThickness, 
			  kGameBoxYOffset - kWallThickness );
	lp2 = cpv(kGameBoxXOffset - kWallThickness, 
			  kGameBoxYOffset + kGameBoxHeight + kWallThickness);
	
	cpShape* leftShape = cpSegmentShapeNew(leftBody, lp1, lp2, kWallThickness);
	
	leftShape->e = kWallElasticity;
	leftShape->u = kWallFriction;
	leftShape->collision_type = kWallCollisionType;
	leftShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, leftShape);
	
	
	
	// Right side
	
	cpBody* rightBody = cpBodyNew(kWallMass, kWallInertia);
	
	rightBody->p = cpv(0, 0);
	
	lp1 = cpv(kGameBoxXOffset + kGameBoxWidth + kWallThickness, 
			  kGameBoxYOffset - kWallThickness );
	lp2 = cpv(kGameBoxXOffset + kGameBoxWidth + kWallThickness, 
			  kGameBoxYOffset + kGameBoxHeight + kWallThickness);
	
	cpShape* rightShape = cpSegmentShapeNew(rightBody, lp1, lp2, kWallThickness);
	
	rightShape->e = kWallElasticity;
	rightShape->u = kWallFriction;
	rightShape->collision_type = kWallCollisionType;
	rightShape->group = kWallShapeGroup;
	
	cpSpaceAddStaticShape(space, rightShape);
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
			
			CCSprite *bball = [CCSprite spriteWithFile: kBouncingBallSprite];
			
			
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
			NSString *expl = @"If you run out of energy (left) or time (top right), you lose the game.\nEvery time you complete a level, you get more energy and time.";
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
			NSString *expl = @"\nYou should now be ready to play.";
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
												   fontSize: kWelcomeToPizarroFontSize];
			
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
			tutorialOver = YES;
			tutorialStep = kTutorialStepNone;
			[self startGame];
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
//	[self removeChild: levelLabel cleanup: YES];
//	
//	NSString *levelStr = [NSString stringWithFormat: @"%d", level];
//	levelLabel = [CCLabelTTF labelWithString: levelStr fontName: kHUDFont fontSize: kHUDFontSize];
//	levelLabel.color = ccc3(255,255,255);
//	levelLabel.position =  ccp(14 , 304 );
//	[self addChild: levelLabel z: 1001];
}

-(void)updateScore
{
	[self removeChild: scoreLabel cleanup: YES];
	
	NSString *scoreStr = [NSString stringWithFormat: @"%.06d", score];
	scoreLabel = [CCLabelTTF labelWithString: scoreStr dimensions:CGSizeMake(160,40) alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: kHUDFontSize];
	scoreLabel.color = kBlackColor;
	scoreLabel.position =  ccp(262, 300 );
	[self addChild: scoreLabel z: 1001];
}

-(void)updateTimer
{
	[self removeChild: timeLabel cleanup: YES];
		
	int min, sec;
	min = timeRemaining/60;
	sec = timeRemaining - (min*60);
		
	NSString *timeStr = [NSString stringWithFormat: @"%.2d:%.2d", min, sec];
	timeLabel = [CCLabelTTF labelWithString: timeStr dimensions:CGSizeMake(110,40) alignment: UITextAlignmentLeft fontName: kHUDFont fontSize: kHUDFontSize];
	
	if (timeRemaining > kTimeLow)
		timeLabel.color = kBlackColor; // black
	else
		timeLabel.color = ccc3(180,0,0); // red
	
	timeLabel.position =  ccp(415, 300);
	[self addChild: timeLabel z: 1001];	
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
	
//	if (currentCircle != nil)
//		ccDrawPoint(currentCircle.position);
	
	//[self drawGameSquare];
//	glDisable(GL_TEXTURE_2D);
//	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//	glDisableClientState(GL_COLOR_ARRAY);
//
//	
//	for (int x = 0; x < kMatrixWidth; x++)
//	{
//		for (int y = 0; y < kMatrixHeight; y++)
//		{
//			if (matrix[x][y] == 1)
//			{
//				glColor4ub(255,0,0,255);
//			}
//			else
//				glColor4ub(0,0,255,255);
//			
//			CGPoint p = CGPointMake((x * kMatrixUnitSize) + kGameBoxXOffset, (y * kMatrixUnitSize) + kGameBoxYOffset);
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
	
	currentShapeClass = [Circle class];//[shapeKinds objectAtIndex: currShapeIndex];
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
	if (inTransition || tutorialStep != kTutorialStepNone)
		return;
	
	// OK, let's check if we're advancing up level
	if (percentageFilled >= kSurfaceReqPerLevel)
	{
		inTransition = YES;
		
		// Give bonus points for each additional percentage point covered
		
		float extraPerc = percentageFilled - kSurfaceReqPerLevel;
		int bonus = extraPerc * 10 + level;
		score += bonus;
		
		Shape *lastShape = [shapes lastObject];
		[self noteBlastAtPoint: lastShape.position afterDelay: 0.1];
		
		[self runAction: [CCSequence actions:
						  [CCDelayTime actionWithDuration: 0.15],
						  [CCCallFunc actionWithTarget: self selector: @selector(advanceLevel)], nil]];
		
		return;
	}
	
	if (mana <= 0 || timeRemaining <= 0)
	{
		// OK, he's out of time or mana, but if he's currenlty covering enough area,
		// then we let it slide
		
		BOOL addedShape = NO;
		for (Shape *shape in shapes)
		{
			if (shape.expanding && !shape.destroyed)
			{
				[self endExpansionOfShape: shape];
				addedShape = YES;
			}
		}
		
		if (!addedShape)
			[self gameOver];
		
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
			NSTimeInterval timeSinceTouch = NOW - currentShape.created;
			currentShape.size = timeSinceTouch * kCircleExpansionDiameterPerSecond;
			
			mana -= 1.0f/60.0f;
			manaBar.percentage = (float)mana/kFullMana;
			
			cpCircleShape *sh = (cpCircleShape *)currentShape.cpShape;
			sh->r = currentShape.size/2;
		
		}
	}
	
	// Update physics engine
	cpSpaceStep(space, 1.0f/60.0f);
	cpSpaceHashEach(space->activeShapes, &UpdateShape, nil);
}

#pragma mark -
#pragma mark Blast

-(void)levelBlast: (NSUInteger)lvl atPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay
{
	NSString *levelStr = [NSString stringWithFormat: @"Level %d", lvl];
	CCLabelTTF *levelBlast = [CCLabelTTF labelWithString: levelStr fontName: kLevelBlastFont fontSize: kLevelBlastFontSize];
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
	CCLabelTTF *scoreBlast = [CCLabelTTF labelWithString: scoreStr fontName: kPercentageBlastFont fontSize: kPercentageBlastFontSize];
	scoreBlast.position = p;
	scoreBlast.scale = 0.4;
	scoreBlast.opacity = 255.0;
	scoreBlast.color = kWhiteColor;
	[self addChild: scoreBlast z: 1000];
	
	[scoreBlast runAction: [CCSequence actions: 
							
							[CCScaleTo actionWithDuration: 0.4 scale: 1.0],
							[CCCallFunc actionWithTarget: scoreBlast selector: @selector(dispose)], 
							nil]];
	
	//	[scoreBlast runAction: [CCSequence actions: 
	//							
	//							[CCFadeIn actionWithDuration: 0.2],
	//							[CCFadeTo actionWithDuration: 0.2 opacity: 0.0], 
	//							nil]];
	
	CCLabelTTF *scoreBlast2 = [CCLabelTTF labelWithString: scoreStr fontName: kPercentageBlastFont fontSize: kPercentageBlastFontSize];
	scoreBlast2.position = p;
	scoreBlast2.scale = 0.4;
	scoreBlast2.opacity = 255.0;
	scoreBlast2.color = kBlackColor;
	[self addChild: scoreBlast2 z: 999];
	
	[scoreBlast2 runAction: [CCSequence actions: 
							 
							 [CCScaleTo actionWithDuration: 0.4 scale: 1.0],
							 [CCCallFunc actionWithTarget: scoreBlast2 selector: @selector(dispose)], 
							 nil]];
	
	//	[scoreBlast2 runAction: [CCSequence actions: 
	//							
	//							[CCFadeIn actionWithDuration: 0.2],
	//							[CCFadeTo actionWithDuration: 0.2 opacity: 0.0], 
	//							nil]];
	
}


-(void)gameOverBlastAfterDelay: (NSTimeInterval)delay
{
	NSString *gameOverStr = [NSString stringWithFormat: @"GAME OVER"];
	CCLabelTTF *gameOverBlast = [CCLabelTTF labelWithString: gameOverStr fontName: kGameOverBlastFont fontSize: kGameOverBlastFontSize];
	gameOverBlast.position = kGameBoxCenterPoint;
	gameOverBlast.scale = 0.0;
	gameOverBlast.opacity = 255.0;
	gameOverBlast.color = kWhiteColor;
	[self addChild: gameOverBlast z: 1000];
		
	[gameOverBlast runAction: [CCSequence actions: 
							[CCDelayTime actionWithDuration: delay],
							[CCScaleTo actionWithDuration: 0.33 scale: 1.0],
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

-(void)createShapeAtPoint: (CGPoint)p forTouch: (UITouch *)touch
{
	if ([shapes count] == kMaxShapes)
	{
		CCLOG(@"Max shape count reached");
		return;
	}
	
	CCLOG(@"Creating shape at point %f,%f", p.x,p.y);
	
	// Create shape and add it to scene
	Shape *shape = [[[currentShapeClass alloc] init] autorelease];
	shape.position = p;
	shape.touch = touch;
	[shape addToSpace: space];
	[shapes addObject: shape];
	[self addChild: shape z: 98];
		
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
		int value = filledSq / 10;
		if (!value)
			value = 1;
		value += level;
		value *= (float)shape.fullSize/100;
		
		
//		CCLOG(@"Score filledSq: %d + shapesize: %f, level: %d", filledSq, (float)shape.fullSize/100, level);
		CCLOG(@"Value: %d", value);
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
	BouncingBall *bounceBall = [BouncingBall spriteWithFile: kBouncingBallSprite];
	bounceBall.size = 20;
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
#pragma mark Level transitions

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
	
	float energy = 6000 + (level * 1200);
	float energyPerBall = energy / (numBalls - (numBalls * 0.08));
	
	// Create the balls and set them going
	for (int i = 0; i < numBalls; i++)
	{
		// Define starting point
		CGPoint startingPoint = kGameScreenCenterPoint;
		int mod = RandomBetween(0, 1);
		mod = mod ? -1 : 1;
		
		startingPoint.x += (mod * 25 + RandomBetween(5, 10)) * i;
		startingPoint.y += (mod * 15 + RandomBetween(5, 10)) * i;
		
		// Define movement vector
		float x = RandomBetween(0, energyPerBall);
		float y = energyPerBall - x;
		
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
	
	[self removeAllShapes];
		
	// Clear surface
	[bgRenderTexture clear];
	[surface clear]; 
	
	level += 1;
	percentageFilled = 0.0f;
	
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
	
	//[bgRenderTexture goBlack];
	gameOverCircle = [[[GameOverCircle alloc] init] autorelease];
	gameOverCircle.position = kGameBoxCenterPoint;
	[self addChild: gameOverCircle z: 90];
	[gameOverCircle runAction: [CCSequence actions:	[CCDelayTime actionWithDuration: 0.1],
												[CCCallFunc actionWithTarget: gameOverCircle selector: @selector(startExpanding)],
						  nil]];
	
	[piano playWithInterval: 0.4 afterDelay: 0 chords: @"1,2,5", @"1,2,5", @"1,2,5", @"1,2,4", @"1,2,4", @"1,2,3", @"1,2,3", nil]; 
	[self gameOverBlastAfterDelay: 0.2];
	
	// Submit score to Game Center
	if ([GameCenterManager isGameCenterAvailable] && GAMECENTER_ENABLED)
		[[GameCenterManager sharedManager] authenticateLocalUserAndReportScore: score level: level];
	
//	[self runAction: [CCSequence actions:
//					  
//					  [CCDelayTime actionWithDuration: 2.5],
//					  [CCCallFuncO actionWithTarget: [CCDirector sharedDirector] 
//										   selector: @selector(replaceScene:) 
//											 object: [CCTransitionSlideInL transitionWithDuration: 0.35 scene: [MainMenuScene scene]]],
//					  nil]];
	 
	
}

-(void)endTransition
{
	inTransition = NO;
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if (gameOver)
		[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInL transitionWithDuration: 0.35 scene: [MainMenuScene scene]]];
		
	if (inTransition || tutorialStep != kTutorialStepNone)
		return;
	
	NSArray *tchs = [touches allObjects];
	
	for (UITouch *touch in tchs)
	{
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL: location];
		
		if (CGRectContainsPoint(kGameBoxRect, location))
		{
			[self createShapeAtPoint: location forTouch: touch];
		}
	}
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
//	if (inTransition)
//		return;
//	
//	NSArray *tchs = [touches allObjects];
//	
//	for (UITouch *touch in tchs)
//	{
//		for (Shape *s in shapes)
//		{
//			if (touch == s.touch && s.expanding && !s.destroyed && NOW - s.created > 0.5f)
//			{
//				CGPoint location = [touch locationInView: [touch view]];
//				location = [[CCDirector sharedDirector] convertToGL: location];
//				
//				if (ccpDistance(s.position, location) > s.size/2)
//					[self endExpansionOfShape: s];
//			}
//		}
//	}
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{			
	if (inTransition)
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
