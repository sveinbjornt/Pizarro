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

#pragma mark Chipmunk Callbacks

int lastPlayedIndex = 0;

void UpdateShape(void* ptr, void* unused)
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

static void CollisionBallExpansionCircle (cpArbiter *arb, cpSpace *space, void *data)
{
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	Shape *shape = b->data;
	shape.destroyed = YES;
	
	[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch:0.891 pan:0.0f gain:0.3f];
	
	NSLog(@"Collision");
}

static void CollisionBallAndCircleOrWall (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	int lvl = [scene currentLevel]+1;
	
	int mod = RandomBetween(-lvl, lvl);
	
	lastPlayedIndex += mod;
	if (lastPlayedIndex < 1)
		lastPlayedIndex = 7 + lastPlayedIndex;
	if (lastPlayedIndex > 7)
		lastPlayedIndex = 1 + (lastPlayedIndex - 8);
	
	//[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", lastPlayedIndex]];
	[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"piano%d.wav", lastPlayedIndex] pitch:1.0f pan:0.0f gain:0.1f];
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
	
	[layer setColor: ccc3(255,255,255)];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) dealloc
{
	[bounceBalls release];
	[shapeKinds release];
	[surface release];
	[shapes release];
	[piano release];
	[super dealloc];
}

- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	if( (self=[super initWithColor: color width: w height: h]) ) 
	{		
		// White, touch-sensitive layer
		self.isTouchEnabled = YES;
		self.color = ccc3(255,255,255);
		self.opacity = 255;
		
		// Setup
		[self setupGameVariables];
		[self setupHUD];
		[self setupGame];
		[self updateCurrentShape];
		
		// Music and sound
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"bassline.mp3"];
		piano = [[Instrument alloc] initWithName: @"piano" numberOfNotes: 7 tempo: 0.1];
		
		// Go!
		inTransition = YES;
		[self levelBlast: level atPoint: kGameBoxCenterPoint afterDelay: 1.0];
		[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(startLevel)] withDelay: 2.5]];;

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
	mana = kStartingMana;
	timeRemaining = kStartingTime;
	gameOver = NO;
	currShapeIndex = 0;
	currentShapeClass = [Circle class];//[Circle class];
	shapeKinds = [[NSArray arrayWithObjects: [Circle class], [Square class], [Triangle class], nil] retain];
}

-(void)setupHUD
{	
	// BACKGROUND
	CCSprite *bg = [CCSprite spriteWithFile: @"bg.png"];
	bg.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
	bg.position = kGameScreenCenterPoint;
	[self addChild: bg z: 100];
	
	// TIMER
	[self updateTimer];
	
	// LEVEL
	[self updateLevel];
	
	// SCORE
	[self updateScore];
	
	// MANA BAR
	manaBar = [[[ManaBar alloc] init] autorelease];
	manaBar.position = ccp(4,7);
	manaBar.percentage = (float)mana/kFullMana;
	[self addChild: manaBar z: 99];
	
	// Pause button
	pauseMenuItem = [CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"menu_button_black.png"] 
											selectedSprite: [CCSprite spriteWithFile: @"menu_button_white.png"] 
													target: self 
												  selector: @selector(pauseGame)];
	
	pauseMenuItem.position = kMenuPauseButtonPoint;
	//CCMenu *menu = [CCMenu menuWithItems: pauseMenuItem, nil];
	[self addChild: pauseMenuItem z: 10002];
}

-(void)pauseGame
{
	NSLog(@"Paused");
}

-(void)setupGame
{
	//surface matrix
	surface = [[SurfaceMatrix alloc] init];
	
	// game backing texture
	bgRenderTexture = [BGRenderTexture renderTextureWithWidth: kGameBoxWidth height: kGameBoxHeight];
	[bgRenderTexture setPosition: kGameBoxCenterPoint];
	[bgRenderTexture clear];
	//[[bgRenderTexture sprite] setBlendFunc:(ccBlendFunc){GL_ONE, GL_ONE_MINUS_SRC_ALPHA}];
	[self addChild: bgRenderTexture z: 90];
	
	// Array of objects
	shapes = [[NSMutableArray alloc] initWithCapacity: kMaxShapes];
	bounceBalls = [[NSMutableArray alloc] initWithCapacity: kMaxBounceBalls];
	
	// Timers
	[self schedule: @selector(tick:) interval: 1.0/60];
	[self schedule: @selector(timeTicker:) interval: 1.0];
	[self schedule: @selector(symbolTicker:) interval: 2.0];
	
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
	cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, &CollisionBallExpansionCircle, NULL, NULL);  // collision between expanding shape and bouncing ball
	cpSpaceAddCollisionHandler(space, 1, 0, NULL, NULL, &CollisionBallAndCircleOrWall, NULL, self); // collision between finished circles or walls and a bouncing ball
	
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
	
	NSString *scoreStr = [NSString stringWithFormat: @"Score %.05d", score];
	scoreLabel = [CCLabelTTF labelWithString: scoreStr fontName: kHUDFont fontSize: kHUDFontSize];
	scoreLabel.color = ccc3(0,0,0);
	scoreLabel.position =  ccp(175 , 300 );
	[self addChild: scoreLabel z: 1001];
}

-(void)updateTimer
{
	[self removeChild: timeLabel cleanup: YES];
		
	int min, sec;
	min = timeRemaining/60;
	sec = timeRemaining - (min*60);
		
	NSString *timeStr = [NSString stringWithFormat: @"%.2d:%.2d", min, sec];
	timeLabel = [CCLabelTTF labelWithString: timeStr fontName: kHUDFont fontSize: kHUDFontSize];
	
	if (timeRemaining > 30)
		timeLabel.color = ccc3(0,0,0);
	else
		timeLabel.color = ccc3(180,0,0);
	
	timeLabel.position =  ccp(405 , 300 );
	[self addChild: timeLabel z: 1001];	
}

-(void)updateCurrentShape
{
	[self removeChild: shapeLabel cleanup: YES];
		
	shapeLabel = [CCLabelTTF labelWithString: [currentShapeClass textSymbol] fontName: kHUDFont fontSize: [currentShapeClass textSymbolSizeForHUD]];
	shapeLabel.position =  ccp(330, 297);
	shapeLabel.color = ccc3(0,0,0);
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
	if (inTransition)
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

-(void)tick: (ccTime)dt
{
	if (inTransition)
		return;
	
	if (mana <= 0 || timeRemaining <= 0)
	{
		[self gameOver];
		return;
	}
	
	if (currentShape != nil)
	{
		if (currentShape.destroyed)
		{
			NSTimeInterval timeSinceDestroyed = NOW - currentShape.ended;
			NSTimeInterval ttl = 0.3;
			
			float fraction = (float) 1.0 - (timeSinceDestroyed / ttl);
			currentShape.size =  (float)fraction * currentShape.fullSize;
			
			if (currentShape.size <= 1)
			{
				[self removeShape: currentShape];
				currentShape = nil;
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
			currentShape.size = timeSinceTouch * 170;
			
			mana -= 1.0f/60.0f;
			manaBar.percentage = (float)mana/kFullMana;
			
			//[currentShape runAction: [CCRotateBy actionWithDuration: 1.0/60.0f angle: 5.0]];
			
			//cpCircleShapeSetRadius(currentShape.cpShape, currentShape.size/2);
			cpCircleShape *sh = (cpCircleShape *)currentShape.cpShape;
			sh->r = currentShape.size/2;
		
		}
	}
	
	cpSpaceStep(space, 1.0f/60.0f);
	cpSpaceHashEach(space->activeShapes, &UpdateShape, nil);
}

#pragma mark -
#pragma mark Blast

-(void)levelBlast: (NSUInteger)lvl atPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay
{
	NSString *levelStr = [NSString stringWithFormat: @"Level %d", lvl];
	CCLabelTTF *levelBlast = [CCLabelTTF labelWithString: levelStr fontName: @"RedStateBlueState BB" fontSize: 78];
	levelBlast.position = p;
	levelBlast.scale = 0.0;
	levelBlast.opacity = 255.0;
	levelBlast.color = ccc3(0,0,0);
	[self addChild: levelBlast z: 1000];
	
	[piano playWithInterval: 0.3 afterDelay: delay + 0.66 chords: @"1,2,3",  @"1,2,4", @"1,2,5", nil];
	
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
	CCLabelTTF *scoreBlast = [CCLabelTTF labelWithString: scoreStr fontName: @"RedStateBlueState BB" fontSize: 54];
	scoreBlast.position = p;
	scoreBlast.scale = 0.4;
	scoreBlast.opacity = 255.0;
	scoreBlast.color = ccc3(255,255,255);
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
	
	CCLabelTTF *scoreBlast2 = [CCLabelTTF labelWithString: scoreStr fontName: @"RedStateBlueState BB" fontSize: 56];
	scoreBlast2.position = p;
	scoreBlast2.scale = 0.4;
	scoreBlast2.opacity = 255.0;
	scoreBlast2.color = ccc3(0,0,0);
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
	CCLabelTTF *gameOverBlast = [CCLabelTTF labelWithString: gameOverStr fontName: @"RedStateBlueState BB" fontSize: 84];
	gameOverBlast.position = kGameBoxCenterPoint;
	gameOverBlast.scale = 0.0;
	gameOverBlast.opacity = 255.0;
	gameOverBlast.color = ccc3(255,255,255);
	[self addChild: gameOverBlast z: 1000];
		
	[gameOverBlast runAction: [CCSequence actions: 
							[CCDelayTime actionWithDuration: delay],
							[CCScaleTo actionWithDuration: 0.33 scale: 1.0],
							[CCDelayTime actionWithDuration: 1.66],
							//[CCScaleTo actionWithDuration: 0.33 scale: 0.0],
							//[CCCallFunc actionWithTarget: gameOverBlast selector: @selector(dispose)], 
							nil]];
	
}


#pragma mark -
#pragma mark Shapes and Physics

-(void)createShapeAtPoint: (CGPoint)p
{
	// Create shape and add it to scene
	currentShape = [[[currentShapeClass alloc] init] autorelease];
	currentShape.position = p;
	[currentShape addToSpace: space];
	[self addChild: currentShape z: 98];
		
	//[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch:1.0f pan:0.0f gain:0.3f];
}

-(void)endExpansionOfShape: (Shape *)shape
{
	
	// Failure, shape too small
	if (shape.size < kMinimumShapeSize)
	{
		shape.destroyed = YES;
		shape.ended = NOW;
		[self removeShape: shape];
	
		
		[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch:0.891 pan:0.0f gain:0.3f];
	}
	else
	{
		shape.expanding = NO;
		shape.fullSize = shape.size;

		[surface updateWithShape: shape];
	
		//NSLog([surface description]);
		[self updateScore];
		[self percentageBlast: [surface percentageFilled] atPoint: shape.position];
		
		shape.cpShape->collision_type = 0;
		[shapes addObject: shape];	
		score += ([shape area]/100);
		
		[bgRenderTexture drawShape: currentShape];
		
//		[bgRenderTexture begin];
//		[currentShape drawFilledShape];
//		[bgRenderTexture end];
		
		int size = shape.size;
		int index = size % 7;
		float pitch = [Instrument bluesPitchForIndex: index];
		[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch: pitch pan:0.0f gain:0.3f];
		
		if ([surface percentageFilled] >= 80.0f)
			[self advanceLevel];
	}

}

-(void)removeShape: (Shape *)shape
{
	if (shape != nil)
	{
		cpSpaceRemoveShape(space, shape.cpShape);
		cpSpaceRemoveBody(space, shape.cpBody);
	
		[self removeChild: shape cleanup: YES];
	}
}

-(void)addBouncingBallAtPoint: (CGPoint)p withVelocity: (CGPoint)movementVector
{
	BouncingBall *bounceBall = [[[BouncingBall alloc] init] autorelease];
	bounceBall.size = 20;
	bounceBall.position = p;
	
	[bounceBall addToSpace: space];
	[bounceBall pushWithVector: movementVector];
	
	[bounceBalls addObject: bounceBall];
	
	[self addChild: bounceBall];
}


#pragma mark -
#pragma mark Level transitions

-(void)startLevel
{	
	int numBalls = 0;
	
	if (level < 4)
		numBalls = 1;
	else if (level >= 5 && level < 7)
		numBalls = 2;
	else
		numBalls = 2 + (level / 7);	
	
	if (numBalls > kMaxBounceBalls)
		numBalls = kMaxBounceBalls;
	
	// Create the balls and set them going
	for (int i = 0; i < numBalls; i++)
	{
		// Define starting point
		CGPoint startingPoint = kGameScreenCenterPoint;
		int mod = RandomBetween(0, 1) ? -1 : 1;
		startingPoint.x += (mod * 25 + RandomBetween(5, 10)) * i;
		startingPoint.y += (mod * 15 + RandomBetween(5, 10)) * i;
		
		// Define movement vector
		CGPoint movementVector = cpv( 5000 + (level * 700 ), 5000 + (level * 700));
		
		// Add ball
		[self addBouncingBallAtPoint: startingPoint withVelocity: movementVector];
	}
	
	[self runAction: [CCCallFunc actionWithTarget: self selector: @selector(endTransition)]];
}

-(void)advanceLevel
{
	inTransition = YES;
	
	// Clear all shapes from our databank
	for (Shape *s in shapes)
	{
		[self removeShape: s];
	}
	[shapes removeAllObjects];
	
	// Remove bouncing balls
	for (BouncingBall *b in bounceBalls)
		[self removeShape: b];
	[bounceBalls removeAllObjects];
	
	// Clear surface
	[bgRenderTexture clear];
	[surface clear]; 
	
	level += 1;
	
	// Add to time
	timeRemaining += kTimePerLevel;
	
	// Add to mana
	mana += kManaPerLevel;
	if (mana > kFullMana)
		mana = kFullMana;
	manaBar.percentage = (float)mana/kFullMana;
	
	
	[piano playWithInterval: 0.22 afterDelay: 0 chords: @"1,2,5", @"1,2,5", @"1,2,4", @"1,2,3", nil];
		
	[self levelBlast: level atPoint: kGameBoxCenterPoint afterDelay: 1.0];
	[self runAction: [CCAction action: [CCCallFunc actionWithTarget: self selector: @selector(startLevel)] withDelay: 2.6]];;
}

-(int)currentLevel
{
	return level;
}

-(void)gameOver
{
	inTransition = YES;
	
	// Remove all shapes
	if (currentShape != nil)
	{
		[self removeShape: currentShape];
		currentShape = nil;
	}
	
	for (BouncingBall *b in bounceBalls)
		[b removeFromParentAndCleanup: YES];	

	[bgRenderTexture goBlack];
	[piano playWithInterval: 0.4 afterDelay: 0 chords: @"1,2,5", @"1,2,5", @"1,2,5", @"1,2,4", @"1,2,4", @"1,2,3", @"1,2,3", nil];

	[self gameOverBlastAfterDelay: 0.2];
	
	[self runAction: [CCSequence actions:
					  
					  [CCDelayTime actionWithDuration: 2.5],
					  [CCCallFuncO actionWithTarget: [CCDirector sharedDirector] 
										   selector: @selector(replaceScene:) 
											 object: [CCTransitionMoveInR transitionWithDuration: 0.35 scene: [MainMenuScene scene]]],
					  nil]];
	 
	
}

-(void)endTransition
{
	inTransition = NO;
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
		
	NSLog(@"Touch began");

	if (!inTransition && CGRectContainsPoint(kGameBoxRect, location))
	{
		[self createShapeAtPoint: location];
	}
	
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{

}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
	NSLog(@"Touch ended");
    //UITouch *touch = [touches anyObject];
	
	if (currentShape != nil && !currentShape.destroyed)
	{
		[self endExpansionOfShape: currentShape];
		currentShape = nil;
	}
	
}

@end
