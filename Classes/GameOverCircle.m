//
//  GameOverCircle.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/21/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "GameOverCircle.h"
#import "GParams.h"

@implementation GameOverCircle

-(id)init
{
	if ((self = [super init]))
	{
		color = ccc3(0,0,0);
		size = 1;
		created = NOW;
		expanding = NO;
		destroyed = NO;
		animationDuration = 0.4f;
		if (IPAD)
			fullSize = 1600;
		else
			fullSize = 800;
	}
	return self;
}

-(void)startExpanding
{
	[self schedule: @selector(updateSize)];
}

-(void)updateSize
{
	NSTimeInterval elapsed = NOW - created;
	float fraction = elapsed / animationDuration;
	if (fraction > 1.0f)
		fraction = 1.0f;
	
	size = fraction * fullSize;
	
}


-(void)draw
{
	// We draw square to fill screen if fullsize
	if (size == fullSize && ![self.children count])
	{
		glColor4ub(0,0,0,255);
		CGPoint vertices[] = 
		{
			{ -kGameScreenWidth/2, -kGameScreenHeight/2 },
			{  kGameScreenWidth/2, -kGameScreenHeight/2 },
			{  kGameScreenWidth/2,  kGameScreenHeight/2 },
			{ -kGameScreenWidth/2,  kGameScreenHeight/2 }
		};
		ccFillPoly(vertices,  4, YES);
	}
	else
		[self drawFilledShape];
}




@end
