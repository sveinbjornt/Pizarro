//
//  BouncingBall.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "BouncingBall.h"


@implementation BouncingBall

-(void)addToSpace:(cpSpace *)space
{
	self.cpBody = cpBodyNew(20, INFINITY);
	self.cpBody->p = self.position;
	
	cpSpaceAddBody(space, self.cpBody);
	
	self.cpShape = cpCircleShapeNew(self.cpBody, self.size/2, cpvzero);
	self.cpShape->e = 1.0;
	self.cpShape->u = 0.0;	
	self.cpShape->data = self;
	self.cpShape->collision_type = 1;
	
	cpSpaceAddShape(space, self.cpShape);
}

-(void)pushWithVector: (cpVect)v
{
	cpBodyApplyImpulse(self.cpBody, v,cpvzero);
}

-(void)draw
{
	CGPoint p = CGPointZero;
	
	glColor4ub(0,0,0,255);
	glPointSize(size);
	glEnable(GL_POINT_SMOOTH);
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, &p);	
	glDrawArrays(GL_POINTS, 0, 1);
	
	glColor4ub(255,255,255,255);
	glPointSize(size-4);
	
	glVertexPointer(2, GL_FLOAT, 0, &p);	
	glDrawArrays(GL_POINTS, 0, 1);
	
	glColor4ub(0,0,0,255);
	glPointSize(size-8);
	glVertexPointer(2, GL_FLOAT, 0, &p);	
	glDrawArrays(GL_POINTS, 0, 1);
	
//	glColor4ub(255,255,255,255);
//	glPointSize(radius-12);
//	glEnable(GL_POINT_SMOOTH);
//	glVertexPointer(2, GL_FLOAT, 0, &p);	
//	glDrawArrays(GL_POINTS, 0, 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);	
	
	
}


@end
