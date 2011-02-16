//
//  ManaBar.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "ManaBar.h"


@implementation ManaBar
@synthesize percentage;

-(id)init
{
	if ((self = [super init]))
	{
		percentage = 0.7;
	}
	return self;
}

-(void)draw
{
	
	CGPoint whiteVertices[4] =
	{
		ccp(0,0),
		ccp(0,260),
		ccp(19,260),
		ccp(19,0)
	};
	
	CGPoint barVertices[4] =
	{
		ccp(0,0),
		ccp(0,self.percentage * 250),
		ccp(19,self.percentage * 250),
		ccp(19,0)
	};
	
	CGPoint topTriangleVertices[3] = 
	{
		ccp(0, self.percentage * 250),
		ccp(19,self.percentage * 250),
		ccp(19, (self.percentage * 250) + 19)
	};
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	glColor4ub(255,255,255,255);
	ccFillPoly(whiteVertices, 4, YES);
	
	glColor4ub(0,160,0,255);
	ccFillPoly(barVertices, 4, YES);
	
	glColor4ub(0,160,0,255);
	ccFillPoly(topTriangleVertices, 3, YES);
}

@end
