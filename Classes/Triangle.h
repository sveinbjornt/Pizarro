//
//  Triangle.h
//  Pithon
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Shape.h"

@interface Triangle : Shape
{
}

- (void)drawExpandingTriangle;
- (void)drawTriangle;

@end
