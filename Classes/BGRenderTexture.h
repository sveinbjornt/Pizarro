//
//  BGRenderTexture.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Shape.h"

@interface BGRenderTexture : CCRenderTexture
{
}
- (void)clear;
- (void)goBlack;
- (void)drawShape:(Shape *)circle;
@end
