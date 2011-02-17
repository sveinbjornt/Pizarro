/*
 *  Constants.h
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/15/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */



#define kFullMana			10.0

#define kMaxShapes			65535
#define kMaxBounceBalls		8
#define kMinimumShapeSize	4

#define kNumNameLetters		7

#define kNumShapeKinds		3

#define kHUDFontSize		42
#define kHUDFont			@"RedStateBlueState BB"

#define kMainMenuMenuFontSize		42

#define NOW [NSDate timeIntervalSinceReferenceDate]
#define RETINA_DISPLAY (CC_CONTENT_SCALE_FACTOR() == 2.0)


#define kMatrixWidth		44
#define kMatrixHeight		27
#define kMatrixUnitSize		10

#define kGameBoxWidth		440
#define kGameBoxHeight		270

#define kGameBoxXOffset		32
#define kGameBoxYOffset		8

#define kGameScreenWidth			480
#define kGameScreenHeight			320
#define kGameScreenCenterPoint		CGPointMake([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2)
#define kGameBoxRect				CGRectMake(kGameBoxXOffset, kGameBoxYOffset, kGameBoxWidth, kGameBoxHeight)
#define kGameBoxCenterPoint			CGPointMake(kGameBoxXOffset + (kGameBoxWidth/2), kGameBoxYOffset + (kGameBoxHeight/2)) 
#define kMainMenuBackgroundPoint	CGPointMake([[CCDirector sharedDirector] winSize].width/2, 65)
#define kMainMenuMenuPoint			CGPointMake([[CCDirector sharedDirector] winSize].width/2, 42)
#define kMainMenuIconPoint			CGPointMake(392, 220)
#define kMenuPauseButtonPoint		CGPointMake(36, 290)
#define kMainMenuFirstLetterPoint	CGPointMake(54, 190)
#define kMainMenuLetterSpacing		53

#define kMainMenuLetterShiftVector	CGPointMake(-20, 100)