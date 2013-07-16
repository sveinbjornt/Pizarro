//
//  BouncingBall.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"


@interface BouncingBall : CCSprite
{
	float size;
    
	cpShape *cpShape;
	cpBody *cpBody;
    
	//CCSprite		*hilightSprite;
}
@property (readwrite, assign) float size;
@property (readwrite, assign) cpShape *cpShape;
@property (readwrite, assign) cpBody *cpBody;

- (void)hilight;
- (void)pushWithVector:(cpVect)v;
- (void)addToSpace:(cpSpace *)space;

@end
