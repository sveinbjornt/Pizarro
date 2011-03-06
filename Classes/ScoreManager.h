//
//  ScoreManager.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 10/12/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "NSFileManager+DocumentFolder.m"
#import "Constants.h"


@interface ScoreManager : NSObject 
{

}
+(NSUInteger)localHighScore;
+(void)saveLocalHighScore: (NSUInteger)score;

+ (void)reportGameScore: (NSUInteger)score level: (NSUInteger)level;
+ (void)reportNewGKScore: (NSUInteger)score forCategory: (NSString *)category;
+ (void)reportGKScore: (GKScore *)theScore;
+ (void)archiveScore: (GKScore *)theScore;
+ (void)reportArchivedScoresAndAchievements;
+ (void)reportAchievementWithIdentifier: (NSString *)identifier;
+ (void)reportAchievement: (GKAchievement *)achievement;
@end
