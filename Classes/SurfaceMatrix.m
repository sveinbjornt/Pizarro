//
//  LevelSurfaceMatrix.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "SurfaceMatrix.h"
#import "Shape.h"
#import "GParams.h"

@implementation SurfaceMatrix
@synthesize totalFilled;

-(id)initWithWidth: (int)w height: (int)h 
{
	if ((self = [super init]))
	{
		width = w;
		height = h;
		[self clear];
	}
	return self;
}

-(void)clear
{
	totalFilled = 0;
	memset(matrix, kNotCoveredPoint, sizeof(matrix[0][0]) * 100 * 100);
}

-(int)numPoints
{
	return height * width;
}

-(float)percentageFilled
{
	float fraction = (float)totalFilled / [self numPoints];
	return fraction * 100;
}

-(int)updateWithShape: (Shape *)shape
{
	int filled = 0;
	totalFilled = 0;
	
	// we iterate through the matrix, find if any non-covered point
	// is within the surface area of the shape.  If so, we mark it
	// as covered
	for (int x = 0; x < width; x++)
	{
		for (int y = 0; y < height; y++)
		{
			if (matrix[x][y] == kCoveredPoint)
			{
				totalFilled++;
				continue;
			}
			
			CGPoint p = CGPointMake((x * kMatrixUnitSize) + [GParams gameBoxXOffset], (y * kMatrixUnitSize) + [GParams gameBoxYOffset]);
			
			if ([shape isKindOfClass: [Circle class]])
			{
				Circle *c = (Circle *)shape;
				
				if (ccpDistance(c.position, p) <= c.size/2)
				{
					matrix[x][y] = kCoveredPoint;
					filled++;
				}
			}
		}
	}
	
	totalFilled += filled;
	
	// return the number of points marked in this operation
	return filled;
}

-(NSString *)description
{
	return [NSString stringWithFormat: @"%@\nSurfaceMatrix (%d x %d) - Filled: %f%% (%d / %d)",
			[super description],
			width,
			height,
			[self percentageFilled],
			totalFilled,
			[self numPoints]];
			
}

@end
