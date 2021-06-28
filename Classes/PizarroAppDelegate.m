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
#import "ScoreManager.h"

@implementation PizarroAppDelegate

@synthesize window;

- (void)removeStartupFlicker {
    //
    // THIS CODE REMOVES THE STARTUP FLICKER
    //
    // Uncomment the following code if you Application only supports landscape mode
    //
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
    
	CC_ENABLE_DEFAULT_GL_STATES();
	CCDirector *director = [CCDirector sharedDirector];
	CGSize size = [director winSize];
	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
	sprite.position = ccp(size.width / 2, size.height / 2);
	sprite.rotation = -90;
	[sprite visit];
	[[director openGLView] swapBuffers];
	CC_ENABLE_DEFAULT_GL_STATES();
    
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	BOOL showAdForFullVersion = NO;
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjects:
                                                             
	                                                         [NSArray arrayWithObjects:[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithInt:kStartingBassLine], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:showAdForFullVersion], nil]
	                                                                                    forKeys:[NSArray arrayWithObjects:kMusicEnabled, kSoundEnabled, kLastBassLine, kGameCenterEnabled, kShowTutorial, kShowAdForFullVersion, nil]]];
    
	CCLOG(@"User defaults: Music: %d Sound: %d GameCenter: %d", MUSIC_ENABLED, SOUND_ENABLED, GAMECENTER_ENABLED);
    
	[[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    
	if (MUSIC_ENABLED)
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f];
	else
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
    
    
    
	application.statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    
	// Init the window
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds = CGRectMake(0, 0, 480, 320);
	window = [[UIWindow alloc] initWithFrame:bounds];
    
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink])
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
    
    
	CCDirector *director = [CCDirector sharedDirector];
    
    
    
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	//viewController.wantsFullScreenLayout = YES;
    
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
	                               pixelFormat:kEAGLColorFormatRGBA8   // kEAGLColorFormatRGBA8
	                               depthFormat:0                        // GL_DEPTH_COMPONENT16_OES
                        ];
    
	// attach the openglView to the director
	[director setOpenGLView:glView];
	[glView setMultipleTouchEnabled:YES];
    
    //	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if (![director enableRetinaDisplay:YES])
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
    
    //	if (IPAD)
    //		[director setDeviceOrientation:kCCDeviceOrientationPortrait];
    //	else
    //		[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
    
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
    
    
	[director setAnimationInterval:1.0 / 60];
    
#if COCOS2D_DEBUG == TRUE
	[director setDisplayFPS:YES];
#endif
    
	[self loadResources];
    
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
    
	// make the View Controller a child of the main window
	[window addSubview:viewController.view];
    window.rootViewController = viewController;
    
	[window makeKeyAndVisible];
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// Removes the startup flicker
	[self removeStartupFlicker];
    
	// Run the intro Scene
	//[[CCDirector sharedDirector] runWithScene: [PizarroGameScene scene]];
    
	[[CCDirector sharedDirector] runWithScene:[MainMenuScene scene]];
    
	// Init and log in to game center
//	[self initGameCenter];
    
//	if (GAMECENTER_ENABLED)
//		[[GameCenterManager sharedManager] authenticateLocalUser];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	CCScene *s = [[CCDirector sharedDirector] runningScene];
	id layer = [s.children objectAtIndex:0];
    
	if ([layer isKindOfClass:[PizarroGameScene class]]) {
		CCLOG(@"Game layer pausing without animation on resign active");
		[(PizarroGameScene *)layer pauseGameWithAnimation : NO];
	}
    
	[[CCDirector sharedDirector] performSelector:@selector(pause) withObject:nil afterDelay:0.2];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[CCDirector sharedDirector] stopAnimation];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
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

- (void)loadResources {
	CCLOG(@"Loading Resources");
    
	//	BOOL	 useHD = CC_CONTENT_SCALE_FACTOR() == 2.0 ? YES : NO;
	NSString *hdSuffix = @"-hd.png";
	NSString *ipadSuffix = @"-ipad.png";
	NSString *pngSuffix = @".png";
	NSString *wavSuffix = @".wav";
	//NSString	*mp3Suffix = @".mp3";
    
	NSString *rsrcPath = [[NSBundle mainBundle] resourcePath];
    
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rsrcPath error:NULL];
	for (NSString *file in files) {
		// If texture, add to texture cache
		if (![file hasSuffix:hdSuffix] &&
		    [file hasSuffix:pngSuffix] &&
		    ![file hasPrefix:@"Icon"] &&
		    ![file hasPrefix:@"Default"] &&
		    ![file isEqualToString:@"fps_images.png"] &&
		    ((IPAD && [file hasSuffix:ipadSuffix]) ||
		     (!IPAD && ![file hasSuffix:ipadSuffix]))
		    ) {
			CCLOG(@"Loading into Texture Cache: \"%@\"", file);
			[[CCTextureCache sharedTextureCache] addImage:file];
		}
        
		// If audio effect, preload it
		if ([file hasSuffix:wavSuffix]) {
			CCLOG(@"Loading sound \"%@\"", file);
			[[SimpleAudioEngine sharedEngine] preloadEffect:file];
		}
        
        //		// If music, preload
        //		if ([file hasSuffix: mp3Suffix] )
        //		{
        //			CCLOG(@"Preloading music \"%@\"", file);
        //			[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: file];
        //		}
	}
    
	[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:kMainMenuMusicFile];
    
	CCLOG(@"Texture cache: %@", [[CCTextureCache sharedTextureCache] description]);
}

#pragma mark -
#pragma mark Settings

- (void)toggleMusic {
	CCLOG(@"Toggling music");
	BOOL enabled = MUSIC_ENABLED;
    
	if (!enabled)
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f];
	else
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0f];
    
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!enabled] forKey:kMusicEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	CCLOG(@"Music: %d", MUSIC_ENABLED);
}

- (void)toggleSound {
	CCLOG(@"Toggling sound effects");
	BOOL enabled = SOUND_ENABLED;
    
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!enabled] forKey:kSoundEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	CCLOG(@"Sound: %d", SOUND_ENABLED);
	[[SimpleAudioEngine sharedEngine] setEffectsVolume:SOUND_ENABLED];
}

- (void)toggleGameCenter {
    
	CCLOG(@"Toggling game center");
	BOOL enabled = GAMECENTER_ENABLED;
    
	[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!enabled] forKey:kGameCenterEnabled];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	CCLOG(@"Game Center: %d", GAMECENTER_ENABLED);
    
	if (!enabled) {
        CCLOG(@"Authenticating with GC");
    }
}

#pragma mark -
#pragma mark Game Center

- (void)initGameCenter {
	CCLOG(@"Initing Game Center");
}

- (void)processGameCenterAuth:(NSError *)error {
	if (error == NULL) {
		CCLOG(@"Authenticated with Game Center");
	}
	else {
		CCLOG(@"Error w. Game Center: %@", [error localizedDescription]);
	}
}

#pragma mark -
#pragma mark Leaderboard

- (void)loadLeaderboard {
	CCLOG(@"Loading leaderboard");
}

- (void)alert:(NSString *)str {
}

- (void)endLeaderboard {
}

- (void)showLeaderboard {
}

@end
