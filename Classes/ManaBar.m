//
//  ManaBar.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "ManaBar.h"
#import "GParams.h"

@implementation ManaBar

- (id)init {
	if ((self = [super init])) {
		percentage = 1.0;
        
		manaBarRed = [CCSprite spriteWithFile:[GParams spriteFileName:kManaBarRedSprite]];
		manaBarRedTop = [CCSprite spriteWithFile:[GParams spriteFileName:kManaBarRedTopSprite]];
		manaBarGreen = [CCSprite spriteWithFile:[GParams spriteFileName:kManaBarGreenSprite]];
		manaBarGreenTop = [CCSprite spriteWithFile:[GParams spriteFileName:kManaBarGreenTopSprite]];
        
		manaBarRed.visible = NO;
		manaBarRedTop.visible = NO;
		manaBarGreen.visible = NO;
		manaBarGreenTop.visible = NO;
        
		[self addChild:manaBarRed];
		[self addChild:manaBarRedTop];
		[self addChild:manaBarGreen];
		[self addChild:manaBarGreenTop];
	}
	return self;
}

- (void)dealloc {
	[self removeAllChildrenWithCleanup:YES];
	[super dealloc];
}

- (void)setManaLevel:(float)level {
	float perc = (float)(level / kFullMana);
	[self setPercentage:perc];
}

- (float)percentage {
	return percentage;
}

- (void)setPercentage:(float)p {
	if (p == self.percentage)
		return;
    
	percentage = p;
    
	float fullHeight = [GParams manaBarHeight];
	float height = roundf((self.percentage * fullHeight));
    
	CCSprite *barSprite, *barTopSprite;
    
	if (percentage > kManaPercentageLow) {
		barSprite = manaBarGreen;
		barTopSprite = manaBarGreenTop;
		manaBarRed.visible = NO;
		manaBarRedTop.visible = NO;
		[manaBarRed stopAllActions];
		[manaBarRedTop stopAllActions];
        
		manaBarGreen.visible = YES;
		manaBarGreenTop.visible = YES;
	}
	else {
		barSprite = manaBarRed;
		barTopSprite = manaBarRedTop;
		manaBarGreen.visible = NO;
		manaBarGreenTop.visible = NO;
		manaBarRed.visible = YES;
		manaBarRedTop.visible = YES;
        
		[manaBarRed runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                 
		                                                         [CCTintTo actionWithDuration:0.5 red:180 green:255 blue:255],
		                                                         [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255],
		                                                         nil]]];
		[manaBarRedTop runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                    
		                                                            [CCTintTo actionWithDuration:0.5 red:180 green:255 blue:255],
		                                                            [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255],
		                                                            nil]]];
	}
    
	barSprite.scaleY = height;
	if (IPAD)
		barSprite.position = ccp(23, -14 + (height / 2));
	else
		barSprite.position = ccp(10, -14 + (height / 2));
    
	barTopSprite.position = ccp(barTopSprite.contentSize.width / 2, (height + barTopSprite.contentSize.height / 2) - 15);
}

- (void)draw {
	// First draw white over everything
	float w = IPAD ? 44 : 19;
	float h = IPAD ? 655 : 270;
    
	CGPoint whiteVertices[4] = {
		ccp(0, 0),
		ccp(0, h),
		ccp(w, h),
		ccp(w, 0)
	};
    
	glColor4ub(255, 255, 255, 255);
	ccFillPoly(whiteVertices, 4, YES);
    
    //	CCTexture2D *colorBar, *barTop;
    //
    //	if (percentage > kManaPercentageLow)
    //	{
    //		colorBar = manaBarGreen;
    //		barTop = manaBarGreenTop;
    //	}
    //	else
    //	{
    //		colorBar = manaBarRed;
    //		barTop = manaBarRedTop;
    //	}
    //
    //	float height = roundf((self.percentage * 254));
    //
    //	//glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    ////	glDisable(GL_BLEND);
    //
    //	glPushMatrix();
    //	glTranslatef(0, 0, 0.0f);
    //	glScalef(1.0, height, 1.0f);
    //	[colorBar drawAtPoint:CGPointZero];
    //	glPopMatrix();
    //
    //	glPushMatrix();
    //	glTranslatef(0, ((height -1) * CC_CONTENT_SCALE_FACTOR()) , 0.0f);
    //	//glScalef(0, 100.0f, 1.0f);
    //	[barTop drawAtPoint:CGPointZero];
    //	glPopMatrix();
    //
    //	glEnable(GL_BLEND);
    
    //	CGPoint whiteVertices[4] =
    //	{
    //		ccp(0,0),
    //		ccp(0,270),
    //		ccp(19,270),
    //		ccp(19,0)
    //	};
    //
    //	CGPoint barVertices[4] =
    //	{
    //		ccp(0,0),
    //		ccp(0,self.percentage * 250),
    //		ccp(19,self.percentage * 250),
    //		ccp(19,0)
    //	};
    //
    //	CGPoint topTriangleVertices[3] =
    //	{
    //		ccp(0, self.percentage * 250),
    //		ccp(19,self.percentage * 250),
    //		ccp(19, (self.percentage * 250) + 19)
    //	};
    //
    //	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    //	glColor4ub(255,255,255,255);
    //	ccFillPoly(whiteVertices, 4, YES);
    //
    //	if (percentage > kManaPercentageLow)
    //		glColor4ub(0,160,0,255); // green
    //	else
    //		glColor4ub(160,0,0,255); // red
    //
    //	ccFillPoly(barVertices, 4, YES);
    //	ccFillPoly(topTriangleVertices, 3, YES);
}

@end
