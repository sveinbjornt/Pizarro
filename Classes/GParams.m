//
//  GParams.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/26/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "GParams.h"
#import "Constants.h"
#import "cocos2d.h"

@implementation GParams

+(NSString *)spriteFileName: (NSString *)spriteFileName
{
	if (IPAD)
	{
		return [NSString stringWithFormat: @"%@-ipad.png", spriteFileName];
	}
	return [NSString stringWithFormat: @"%@.png", spriteFileName];
}

+(CGPoint)mainMenuStartingPoint
{
	if (IPAD)
		return CGPointMake([[CCDirector sharedDirector] winSize].width/2, 84 - 260);
	
	return CGPointMake([[CCDirector sharedDirector] winSize].width/2, 42 - 130);
	
}

+(CGPoint)mainMenuPoint
{
	if (IPAD)
		return CGPointMake([[CCDirector sharedDirector] winSize].width/2, 84);
	
	return CGPointMake([[CCDirector sharedDirector] winSize].width/2, 42);
}

+(CGPoint)mainMenuIconPoint
{
	if (IPAD)
		return CGPointMake(770, 440);
		
	return CGPointMake(385, 220);
}

+(CGPoint)menuPauseButtonPoint
{
	if (IPAD)
		CGPointMake(72, 580);
	
	return CGPointMake(36, 290);
}

+(CGPoint)mainMenuFirstLetterPoint
{
	if (IPAD)
		return CGPointMake(108, 380);
	
	return CGPointMake(54, 190);
}

+(float)mainMenuLetterSpacing
{
	if (IPAD)
		return 100;
	
	return 50;
}

+(CGPoint)mainMenuLetterShiftVector
{
	if (IPAD)
		return CGPointMake(-40, 180);
	
	return CGPointMake(-20, 90);
}

+(CGPoint)mainMenuScoresButtonPoint
{
	if (IPAD)
		return CGPointMake(45, 768-70);
	
	return CGPointMake(45, 320-35);
}

+(CGPoint)resumeGameMenuPoint
{
	if (IPAD)
		return CGPointMake(364, 360);
	
	return CGPointMake(182, 180);
}

+(CGPoint)mainMenuBackgroundPoint
{
	if (IPAD)
		CGPointMake([[CCDirector sharedDirector] winSize].width/2, 130);

	return CGPointMake([[CCDirector sharedDirector] winSize].width/2, 65);
}

+(CGPoint)mainMenuBackgroundStartPosition
{
	if (IPAD)
		return ccpAdd([GParams mainMenuBackgroundPoint], ccp(0,-260));
		
	return ccpAdd([GParams mainMenuBackgroundPoint], ccp(0,-130));
}

@end
