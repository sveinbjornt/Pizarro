//
//  BouncingBall.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "BouncingBall.h"
#import "Constants.h"
#import "GParams.h"

@implementation BouncingBall
@synthesize size, cpShape, cpBody;

- (void)addToSpace:(cpSpace *)space {
	self.cpBody = cpBodyNew(20, INFINITY);
	self.cpBody->p = self.position;
    
	cpSpaceAddBody(space, self.cpBody);
    
	self.cpShape = cpCircleShapeNew(self.cpBody, self.size / 2, cpvzero);
	self.cpShape->e = 1.0;
	self.cpShape->u = 0.0;
	self.cpShape->data = self;
	self.cpShape->collision_type = 1;
    
	cpSpaceAddShape(space, self.cpShape);
}

- (void)hilight {
	[self removeAllChildrenWithCleanup:YES];
    
	CCSprite *hilightBall = [CCSprite spriteWithFile:[GParams spriteFileName:kBouncingBallHilightSprite]];
	hilightBall.position = ccp(self.contentSize.width / 2, self.contentSize.height / 2);
	[self addChild:hilightBall];
	[hilightBall runAction:[CCSequence actions:
	                        [CCFadeOut actionWithDuration:0.33],
	                        [CCCallFunc actionWithTarget:hilightBall selector:@selector(dispose)],
	                        nil]];
}

- (void)pushWithVector:(cpVect)v {
	cpBodyApplyImpulse(self.cpBody, v, cpvzero);
}

@end
