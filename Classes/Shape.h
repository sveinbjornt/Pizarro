//
//  Shape.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import "chipmunk.h"

@interface Shape : CCNode <CCRGBAProtocol>
{
	GLubyte opacity;
	ccColor3B color;
	
	float			size, fullSize;
	BOOL			expanding, destroyed;
	NSTimeInterval	created, ended;
	
	cpShape			*cpShape;
	cpBody			*cpBody;
	UITouch			*touch;
	
}
@property (readwrite, assign) ccColor3B color;
@property (readwrite, assign) GLubyte opacity;
@property (readwrite, assign) BOOL expanding, destroyed;
@property (readwrite, assign) float size, fullSize;
@property (readwrite, assign) NSTimeInterval created, ended;
@property (readwrite, assign) cpShape *cpShape;
@property (readwrite, assign) cpBody *cpBody;
@property (readwrite, assign) UITouch *touch;


-(void)addToSpace: (cpSpace *)space;
-(float)area;
+(NSString *)textSymbol;
+(float)textSymbolSizeForHUD;
@end
