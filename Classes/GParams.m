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

+(float)mainMenuFontSize
{
	if (IPAD)
		return kMainMenuMenuFontSize * 2;
	
	return kMainMenuMenuFontSize;
}

+(CGPoint)mainMenuStartingPoint
{
	if (IPAD)
		return CGPointMake(kGameScreenWidth/2, 84 - 320);
	
	return CGPointMake(kGameScreenWidth/2, 42 - 130);
	
}

+(CGPoint)mainMenuPoint
{
	if (IPAD)
		return CGPointMake(kGameScreenWidth/2, 84);
	
	return CGPointMake(kGameScreenWidth/2, 42);
}

+(float)mainMenuPadding
{
	if (IPAD)
		return 70.0f;
	
	return 35.0f;
}

+(float)mainMenuTitleFontSize
{
	if (IPAD)
		return kMainMenuTitleFontSize * 2;
		
	return kMainMenuTitleFontSize;
}

+(CGPoint)scoresMenuStartPosition
{
	if (IPAD)
		return ccp(-77,768+60);
	
	return ccp(-77,320+60);
}

+(CGPoint)scoresMenuPosition
{
	if (IPAD)
		return ccp(74,768-60);
	
	return ccp(37,320-30);
}

+(CGPoint)scoresMenuShiftOutPosition
{
	if (IPAD)
		return ccp(-90,768+60);
	
	return ccp(-45,480+35);
}

+(CGPoint)mainMenuIconPoint
{
	if (IPAD)
		return CGPointMake(780, 460);
		
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
		return CGPointMake(115, 410);
	
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
		return CGPointMake(-50, 220);
	
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
		CGPointMake(kGameScreenWidth/2, 160);

	return CGPointMake(kGameScreenWidth/2, 65);
}

+(CGPoint)mainMenuBackgroundStartPosition
{
	if (IPAD)
		return ccpAdd([GParams mainMenuBackgroundPoint], [GParams mainMenuShiftOutVector]);
		
	return ccpAdd([GParams mainMenuBackgroundPoint], [GParams mainMenuShiftOutVector]);
}

+(CGPoint)mainMenuShiftOutVector
{
	if (IPAD)
		return ccp(0, -320);
	
	return ccp(0,-130);
}

+(CGPoint)mainMenuShiftInVector
{
	if (IPAD)
		return ccp(0,320);
	
	return ccp(0,130);
}

@end
