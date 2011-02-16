/*
 *  Constants.h
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/15/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */



#define kFullMana			10.0

#define kMaxShapes			255

#define kNumShapeKinds		3

#define kHUDFontSize		42
#define kHUDFont			@"RedStateBlueState BB"

#define NOW [NSDate timeIntervalSinceReferenceDate]
#define RETINA_DISPLAY (CC_CONTENT_SCALE_FACTOR() == 2.0)


#define kMatrixWidth		44
#define kMatrixHeight		27
#define kMatrixUnitSize		10

#define kGameBoxWidth		440
#define kGameBoxHeight		270

#define kGameBoxXOffset		32
#define kGameBoxYOffset		8

#define kGameScreenCenterPoint		CGPointMake([[CCDirector sharedDirector] winSize].width/2,[[CCDirector sharedDirector] winSize].height/2)
#define kGameBoxRect				CGRectMake(kGameBoxXOffset, kGameBoxYOffset, kGameBoxWidth, kGameBoxHeight)
#define kMenuPauseButtonPoint		CGPointMake(36, 290)