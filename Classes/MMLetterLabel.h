//
//  MMLetterLabel.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/18/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface MMLetterLabel : CCLabelTTF
{
	CGPoint originalPosition;
}
@property (readwrite, assign) CGPoint originalPosition;
- (CGRect)rect;
@end
