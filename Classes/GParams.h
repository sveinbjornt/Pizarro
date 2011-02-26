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
+(CGPoint)mainMenuPoint;
+(CGPoint)mainMenuStartingPoint;
+(CGPoint)mainMenuIconPoint;
+(CGPoint)menuPauseButtonPoint;
+(CGPoint)mainMenuFirstLetterPoint;
+(float)mainMenuLetterSpacing;
+(CGPoint)mainMenuLetterShiftVector;
+(CGPoint)mainMenuScoresButtonPoint;
+(CGPoint)resumeGameMenuPoint;
+(CGPoint)mainMenuBackgroundPoint;
+(CGPoint)mainMenuBackgroundStartPosition;
@end
