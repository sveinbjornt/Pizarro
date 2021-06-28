//
//  ScoreManager.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 10/12/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSFileManager+DocumentFolder.m"
#import "Constants.h"


@interface ScoreManager : NSObject
{
}
+ (NSUInteger)localHighScore;
+ (void)saveLocalHighScore:(NSUInteger)score;

@end
