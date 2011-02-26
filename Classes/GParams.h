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
+(CGPoint)mainMenuBackgroundPoint;
+(CGPoint)mainMenuBackgroundStartPosition;
+(CGPoint)mainMenuShiftOutVector;
+(CGPoint)mainMenuShiftInVector;
@end
