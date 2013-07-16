//
//  GameOverCircle.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/21/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Circle.h"

@interface GameOverCircle : Circle
{
	NSTimeInterval animationDuration;
}
- (void)startExpanding;
@end
