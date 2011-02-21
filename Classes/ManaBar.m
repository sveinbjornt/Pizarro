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
		percentage = 1.0;
		
		manaBarRed = [CCSprite spriteWithFile: @"manabar_red.png"];
		manaBarRedTop = [CCSprite spriteWithFile: @"manabar_red_top.png"];
		manaBarGreen = [CCSprite spriteWithFile: @"manabar_green.png"];
		manaBarGreenTop = [CCSprite spriteWithFile: @"manabar_green_top.png"];
		
		manaBarRed.visible = NO;
		manaBarRedTop.visible = NO;
		manaBarGreen.visible = NO;
		manaBarGreenTop.visible = NO;
		
		[self addChild: manaBarRed];
		[self addChild: manaBarRedTop];
		[self addChild: manaBarGreen];
		[self addChild: manaBarGreenTop];
	}
	return self;
}

//-(void)dealloc
//{
//	[super dealloc];
//}

-(void)setPercentage:(float)p
{
	percentage = p;
	float height = roundf((self.percentage * 254));
	
	CCSprite *barSprite, *barTopSprite;
	
	if (percentage > kManaPercentageLow)
	{
		CCLOG(@"High mana");
		barSprite = manaBarGreen;
		barTopSprite = manaBarGreenTop;
		manaBarRed.visible = NO;
		manaBarRedTop.visible = NO;
		manaBarGreen.visible = YES;
		manaBarGreenTop.visible = YES;
	}
	else
	{
		CCLOG(@"Low mana");
		barSprite = manaBarRed;
		barTopSprite = manaBarRedTop;
		manaBarGreen.visible = NO;
		manaBarGreenTop.visible = NO;
		manaBarRed.visible = YES;
		manaBarRedTop.visible = YES;
	}

	barSprite.scaleY = height;
	barSprite.position = ccp(10, 0 + (height/2));
	
	barTopSprite.position = ccp(barTopSprite.contentSize.width/2, (height + barTopSprite.contentSize.height/2)-1);
	
	
}

-(void)draw
{	
	// First draw white over everything
	CGPoint whiteVertices[4] =
	{
		ccp(0,0),
		ccp(0,270),
		ccp(19,270),
		ccp(19,0)
	};
	
	glColor4ub(255,255,255,255);
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
