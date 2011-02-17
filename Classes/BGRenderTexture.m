//
//  BGRenderTexture.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "BGRenderTexture.h"
#import "Circle.h"

@implementation BGRenderTexture

-(void)clear
{
	[self clear: 0 g: 0 b: 0 a: 0];
}

-(void)drawCircle: (Circle *)circle
{	
	[self begin];
	CGPoint p = ccpSub(circle.position, CGPointMake(kGameBoxXOffset, kGameBoxYOffset));
	//glColor4ub(circle.color.r,circle.color.g,circle.color.b,circle.opacity);
	glColor4ub(0,0,0,255);
	glPointSize(circle.size);
	glEnable(GL_POINT_SMOOTH);
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(2, GL_FLOAT, 0, &p);	
	glDrawArrays(GL_POINTS, 0, 1);
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	[self end];
}

@end
