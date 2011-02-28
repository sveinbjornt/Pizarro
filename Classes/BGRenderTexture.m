//
//  BGRenderTexture.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "BGRenderTexture.h"
#import "Circle.h"
#import "GParams.h"
#import "PizarroGameScene.h"

@implementation BGRenderTexture

-(void)clear
{
	[self clear: 0 g: 0 b: 0 a: 0];
}

-(void)goBlack
{
	[self clear: 0 g: 0 b: 0 a: 255];
}

-(void)drawShape: (Shape *)circle
{	
	// get max smooth point size
	float maxSmoothPointSize[2];
	glGetFloatv(GL_SMOOTH_POINT_SIZE_RANGE, (float *)&maxSmoothPointSize);
	
	// get circle point in local coordinates
	CGPoint p = ccpSub(circle.position, CGPointMake([GParams gameBoxXOffset: [(PizarroGameScene *)self.parent multiPlayer]], [GParams gameBoxYOffset: [(PizarroGameScene *)self.parent multiPlayer]]));
	// Set color
	glColor4ub(circle.color.r,circle.color.g,circle.color.b,circle.opacity);
	
	[self begin];
	
	// If larger than smooth point size, we draw as circle
	if (circle.size * CC_CONTENT_SCALE_FACTOR() > maxSmoothPointSize[1])
	{
		ccFillCircle(p, circle.size/2, CC_DEGREES_TO_RADIANS(360), 60, NO);
	}
	else // Draw as antialiased point
	{
		p.x *= CC_CONTENT_SCALE_FACTOR();
		p.y *= CC_CONTENT_SCALE_FACTOR();
	
		//glColor4ub(circle.color.r,circle.color.g,circle.color.b,circle.opacity);
		glColor4ub(0,0,0,255);
		glPointSize(circle.size * CC_CONTENT_SCALE_FACTOR());
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
	}
	
	[self end];
}

@end
