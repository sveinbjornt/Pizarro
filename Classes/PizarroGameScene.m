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
#import "BadCircle.h"
#import "CCNode+Cleanup.m"
#import "chipmunk.h"
#import "SimpleAudioEngine.h"
#import "Common.c"

int lastPlayedIndex = 0;

void updateShape(void* ptr, void* unused){
	
	cpShape* shape = (cpShape*)ptr;
	
	CCNode *sprite = shape->data;
	
	if(sprite)// && [sprite isKindOfClass: [BadCircle class]]){
	{	
		cpBody* body = shape->body;
		
		[sprite setPosition:cpv(body->p.x, body->p.y)];
		
	}
}

static void collisionExpansion (cpArbiter *arb, cpSpace *space, void *data)
{
	cpShape *a, *b; 
	cpArbiterGetShapes(arb, &a, &b);
	
	Shape *shape = b->data;
	shape.destroyed = YES;
		
	[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch:0.891 pan:0.0f gain:0.3f];
	
	NSLog(@"Collision");
}

static void collision (cpArbiter *arb, cpSpace *space, void *data)
{
	PizarroGameScene *scene = (PizarroGameScene *)data;
	int lvl = [scene currentLevel];
	
	int mod = RandomBetween(-lvl, lvl);
	
	lastPlayedIndex += mod;
	if (lastPlayedIndex < 1)
		lastPlayedIndex = 7 + lastPlayedIndex;
	if (lastPlayedIndex > 7)
		lastPlayedIndex = 1 + (lastPlayedIndex - 8);
	
	//[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", lastPlayedIndex]];
	[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithFormat: @"%d.wav", lastPlayedIndex] pitch:1.0f pan:0.0f gain:0.1f];
}



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
	[shapeKinds release];
	[surface release];
	[shapes release];
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
		
		[self setupGameVariables];
		[self setupHUD];
		[self setupGame];
		[self updateCurrentShape];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: @"bassline.mp3"];
	}
	return self;
}


#pragma mark -
#pragma mark Setup

-(void)setupGameVariables
{
	// Game variables

	score = 0;
	level = 1;
	timeRemaining = 50;

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
	[self addChild: bg z: 1000];
	
	// TIMER
	[self updateTimer];
	
	// LEVEL
	[self updateLevel];
	
	// SCORE
	[self updateScore];
	
	// MANA BAR
	manaBar = [[[ManaBar alloc] init] autorelease];
	manaBar.position = ccp(4,7);
	[self addChild: manaBar z: 10];
	
	// Pause button
	pauseMenuItem = [CCMenuItemSprite itemFromNormalSprite: [CCSprite spriteWithFile: @"menu_button_black.png"] 
											selectedSprite: [CCSprite spriteWithFile: @"menu_button_white.png"] 
													target: self 
												  selector: @selector(pauseGame)];
	pauseMenuItem.position = kMenuPauseButtonPoint;
	//CCMenu *menu = [CCMenu menuWithItems: pauseMenuItem, nil];
	[self addChild: pauseMenuItem z: 1002];
}

-(void)pauseGame
{
	
}

-(void)setupGame
{
	// null out matrix
	surface = [[SurfaceMatrix alloc] init];
	
	// Array of objects
	shapes = [[NSMutableArray alloc] initWithCapacity: kMaxShapes];
	
	[self schedule: @selector(tick:) interval: 1.0/60];
	[self schedule: @selector(timeTicker:) interval: 1.0];
	[self schedule: @selector(symbolTicker:) interval: 2.0];
	[self setupChipmunk];
}


-(void)setupChipmunk
{
	
	cpInitChipmunk();
	
	space = cpSpaceNew();
	
	space->gravity = cpv(0,0);
	
	space->elasticIterations = 0;
	
	
	// Create the square shape by making 4 lines
	
	// Floor
	cpBody* floorBody1 = cpBodyNew(INFINITY, INFINITY);
	
	floorBody1->p = cpv(0, 0);
	
	cpShape* floorShape1 = cpSegmentShapeNew(floorBody1, cpv(26,4), cpv(476,4), 4);
	
	floorShape1->e = 1.0;
	
	floorShape1->u = 0.0;
	
	floorShape1->collision_type = 0;
	
	floorShape1->group = 100;
	
	cpSpaceAddStaticShape(space, floorShape1);
	
	// Ceiling
	cpBody* floorBody2 = cpBodyNew(INFINITY, INFINITY);
	
	floorBody2->p = cpv(0, 0);
	
	cpShape* floorShape2 = cpSegmentShapeNew(floorBody2, cpv(26,282), cpv(476,282), 4);
	
	floorShape2->e = 1.0;
	
	floorShape2->u = 0.0;
	
	floorShape2->collision_type = 0;
	
	floorShape2->group = 100;
	
	cpSpaceAddStaticShape(space, floorShape2);
	
	// Left side
	
	cpBody* floorBody3 = cpBodyNew(INFINITY, INFINITY);
	
	floorBody3->p = cpv(0, 0);
	
	cpShape* floorShape3 = cpSegmentShapeNew(floorBody3, cpv(26,4), cpv(26,282), 2);
	
	floorShape3->e = 1.0;
	
	floorShape3->u = 0.0;
	
	floorShape3->collision_type = 0;
	
	floorShape3->group = 100;
	
	cpSpaceAddStaticShape(space, floorShape3);
	
	// Right side
	
	cpBody* floorBody4 = cpBodyNew(INFINITY, INFINITY);
	
	floorBody4->p = cpv(0, 0);
	
	cpShape* floorShape4 = cpSegmentShapeNew(floorBody4, cpv(476,4), cpv(476,282), 2);
	
	floorShape4->e = 1.0;
	
	floorShape4->u = 0.0;
	
	floorShape4->collision_type = 0;
	
	floorShape4->group = 100;
	
	cpSpaceAddStaticShape(space, floorShape4);
	
	
	
	BadCircle *bounceBall = [[[BadCircle alloc] init] autorelease];
	bounceBall.size = 20;
	bounceBall.position = ccp(200,200);
	[self addChild: bounceBall];
	
	cpBody* ballBody = cpBodyNew(20, INFINITY);
	
	
	ballBody->p = cpv(bounceBall.position.x, bounceBall.position.y);
	
	cpSpaceAddBody(space, ballBody);
	
	cpShape* ballShape = cpCircleShapeNew(ballBody, bounceBall.size/2, cpvzero);
	
	ballShape->e = 1.0;
	
	ballShape->u = 0.0;
	
	ballShape->data = bounceBall;
	
	ballShape->collision_type = 1;
	
	cpSpaceAddShape(space, ballShape);
	cpBodyApplyImpulse(ballBody, cpv(10000,10000),cpvzero);
	
	
	cpSpaceAddCollisionHandler(space, 1, 2, NULL, NULL, &collisionExpansion, NULL, NULL);
	
	cpSpaceAddCollisionHandler(space, 1, 0, NULL, NULL, &collision, NULL, self);

	
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


#pragma mark -
#pragma mark Drawing

-(void)draw
{
	[super draw];
	
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
}

#pragma mark -
#pragma mark Tickers

-(void)timeTicker: (ccTime)dt
{
	timeRemaining--;
	[self updateTimer];
}

-(void)symbolTicker: (ccTime)dt
{
	currShapeIndex++;
	if (currShapeIndex >= kNumShapeKinds)
		currShapeIndex = 0;
	
	currentShapeClass = [Circle class];//[shapeKinds objectAtIndex: currShapeIndex];
	[self updateCurrentShape];
}

-(void)tick: (ccTime)dt
{
	if (currentShape != nil)
	{
		if (currentShape.destroyed)
		{
			NSTimeInterval timeSinceDestroyed = NOW - currentShape.ended;
			NSTimeInterval ttl = 0.3;
			float fraction = (float) 1.0 - (timeSinceDestroyed / ttl);
			currentShape.size =  (float)fraction * currentShape.fullSize;
			//NSLog(@"Fraction = %f, size = %f", fraction, currentShape.size);
			
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

				//currentShape.size--;
			//[self removeShape: currentShape];
			//currentShape = nil;
		}
		else
		{
			
			NSTimeInterval timeSinceTouch = NOW - currentShape.created;
			currentShape.size = timeSinceTouch * 170;
			
			//[currentShape runAction: [CCRotateBy actionWithDuration: 1.0/60.0f angle: 5.0]];
			
			//cpCircleShapeSetRadius(currentShape.cpShape, currentShape.size/2);
			cpCircleShape *sh = (cpCircleShape *)currentShape.cpShape;
			sh->r = currentShape.size/2;
		
		}
	}
	
	cpSpaceStep(space, 1.0f/60.0f);
	cpSpaceHashEach(space->activeShapes, &updateShape, nil);
	
	
}

#pragma mark -
#pragma mark Blast

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





#pragma mark -
#pragma mark Shapes and Physics

-(void)createShapeAtPoint: (CGPoint)p
{
	// Create shape and add it to scene
	
	currentShape = [[[currentShapeClass alloc] init] autorelease];
	currentShape.position = p;
	[self addChild: currentShape];
	
	// Create Chipmunk physics stuff
	
	// Create body
	currentShape.cpBody = cpBodyNew(INFINITY, INFINITY);
	currentShape.cpBody->p = currentShape.position;
	
	cpSpaceAddBody(space, currentShape.cpBody);
	
	// Add shape to body
	currentShape.cpShape = cpCircleShapeNew(currentShape.cpBody, currentShape.size, cpvzero);
	
	currentShape.cpShape->e = 1.0;
	currentShape.cpShape->u = 0.0;
	currentShape.cpShape->data = currentShape;
	currentShape.cpShape->group = 100;
	currentShape.cpShape->collision_type = 2;
	
	cpSpaceAddShape(space, currentShape.cpShape);
	
	//[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch:1.0f pan:0.0f gain:0.3f];
}

-(void)endExpansionOfShape: (Shape *)shape
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
	
	[[SimpleAudioEngine sharedEngine] playEffect: @"trumpet_start.wav" pitch: 1.0f pan:0.0f gain:0.3f];
}

-(void)removeShape: (Shape *)shape
{
	cpSpaceRemoveShape(space, shape.cpShape);
	cpSpaceRemoveBody(space, shape.cpBody);
	
	[self removeChild: shape cleanup: YES];
}


-(int)currentLevel
{
	return level;
}

#pragma mark -
#pragma mark  Touch handling

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
		
	NSLog(@"Touch began");

	if (CGRectContainsPoint(kGameBoxRect, location))
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
