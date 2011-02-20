//
//  PizarroAppDelegate.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright Corrino Software 2011. All rights reserved.
//

#import "cocos2d.h"

#import "PizarroAppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "PizarroGameScene.h"
#import "MainMenuScene.h"
#import "SimpleAudioEngine.h"

@implementation PizarroAppDelegate

@synthesize window;

- (void) removeStartupFlicker
{
//
// THIS CODE REMOVES THE STARTUP FLICKER
//
// Uncomment the following code if you Application only supports landscape mode
//
//#if GAME_AUTOROTATION == kGameAutorotationUIViewController
//	
//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
//	
//#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:
															 
															 [NSArray arrayWithObjects:  [NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool: [GameCenterManager isGameCenterAvailable]], nil]
																			   forKeys:  [NSArray arrayWithObjects: @"MusicEnabled", @"SoundEffectsEnabled", @"GameCenterEnabled", nil]]];	
	
	
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if(![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	[self loadResources];
	
	// Run the intro Scene
	//[[CCDirector sharedDirector] runWithScene: [PizarroGameScene scene]];		

	[[CCDirector sharedDirector] runWithScene: [MainMenuScene scene]];	
	
	// Init and log in to game center
//	[self initGameCenter];
//	
//	if ([[NSUserDefaults standardUserDefaults] boolForKey: @"GameCenterEnabled"])
//		[[GameCenterManager sharedManager] authenticateLocalUser];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

#pragma mark -
#pragma mark Resource loading

-(void)loadResources
{
	CCLOG(@"Loading Resources");
	
	//	BOOL	 useHD = CC_CONTENT_SCALE_FACTOR() == 2.0 ? YES : NO;
	NSString	*hdSuffix = @"-hd.png";
	NSString	*pngSuffix = @".png";
	NSString	*wavSuffix = @".wav";
	
	NSString *rsrcPath = [[NSBundle mainBundle] resourcePath];
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: rsrcPath  error: NULL];
	for (NSString *file in files)
	{			
		// If texture, add to texture cache
		if (![file hasSuffix: hdSuffix] && [file hasSuffix: pngSuffix] && ![file hasPrefix: @"Icon"] && ![file hasPrefix: @"Default"])
		{
			CCLOG(@"Loading into Texture Cache: \"%@\"", file);
			[[CCTextureCache sharedTextureCache] addImage: file];
		}
		
		// If audio, preload it
		if ([file hasSuffix: wavSuffix])
		{
			CCLOG(@"Loading sound \"%@\"", file);
			[[SimpleAudioEngine sharedEngine] preloadEffect: file];
		}
	}	
	
	CCLOG(@"Texture cache: %@", [[CCTextureCache sharedTextureCache] description]);
}

#pragma mark -
#pragma mark Settings

- (void)toggleMusic
{
	NSLog(@"Toggling music");
	BOOL enabled = [[[NSUserDefaults standardUserDefaults] valueForKey: @"MusicEnabled"] boolValue];
	
	if (!enabled)
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 1.0f];
	else
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: 0.0f];
	
	[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: !enabled] forKey:@"MusicEnabled"];
	
	NSLog(@"Music: %d", [[[NSUserDefaults standardUserDefaults] valueForKey: @"MusicEnabled"] boolValue]);
}

- (void)toggleSound
{
	NSLog(@"Toggling sound effects");
	BOOL enabled = [[[NSUserDefaults standardUserDefaults] valueForKey: @"SoundEffectsEnabled"] boolValue];
	
	[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: !enabled] forKey:@"SoundEffectsEnabled"];
	
	NSLog(@"Sound: %d", [[[NSUserDefaults standardUserDefaults] valueForKey: @"SoundEffectsEnabled"] boolValue]);
	[[SimpleAudioEngine sharedEngine] setEffectsVolume: [[[NSUserDefaults standardUserDefaults] valueForKey: @"SoundEffectsEnabled"] boolValue]];	
//	NSLog(@"Effects volume %f", [[SimpleAudioEngine sharedEngine] effectsVolume]); 
	//[[SimpleAudioEngine sharedEngine] setEnabled:  [[[NSUserDefaults standardUserDefaults] valueForKey: @"SoundEffectsEnabled"] boolValue] ];
}


- (void)toggleGameCenter
{
	NSLog(@"Toggling game center");
	BOOL enabled = [[[NSUserDefaults standardUserDefaults] valueForKey: @"GameCenterEnabled"] boolValue];
	
	[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: !enabled] forKey:@"GameCenterEnabled"];
	
	NSLog(@"Game Center: %d", [[[NSUserDefaults standardUserDefaults] valueForKey: @"GameCenterEnabled"] boolValue]);
}


#pragma mark -
#pragma mark Game Center

-(void)initGameCenter
{
	NSLog(@"Initing Game Center");
	if ([GameCenterManager isGameCenterAvailable])
	{
		//[self setGameCenterDelegate: gameCenterManager];
		[[GameCenterManager sharedManager] setDelegate: self];
		
		//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	}
	//	else
	//		[[NSUserDefaults standardUserDefaults] setValue: [NSNumber numberWithBool: NO] forKey: @"GameCenterEnabled"];		
}

-(void)processGameCenterAuth: (NSError*) error
{
	if(error == NULL)
	{
		//		NSLog(@"Authenticated");
		//[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
		//[FlurryAPI logEvent:@"Using GameCenter"];
	}
	else
	{
		//		NSLog(@"Error w. Game Center: %@", [error localizedDescription]);
	}	
}


#pragma mark -
#pragma mark Leaderboard

- (void)loadLeaderboard
{
	
	//	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"Game Center not enabled" 
	//													message: @"Game Center functionality is disabled in this beta build"
	//												   delegate: nil
	//										  cancelButtonTitle: @"OK" 
	//										  otherButtonTitles: NULL] autorelease];
	//	[alert show];
	
	//	if (![GameCenterManager isGameCenterAvailable])
	//	{
	////		[GMenuGenerator createGameCenterRequiredMenu: engine.menuManager delegate: engine];
	////		[engine showMenu:@"gamecenterrequired"];
	//	}
	////	else if ([[[NSUserDefaults standardUserDefaults] valueForKey: @"GameCenterEnabled"] boolValue] == NO)
	//	{
	//		[GMenuGenerator createEnableGameCenterMenu: engine.menuManager delegate: engine];
	//		[engine showMenu:@"enablegamecenter"];
	//	}
	//	else
	//	{
	[[GameCenterManager sharedManager] authenticateLocalUserForLeaderboard];
	//	}	
}


-(void)alert: (NSString *)str
{
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: str
													message: str
												   delegate: nil
										  cancelButtonTitle: @"OK" 
										  otherButtonTitles: NULL] autorelease];
	[alert show];
}

- (void)endLeaderboard
{	
	if(leaderboardController)
		[leaderboardController release];
}

- (void)showLeaderboard
{		
	NSLog(@"Showing leaderboard");
	leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		// These defaults can be set in iTunes Connect as oppsoed to code
		leaderboardController.category = kGameCenterScoreCategory;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[leaderboardController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
		[viewController presentModalViewController: leaderboardController animated: YES];
	}	
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)gkLeaderboardViewController
{
	[gkLeaderboardViewController setModalTransitionStyle: UIModalTransitionStyleFlipHorizontal];
	[gkLeaderboardViewController dismissModalViewControllerAnimated:YES];
	[self endLeaderboard];
}




@end
