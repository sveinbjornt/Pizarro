//
//  Reward.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/2/12.
//  Copyright 2012 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "chipmunk.h"

@interface Reward : CCSprite
{
	cpShape *cpShape;
	cpBody *cpBody;
	int size;
}
@property (readwrite, assign) cpShape *cpShape;
@property (readwrite, assign) cpBody *cpBody;
@property (readwrite, assign) int size;


@end
