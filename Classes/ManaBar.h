//
//  ManaBar.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"

@interface ManaBar : CCNode
{
	float percentage;
	//CCTexture2D *manaBarRed, *manaBarGreen, *manaBarRedTop, *manaBarGreenTop;
    
	CCSprite *manaBarRed, *manaBarGreen, *manaBarRedTop, *manaBarGreenTop;
}
@property (readwrite, assign) float percentage;
- (void)setManaLevel:(float)level;

@end
