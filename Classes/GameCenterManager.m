//
//  GameCenterManager.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 10/8/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "ScoreManager.h"
#import "cocos2d.h"

@implementation GameCenterManager

//@synthesize earnedAchievementCache;
@synthesize delegate;

+ (GameCenterManager *)sharedManager {
    static GameCenterManager *sharedLocalizedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocalizedStore = [[self alloc] init];
    });
    return sharedLocalizedStore;
}



//- (id) init
//{
//    if(self = [super init])
//    {
//        earnedAchievementCache = NULL;
//    }
//    return self;
//}
//
//-(void)dealloc
//{
//    self.earnedAchievementCache = NULL;
//    [super dealloc];
//}

// NOTE:  GameCenter does not guarantee that callback blocks will be execute on the main thread.
// As such, your application needs to be very careful in how it handles references to view
// controllers.  If a view controller is referenced in a block that executes on a secondary queue,
// that view controller may be released (and dealloc'd) outside the main queue.  This is true
// even if the actual block is scheduled on the main thread.  In concrete terms, this code
// snippet is not safe, even though viewController is dispatching to the main queue:
//
//  [object doSomethingWithCallback:  ^()
//  {
//      dispatch_async(dispatch_get_main_queue(), ^(void)
//      {
//          [viewController doSomething];
//      });
//  }];
//
// UIKit view controllers should only be accessed on the main thread, so the snippet above may
// lead to subtle and hard to trace bugs.  Many solutions to this problem exist.  In this sample,
// I'm bottlenecking everything through  "callDelegateOnMainThread" which calls "callDelegate".
// Because "callDelegate" is the only method to access the delegate, I can ensure that delegate
// is not visible in any of my block callbacks.

- (void)callDelegate:(SEL)selector withArg:(id)arg error:(NSError *)err {
	assert([NSThread isMainThread]);
	if ([delegate respondsToSelector:selector]) {
		if (arg != NULL)
			[delegate performSelector:selector withObject:arg withObject:err];
		else
			[delegate performSelector:selector withObject:err];
	}
	else {
		NSLog(@"Missed Method");
	}
}

- (void)callDelegateOnMainThread:(SEL)selector withArg:(id)arg error:(NSError *)err {
	dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self callDelegate:selector withArg:arg error:err];
                   });
}

#pragma mark -

+ (BOOL)isGameCenterAvailable {
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
	return (gcClass && osVersionSupported);
}

//
//  There are three different occasions on which the user can authenticate himself
//

//  First, when the application is launched/becomes active

- (void)authenticateLocalUser {
    CCLOG(@"Authenticating local user in GC");
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError *error)
         {
             if (error) {
                 CCLOG(@"%@", [error localizedDescription]);
                 if ([error code] != GKErrorCancelled)
                     [self callDelegateOnMainThread:@selector(alert:) withArg:@"Unable to connect to Game Center" error:nil];
             }
             else
                 [self callDelegateOnMainThread:@selector(processGameCenterAuth:) withArg:NULL error:error];
         }];
	}
}

//  Second, when he requests the leaderboard by pressing the Highscores menu button

- (void)authenticateLocalUserForLeaderboard {
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError *error)
         {
             if (error) {
                 CCLOG(@"%@", [error localizedDescription]);
                 
                 if ([error code] != GKErrorCancelled)
                     [self callDelegateOnMainThread:@selector(alert:) withArg:@"Unable to connect to Game Center" error:nil];
                 
                 [self callDelegateOnMainThread:@selector(endLeaderboard) withArg:NULL error:nil];
             }
             else
                 [self callDelegateOnMainThread:@selector(showLeaderboard) withArg:NULL error:nil];
         }];
	}
	else
		[delegate showLeaderboard];
}

//  Third, when he has finished a game

- (void)authenticateLocalUserAndReportScore:(NSUInteger)score level:(NSUInteger)level {
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError *error)
         {
             if (error) {
                 CCLOG(@"%@", [error localizedDescription]);
                 
                 if ([error code] != GKErrorCancelled)
                     [self callDelegateOnMainThread:@selector(alert:) withArg:@"Unable to connect to Game Center" error:nil];
                 // if player isn't authenticated, we can't post the score since we don't know
                 // whose score it is.  Creating a GKScore requires a player ID.
                 //NSLog((NSString *)[error localizedDescription]);
             }
             else
                 [ScoreManager reportGameScore:score level:level];
         }];
	}
	else
		[ScoreManager reportGameScore:score level:level];
}

- (void)authenticateLocalUserAndReportAchievement:(NSString *)achievementIdentifier {
	if ([GKLocalPlayer localPlayer].authenticated == NO) {
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError *error)
         {
             if (error) {
                 CCLOG(@"%@", [error localizedDescription]);
                 // [self callDelegateOnMainThread: @selector(alert:) withArg: @"Unable to connect to Game Center" error: nil];
                 // if player isn't authenticated, we can't post the achievement since we don't know
                 // whose achievement it in fact is.
             }
             else
                 [ScoreManager reportAchievementWithIdentifier:achievementIdentifier];
         }];
	}
	else
		[ScoreManager reportAchievementWithIdentifier:achievementIdentifier];
}

- (void)getTopScoresForAuthenticatedLocalUser {
	if ([GKLocalPlayer localPlayer].authenticated == NO)
		return;
    
	GKLeaderboard *leaderboardRequest = [[[GKLeaderboard alloc] initWithPlayerIDs:[NSArray arrayWithObject:[[GKLocalPlayer localPlayer] playerID]]] autorelease];
	if (leaderboardRequest == nil)
		return;
    
	leaderboardRequest.timeScope = GKLeaderboardTimeScopeAllTime;
    
	[leaderboardRequest loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error)
     {
         //            if (error != nil)
         //				NSLog(@"Error getting player score");
         
         // handle the error.
         //			if (scores == nil)
         //				NSLog(@"No scores available");
         
         //			for (GKScore *score in scores)
         //				highestScore = [score value];
     }];
}

//-(void)reloadHighScoresForCategory: (NSString*) category
//{
//    GKLeaderboard* leaderBoard= [[[GKLeaderboard alloc] init] autorelease];
//    leaderBoard.category= category;
//    leaderBoard.timeScope= GKLeaderboardTimeScopeAllTime;
//    leaderBoard.range= NSMakeRange(1, 1);
//
//    [leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error)
//	 {
//		 [self callDelegateOnMainThread: @selector(reloadScoresComplete:error:) withArg: leaderBoard error: error];
//	 }];
//}
/*
 -(void)submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete
 {
 //GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report
 // new achievements to the user, then you need to check if it's been earned
 // before you submit.  Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
 // and reportAchievementWithCompletionHandler.  To avoid this, we fetch the current achievement list once,
 // then cache it and keep it updated with any new achievements.
 if(self.earnedAchievementCache == NULL)
 {
 [GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error)
 {
 if(error == NULL)
 {
 NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [scores count]];
 for (GKAchievement* score in tempCache)
 {
 [tempCache setObject: score forKey: score.identifier];
 }
 self.earnedAchievementCache= tempCache;
 [self submitAchievement: identifier percentComplete: percentComplete];
 }
 else
 {
 //Something broke loading the achievement list.  Error out, and we'll try again the next time achievements submit.
 [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: NULL error: error];
 }
 
 }];
 }
 else
 {
 //Search the list for the ID we're using...
 GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
 if(achievement != NULL)
 {
 if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete))
 {
 //Achievement has already been earned so we're done.
 achievement= NULL;
 }
 achievement.percentComplete= percentComplete;
 }
 else
 {
 achievement= [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
 achievement.percentComplete= percentComplete;
 //Add achievement to achievement cache...
 [self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
 }
 if(achievement!= NULL)
 {
 //Submit the Achievement...
 [achievement reportAchievementWithCompletionHandler: ^(NSError *error)
 {
 [self callDelegateOnMainThread: @selector(achievementSubmitted:error:) withArg: achievement error: error];
 }];
 }
 }
 }
 
 -(void)resetAchievements
 {
 self.earnedAchievementCache= NULL;
 [GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error)
 {
 [self callDelegateOnMainThread: @selector(achievementResetResult:) withArg: NULL error: error];
 }];
 }
 
 -(void)mapPlayerIDtoPlayer: (NSString*) playerID
 {
 [GKPlayer loadPlayersForIdentifiers: [NSArray arrayWithObject: playerID] withCompletionHandler:^(NSArray *playerArray, NSError *error)
 {
 GKPlayer* player= NULL;
 for (GKPlayer* tempPlayer in playerArray)
 {
 if([tempPlayer.playerID isEqualToString: playerID])
 {
 player= tempPlayer;
 break;
 }
 }
 [self callDelegateOnMainThread: @selector(mappedPlayerIDToPlayer:error:) withArg: player error: error];
 }];
 
 }*/

@end
