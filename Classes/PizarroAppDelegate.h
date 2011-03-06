//
//  PizarroAppDelegate.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright Corrino Software 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"

@class RootViewController;

@interface PizarroAppDelegate : NSObject <UIApplicationDelegate, GKLeaderboardViewControllerDelegate> 
{
	UIWindow			*window;
	RootViewController	*viewController;
	GKLeaderboardViewController *leaderboardController;
}

@property (nonatomic, retain) UIWindow *window;

-(void)loadResources;

-(void)alert: (NSString *)str;
-(void)initGameCenter;
-(void)loadLeaderboard;
-(void)endLeaderboard;
-(void)showLeaderboard;

@end
