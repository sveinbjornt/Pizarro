//
//  MMLetterLabel.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/18/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MMLetterLabel.h"


@implementation MMLetterLabel
@synthesize originalPosition;

- (CGRect) rect 
{
	float h = [self contentSize].height;
	float w = [self contentSize].width;
	float x = [self position].x - w/2;
	float y = [self position].y - h/2;
	
	CGRect aRect = CGRectMake(x,y,w,h);
	return aRect;
}


@end
