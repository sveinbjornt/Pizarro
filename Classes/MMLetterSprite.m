//
//  MMLetterSprite.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MMLetterSprite.h"


@implementation MMLetterSprite

- (CGRect)rect
{
	CGSize s = [self.texture contentSize];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self containsTouchLocation: touch])
		return NO;
	
	if (offTexture)
		self.texture = offTexture;
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self containsTouchLocation: touch])
		self.texture = onTexture;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	self.texture = onTexture;
	
	if (!delegate)
		return;
	
	if (object != nil)
		[delegate performSelector: selector withObject: object];
	else
		[delegate performSelector: selector];
}



@end
