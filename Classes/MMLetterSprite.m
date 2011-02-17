//
//  MMLetterSprite.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MMLetterSprite.h"


@implementation MMLetterSprite

//- (CGRect)rect
//{
//	CGSize s = [self.texture contentSize];
//	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
//}

- (CGRect) rect 
{
	float h = [self contentSize].height;
	float w = [self contentSize].width;
	float x = [self position].x - w/2;
	float y = [self position].y - h/2;
	
	CGRect aRect = CGRectMake(x,y,w,h);
	return aRect;
}

//- (void)onEnter
//{
//	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
//	[super onEnter];
//}
//
//- (void)onExit
//{
////	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
//	[super onExit];
//}	
//
//- (BOOL)containsTouchLocation:(UITouch *)touch
//{
//	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
//}
//
//- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if ([self containsTouchLocation: touch])
//	{
//		[self runAction: [CCScaleTo actionWithDuration: 0.2 scale: 1.5]];
//	
//	
//	return YES;
//	}
//	return NO;
//}
//
//- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	if (![self containsTouchLocation: touch])
//		[self runAction: [CCScaleTo actionWithDuration: 0.2 scale: 1.0]];
//	else
//		[self runAction: [CCScaleTo actionWithDuration: 0.2 scale: 1.5]];
//}
//
//- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
//{
//	[self runAction: [CCScaleTo actionWithDuration: 0.2 scale: 1.0]];
//}
//


@end
