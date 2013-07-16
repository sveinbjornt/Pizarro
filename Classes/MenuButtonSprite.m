//
//  MenuButtonSprite.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/24/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "MenuButtonSprite.h"
#import "Constants.h"

@implementation MenuButtonSprite

//-(CGRect)rect
//{
//	float w = 40;
//	float h = 28;
//	return CGRectMake(0,kGameScreenHeight-h, w, h);
//}

- (CGRect)rect {
	if (IPAD) {
		return CGRectMake(position_.x,
		                  position_.y + 100,
		                  60, 120);
	}
    
	return CGRectMake(position_.x,
	                  position_.y + 100,
	                  30, 60);
}

@end
