//
//  Shape.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Shape.h"

@implementation Shape
@synthesize color, opacity, expanding, destroyed, size, fullSize, created, ended, cpShape, cpBody, touch, owner;

-(id)init
{
	if ((self = [super init]))
	{
		opacity = 255;
		color = ccc3(0,0,0);
		size = 8;
		created = NOW;
		expanding = YES;
		destroyed = NO;
		owner = kSinglePlayer;
	}
	return self;
}

//-(void)setExpanding:(BOOL)b
//{	
//	expanding = b;
//	if (!b)
//		fullSize = size;
//}

//-(void)setPosition:(CGPoint)p
//{
//	
//}

-(void)setDestroyed:(BOOL)b
{
	destroyed = b;
	fullSize = size;
//	expanding = NO;
	ended = NOW;
	
	if (b)
		color = ccc3(120,0,0);
}

-(void)addToSpace: (cpSpace *)space
{
	// override in subclass
}

-(float)area
{
	// override in subclass
	return 0;
}

+(NSString *)textSymbol
{
	// override in subclass
	return @"S";
}

+(float)textSymbolSizeForHUD
{
	// override in subclass
	return kHUDFontSize;
}
@end
