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

+ (NSString *)spriteFileName:(NSString *)spriteFileName {
	return [NSString stringWithFormat:@"%@.png", spriteFileName];
}

#pragma mark -
#pragma mark In-Game

+ (float)gameBoxWidth:(BOOL)mp {
	return 450;
}

+ (float)gameBoxHeight:(BOOL)mp {
	return 280;
}

+ (float)gameBoxXOffset:(BOOL)mp {
	return 26;
}

+ (float)gameBoxYOffset:(BOOL)mp {
	return 3;
}

+ (float)matrixXOffset {
	return 31;
}

+ (float)matrixYOffset {
	return 7;
}

+ (int)matrixWidth {
	return 45;
}

+ (int)matrixHeight {
	return 28;
}

+ (int)matrixUnitSize {
	return 10;
}

+ (float)HUDFontSize {
	return kHUDFontSize;
}

+ (CGSize)scoreLabelSize {
	return CGSizeMake(160, 40);
}

+ (CGPoint)scoreLabelPoint {
	return ccp(200, 302);
}

+ (CGPoint)scoreLPoint {
	return ccp(135, 302);
}

+ (CGPoint)timeLabelPoint {
	return ccp(417, 301);
}

+ (CGSize)timeLabelSize {
	return CGSizeMake(110, 40);
}

+ (CGPoint)levelLabelPoint {
	return ccp(472, 8);
}

+ (float)levelLabelFontSize {
	return kLevelLabelFontSize;
}

+ (float)gameOverFontSize {
	return kGameOverBlastFontSize;
}

+ (float)levelBlastFontSize {
	return kLevelBlastFontSize;
}

+ (float)manaBarHeight {
	return 268;
}

#pragma mark -
#pragma mark Multiplayer

+ (CGPoint)multiPlayerSrcBallPoint1 {
	return ccp(23, 370);
}

+ (CGPoint)multiPlayerSrcBallPoint2 {
	return ccp(1000, 370);
}

+ (float)multiPlayerSrcBallRadius {
	return 90;
}

#pragma mark -
#pragma mark Main Menu Scene

+ (float)mainMenuFontSize {
	return kMainMenuMenuFontSize;
}

+ (CGPoint)mainMenuStartingPoint {
	return CGPointMake(kGameScreenWidth / 2, 42 - 130);
}

+ (CGPoint)mainMenuPoint {
	return CGPointMake(kGameScreenWidth / 2, 42);
}

+ (float)mainMenuPadding {
	return 35.0f;
}

+ (float)mainMenuTitleFontSize {
	return kMainMenuTitleFontSize;
}

+ (CGPoint)scoresMenuStartPosition {
	return ccp(-77, 320 + 60);
}

+ (CGPoint)scoresMenuPosition {
	return ccp(37, 290);
}

+ (CGPoint)scoresMenuShiftOutPosition {
	return ccp(-45, 480 + 35);
}

+ (CGPoint)mainMenuIconPoint {
	return CGPointMake(385, 220);
}

+ (CGPoint)menuPauseButtonPoint {
	return CGPointMake(36, 290);
}

+ (CGPoint)mainMenuFirstLetterPoint {
	return CGPointMake(54, 190);
}

+ (float)mainMenuLetterSpacing {
	return 50;
}

+ (CGPoint)mainMenuLetterShiftVector {
	return CGPointMake(-20, 90);
}

+ (CGPoint)mainMenuScoresButtonPoint {
	return CGPointMake(45, 320 - 35);
}

+ (CGPoint)resumeGameMenuPoint {
	return CGPointMake(182, 180);
}

+ (CGPoint)singlePlayerLabelStartingPoint {
	return CGPointMake(182, 180);
}

+ (CGPoint)multiPlayerLabelStartingPoint {
	return CGPointMake(182, 180);
}

+ (CGPoint)singlePlayerLabelPoint {
	return CGPointMake(182, 180);
}

+ (CGPoint)multiPlayerLabelPoint {
	return CGPointMake(182, 180);
}

+ (float)resumeGameFontSize {
	return kResumeGameMenuFontSize;
}

+ (float)gameModeFontSize {
	return kGameModeMenuFontSize;
}

+ (CGPoint)mainMenuBackgroundPoint {
	return CGPointMake(kGameScreenWidth / 2, 65);
}

+ (CGPoint)mainMenuBackgroundStartPosition {
	return ccpAdd([GParams mainMenuBackgroundPoint], [GParams mainMenuShiftOutVector]);
}

+ (CGPoint)mainMenuShiftOutVector {
	return ccp(0, -130);
}

+ (CGPoint)mainMenuShiftInVector {
	return ccp(0, 130);
}

#pragma mark -
#pragma mark Settings

+ (CGPoint)tutorialMenuStartingPoint {
	return ccp(kGameScreenWidth + 45, -35);
}

+ (CGPoint)tutorialMenuPoint {
	return ccp(kGameScreenWidth - 45, 35);
}

+ (float)settingsFontSize {
	return kSettingsFontSize;
}

+ (CGPoint)firstSettingsStartingPoint {
	return ccp(-185, 210);
}

+ (CGPoint)firstSettingsPoint {
	return ccp(170, 175);
}

+ (CGPoint)secondSettingsPoint {
	return ccp(165, 125);
}

+ (CGPoint)thirdSettingsPoint {
	return ccp(125, 100);
}

+ (float)settingsSpacing {
	return 45;
}

+ (CGPoint)settingsMenuStartingPoint {
	return ccp(-185, 150);
}

+ (CGPoint)settingsMenuPoint {
	return ccp(250, 150);
}

+ (float)settingsMenuSpacing {
	return 10;
}

#pragma mark -
#pragma mark Credits

+ (float)creditsFontSize {
	return 32;
}

+ (CGPoint)creditsLogoStartingPoint {
	return ccp(-278, 194);
}

+ (CGPoint)creditsLogoPoint {
	return ccp(40, 194);
}

+ (CGSize)creditsLabelSize {
	return CGSizeMake(390, 200);
}

+ (CGSize)createdByLabelSize {
	return CGSizeMake(390, 150);
}

+ (CGPoint)creditsLabelStartingPoint {
	return ccp(-278, 140);
}

+ (CGPoint)creditsLabelPoint {
	return ccp(205, 140);
}

+ (CGPoint)createdByLabelStartingPoint {
	return ccp(-185, 50);
}

+ (CGPoint)createdByLabelPoint {
	return ccp(205, 50);
}

@end
