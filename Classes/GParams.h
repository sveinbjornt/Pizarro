//
//  GParams.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/26/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GParams : NSObject 
{

}
+(NSString *)spriteFileName: (NSString *)spriteFileName;


+(float)gameBoxWidth: (BOOL)mp;
+(float)gameBoxHeight: (BOOL)mp;
+(float)gameBoxXOffset: (BOOL)mp;
+(float)gameBoxYOffset: (BOOL)mp;

+(int)matrixWidth;
+(int)matrixHeight;
+(int)matrixUnitSize;
+(float)matrixXOffset;
+(float)matrixYOffset;


+(float)HUDFontSize;
+(CGSize)scoreLabelSize;
+(CGPoint)scoreLabelPoint;
+(CGPoint)scoreLPoint;
+(CGPoint)timeLabelPoint;
+(CGSize)timeLabelSize;
+(CGPoint)levelLabelPoint;
+(float)levelLabelFontSize;
+(float)gameOverFontSize;
+(float)levelBlastFontSize;

+(float)manaBarHeight;

+(CGPoint)multiPlayerSrcBallPoint1;
+(CGPoint)multiPlayerSrcBallPoint2;
+(float)multiPlayerSrcBallRadius;





+(float)mainMenuFontSize;
+(CGPoint)mainMenuPoint;
+(CGPoint)mainMenuStartingPoint;
+(float)mainMenuPadding;

+(float)mainMenuTitleFontSize;

+(CGPoint)scoresMenuStartPosition;
+(CGPoint)scoresMenuPosition;
+(CGPoint)scoresMenuShiftOutPosition;

+(CGPoint)mainMenuIconPoint;
+(CGPoint)menuPauseButtonPoint;
+(CGPoint)mainMenuFirstLetterPoint;
+(float)mainMenuLetterSpacing;
+(CGPoint)mainMenuLetterShiftVector;
+(CGPoint)mainMenuScoresButtonPoint;
+(CGPoint)resumeGameMenuPoint;
+(CGPoint)singlePlayerLabelStartingPoint;
+(CGPoint)multiPlayerLabelStartingPoint;
+(CGPoint)singlePlayerLabelPoint;
+(CGPoint)multiPlayerLabelPoint;

+(float)resumeGameFontSize;
+(float)gameModeFontSize;
+(CGPoint)mainMenuBackgroundPoint;
+(CGPoint)mainMenuBackgroundStartPosition;
+(CGPoint)mainMenuShiftOutVector;
+(CGPoint)mainMenuShiftInVector;

+(CGPoint)tutorialMenuStartingPoint;
+(CGPoint)tutorialMenuPoint;
+(float)settingsFontSize;
+(CGPoint)firstSettingsStartingPoint;
+(CGPoint)firstSettingsPoint;
+(CGPoint)secondSettingsPoint;
+(CGPoint)thirdSettingsPoint;
+(float)settingsSpacing;
+(CGPoint)settingsMenuStartingPoint;
+(CGPoint)settingsMenuPoint;
+(float)settingsMenuSpacing;

// Credits menu
+(float)creditsFontSize;
+(CGPoint)creditsLogoStartingPoint;
+(CGPoint)creditsLogoPoint;
+(CGSize)creditsLabelSize;
+(CGSize)createdByLabelSize;
+(CGPoint)creditsLabelStartingPoint;
+(CGPoint)creditsLabelPoint;
+(CGPoint)createdByLabelStartingPoint;
+(CGPoint)createdByLabelPoint;



@end
