//
//  HelloWorldLayer.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/15/11.
//  Copyright Corrino Software 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Constants.h"
#import "Circle.h"
#import "chipmunk.h"
#import "ManaBar.h"
#import "SurfaceMatrix.h"
#import "BGRenderTexture.h"
#import "Instrument.h"
#import "GameOverCircle.h"

@interface PizarroGameScene : CCLayerColor
{	
	NSMutableArray *shapes;
	NSMutableArray *bounceBalls;
	
	Class	currentShapeClass;
	
	CCLabelTTF *timeLabel;
	CCLabelTTF *levelLabel;
	CCLabelTTF *scoreLabel;
	CCLabelTTF *shapeLabel;
	
	CCMenu *pauseMenu;
	
	BGRenderTexture		*bgRenderTexture;
	
	ManaBar		*manaBar;
		
	GameOverCircle	*gameOverCircle;
	
	// CHipmunk objects
	cpSpace* space;	
	
	cpBody *floorBody, *ceilingBody, *leftBody, *rightBody;
	cpShape *floorShape, *ceilingShape, *leftShape, *rightShape;
	
	SurfaceMatrix	*surface;
		
	int				currShapeIndex;
	int				score;
	int				level;
	float			percentageFilled;
	
	NSTimeInterval	mana;
	NSTimeInterval	timeRemaining;
	
	NSTimeInterval	manaIncreaseTime;
	NSTimeInterval	oldMana, newMana;
	
	BOOL			inTransition;
	BOOL			gameOver;
	
	BOOL			flawless;
	
	BOOL			multiPlayer;
	
	Instrument		*piano;
	
	int				tutorialStep;
	CCNode			*currentTutorialNode, *lastTutorialNode;
	
}
@property (readwrite, assign) BOOL multiPlayer;

+(id)scene: (BOOL)multiPl;
-(id)initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h multiPlayer: (BOOL)mp;

-(void)setupGameVariables;
-(void)setupHUD;
-(void)setupGame;
-(void)setupChipmunk;
-(void)createPhysicalBox;
-(void)destroyPhysicalSpace;

-(void)updateLevel;
-(void)updateScore;
-(void)updateTimer;
-(void)updateCurrentShape;

-(void)pauseGame;
-(void)pauseGameWithAnimation: (BOOL)animated;

-(void)showTutorialStep: (int)stepNum;

-(void)levelBlast: (NSUInteger)lvl atPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay;
-(void)percentageBlast: (NSUInteger)s atPoint: (CGPoint)p;
-(void)noteBlastAtPoint: (CGPoint)p afterDelay: (NSTimeInterval)delay;

-(void)addBouncingBallAtPoint: (CGPoint)p withVelocity: (CGPoint)movementVector;
-(void)endExpansionOfShape: (Shape *)shape;

-(void)createShapeAtPoint: (CGPoint)p forTouch: (UITouch *)touch;
-(void)removeShape: (Shape *)shape;

-(void)collision;

-(void)startGame;

-(void)advanceLevel;
-(int)currentLevel;

-(void)gameOver;
@end
