//
//  GameOverCircle.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/21/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "GameOverCircle.h"


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
		fullSize = 330;
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
	
	size = fraction * fullSize;
}


-(void)draw
{
	[self drawFilledShape];
}




@end
