/*
 *  Constants.h
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/15/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */


#define kGameName				@"Pizarro"
#define	kGameVersion			1.0
#define kGameReleaseYear		2011
#define kGameDeveloper			@"Corrino Software"
#define kGameProgramming		@"Sveinbjorn Thordarson"
#define kGameGraphics			@"Magnus David Magnusson"

#define kMainMenuFont			@"RedStateBlueState BB"

///// GAMEPLAY ///////

// Mana
#define kFullMana			10.0
#define kStartingMana		10.0
#define kManaPercentageLow	0.25
#define kManaPerLevel		kFullMana/2.2f

// Time
#define kStartingTime		50.0f
#define kTimePerLevel		20.0f


// Shapes
#define kMaxBounceBalls		8
#define kMinimumShapeSize	4
#define kNumShapeKinds		3

// HUD

#define kHUDFontSize			42
#define kHUDFont				@"RedStateBlueState BB"


// Limits

#define kMaxShapes			65535


// PHYSICS ENGINE CONSTANTS

#define kWallThickness		16
#define kWallCollisionType	0
#define kWallElasticity		1.0f
#define kWallFriction		0.0f
#define kWallMass			INFINITY
#define kWallInertia		INFINITY
#define kWallShapeGroup		100


// Surface matrix

#define kMatrixWidth		44
#define kMatrixHeight		27
#define kMatrixUnitSize		10


// Game box

#define kGameBoxWidth		440
#define kGameBoxHeight		270

#define kGameBoxXOffset		32
#define kGameBoxYOffset		8

#define kGameScreenWidth			480
#define kGameScreenHeight			320

#define kGameScreenCenterPoint		CGPointMake([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2)

#define kGameBoxCenterPoint			CGPointMake(kGameBoxXOffset + (kGameBoxWidth/2), kGameBoxYOffset + (kGameBoxHeight/2)) 

#define kGameBoxRect				CGRectMake(kGameBoxXOffset, kGameBoxYOffset, kGameBoxWidth, kGameBoxHeight)


// Main Menu settings

#define kMainMenuTitleFontSize		84
#define kMainMenuMenuFontSize		42

#define kMainMenuBackgroundPoint	CGPointMake([[CCDirector sharedDirector] winSize].width/2, 65)
#define kMainMenuMenuPoint			CGPointMake([[CCDirector sharedDirector] winSize].width/2, 42)
#define kMainMenuIconPoint			CGPointMake(392, 220)
#define kMenuPauseButtonPoint		CGPointMake(36, 290)
#define kMainMenuFirstLetterPoint	CGPointMake(54, 190)
#define kMainMenuLetterSpacing		50
#define kMainMenuLetterShiftVector	CGPointMake(-20, 100)





// Convenience defs

#define NOW [NSDate timeIntervalSinceReferenceDate]
#define RETINA_DISPLAY (CC_CONTENT_SCALE_FACTOR() == 2.0)
