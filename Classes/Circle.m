//
//  Circle.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/15/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Circle.h"


@implementation Circle

#pragma mark -
#pragma mark Drawing

-(void)draw
{
	if (expanding)
		[self drawExpandingCircle];
//	else
//		[self drawCircle];
}

-(void)addToSpace: (cpSpace *)space
{
	
	// Create body
	self.cpBody = cpBodyNew(INFINITY, INFINITY);
	self.cpBody->p = self.position;
	
	cpSpaceAddBody(space, self.cpBody);
	
	// Add shape to body
	self.cpShape = cpCircleShapeNew(self.cpBody, self.size, cpvzero);
	
	self.cpShape->e = 1.0;
	self.cpShape->u = 0.0;
	self.cpShape->data = self;
	self.cpShape->group = 100;
	self.cpShape->collision_type = 2;
	
	cpSpaceAddShape(space, self.cpShape);
	
}

-(void)drawExpandingCircle
{
	CGPoint p = CGPointZero;
	
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	
	BOOL white = NO;
	for (int i = size; i > 0; i-= 8)
	{
		if (white)
			glColor4ub(255,255,255,opacity);
		else
			glColor4ub(color.r,color.g,color.b,opacity);
		
		white = !white;
		
		glPointSize(i);
		glEnable(GL_POINT_SMOOTH);
		
		glVertexPointer(2, GL_FLOAT, 0, &p);	
		glDrawArrays(GL_POINTS, 0, 1);
	}
	
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
	
	
}

-(void)drawFilledShape
{
	CGPoint p = CGPointZero;

	glColor4ub(color.r,color.g,color.b,opacity);
	glPointSize(size);
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

#pragma mark -
#pragma mark Info

-(float)area
{
	return size * size * M_PI;
}

+(NSString *)textSymbol
{
	return @"•";
}

+(float)textSymbolSizeForHUD
{
	return kHUDFontSize + 12;
}

@end
