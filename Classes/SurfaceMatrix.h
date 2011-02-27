//
//  LevelSurfaceMatrix.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "Circle.h"

#define kNotCoveredPoint	0
#define kCoveredPoint		1

@interface SurfaceMatrix : NSObject 
{
	int totalFilled;
	int height, width;
	int matrix[100][100];
}
@property (readonly,assign) int totalFilled;

-(id)initWithWidth: (int)w height: (int)h;
-(void)clear;
-(int)numPoints;
-(float)percentageFilled;
-(int)updateWithShape: (Shape *)shape;
-(NSString *)description;
@end
