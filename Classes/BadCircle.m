//
//  BadCircle.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "BadCircle.h"


@implementation BadCircle

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
