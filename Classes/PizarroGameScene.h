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

@interface PizarroGameScene : CCLayerColor
{	
	NSArray		   *shapeKinds;
	NSMutableArray *shapes;
	NSMutableArray *bounceBalls;
	
	Shape	*currentShape;
	Class	currentShapeClass;
	
	CCLabelTTF *timeLabel;
	CCLabelTTF *levelLabel;
	CCLabelTTF *scoreLabel;
	CCLabelTTF *shapeLabel;
	
	CCMenuItemSprite	*pauseMenuItem;
	
	BGRenderTexture		*bgRenderTexture;
	
	ManaBar		*manaBar;
		
	cpSpace* space;	
	
	SurfaceMatrix	*surface;
	
	
	int				currShapeIndex;
	int				score;
	int				level;
	NSTimeInterval	timeRemaining;
}

+(id)scene;

-(void)setupGameVariables;
-(void)setupHUD;
-(void)setupGame;
-(void)setupChipmunk;

-(void)updateLevel;
-(void)updateScore;
-(void)updateTimer;
-(void)updateCurrentShape;

-(void)createShapeAtPoint: (CGPoint)p;
-(void)removeShape: (Shape *)shape;

-(void)advanceLevel;
-(int)currentLevel;
@end
