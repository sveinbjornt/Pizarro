//
//  Circle.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/15/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Shape.h"

@interface Circle : Shape
{
}

- (void)drawExpandingCircle;
- (void)drawFilledShape;
@end
