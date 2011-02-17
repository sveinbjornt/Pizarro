//
//  MainMenuScene.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MMLetterSprite.h"

@interface MainMenuScene : CCLayerColor
{
	UITouch *currTouch;
	NSMutableArray *letters;
	CCSprite *icon, *bg1, * bg2;
	CCMenu *menu;
}

+(id)scene;

@end
