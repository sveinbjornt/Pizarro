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
		CGPointMake(172, 718);
	
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

#pragma mark -
#pragma mark Settings

+(CGPoint)tutorialMenuStartingPoint
{
	if (IPAD)
		return ccp(kGameScreenWidth+90, -70);
	
	return ccp(kGameScreenWidth+45, -35);
}

+(CGPoint)tutorialMenuPoint
{
	if (IPAD)
		return ccp(kGameScreenWidth - 90, 70);
	
	return ccp(kGameScreenWidth - 45,35);
}

+(float)settingsFontSize
{
	if (IPAD)
		return kSettingsFontSize * 2;
	
	return kSettingsFontSize;
}

+(CGPoint)firstSettingsStartingPoint
{
	if (IPAD)
		return ccp(-370,400);
	
	return ccp(-185, 200);
}

+(CGPoint)firstSettingsPoint
{
	if (IPAD)
		return ccp(340, 400);
		
	return ccp(170, 200);
}

+(CGPoint)secondSettingsPoint
{
	if (IPAD)
		return ccp(330, 300);
	
	return ccp(165, 150);
}

+(CGPoint)thirdSettingsPoint
{
	if (IPAD)
		return ccp(250, 200);
	
	return ccp(125, 100);
}

+(float)settingsSpacing
{
	if (IPAD)
		return 90;
	
	return 45;
}

+(CGPoint)settingsMenuStartingPoint
{
	if (IPAD)
		return ccp(-370,300);
	
	return ccp(-185,150);
}

+(CGPoint)settingsMenuPoint
{
	if (IPAD)
		return ccp(500,300);
	
	return ccp(250,150);
}

+(float)settingsMenuSpacing
{
	if (IPAD)
		return 20;
	
	return 10;
}

#pragma mark -
#pragma mark Credits

+(float)creditsFontSize
{
	if (IPAD)
		return 64;

	return 32;
}

+(CGPoint)creditsLogoStartingPoint
{
	if (IPAD)
		return ccp(-556, 388);
	
	return ccp(-278, 194);
}
+(CGPoint)creditsLogoPoint
{
	if (IPAD)
		return ccp(80, 388);
	
	return ccp(40, 194);
}

+(CGSize)creditsLabelSize
{
	if (IPAD)
		return CGSizeMake(780, 400);
	
	return CGSizeMake(390,200);
}
+(CGSize)createdByLabelSize
{
	if (IPAD)
		return CGSizeMake(780, 300);
	
	return CGSizeMake(390,150);
}

+(CGPoint)creditsLabelStartingPoint
{
	if (IPAD)
		return ccp(-445, 280);
	
	return ccp(-278, 140);
}
+(CGPoint)creditsLabelPoint
{
	if (IPAD)
		return ccp(410, 280);
	
	return ccp(205, 140);
}
+(CGPoint)createdByLabelStartingPoint
{
	if (IPAD)
		return ccp(-370, 100);
	
	return ccp(-185, 50);
}
+(CGPoint)createdByLabelPoint
{
	if (IPAD)
		return ccp(410, 100);
	
	return ccp(205, 50);
}


@end
