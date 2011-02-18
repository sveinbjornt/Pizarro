//
//  GameCenterManager.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 10/8/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//

@class GKLeaderboard, GKAchievement, GKPlayer;


@protocol GameCenterManagerDelegate <NSObject>
- (void)showLeaderboard;
@end

@interface GameCenterManager : NSObject
{
//  NSMutableDictionary* earnedAchievementCache;
    id		delegate;
}

//This property must be atomic to ensure that the cache is always in a viable state...
//@property (retain) NSMutableDictionary* earnedAchievementCache;

@property (nonatomic, assign) id delegate;

+(BOOL)isGameCenterAvailable;
-(void)authenticateLocalUser;
-(void)authenticateLocalUserForLeaderboard;
-(void)authenticateLocalUserAndReportScore: (NSUInteger)score level: (NSUInteger)level;
-(void)authenticateLocalUserAndReportAchievement: (NSString *)achievementIdentifier;
-(void)getTopScoresForAuthenticatedLocalUser;

//- (void) reloadHighScoresForCategory: (NSString*) category;
//- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete;
//- (void) resetAchievements;
//- (void) mapPlayerIDtoPlayer: (NSString*) playerID;

+ (GameCenterManager *)sharedManager;

@end
