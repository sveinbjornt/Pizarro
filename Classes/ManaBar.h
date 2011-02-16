//
//  ManaBar.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ManaBar : CCNode 
{
	float percentage;
}
@property (readwrite, assign) float percentage;
@end
