//
//  CCNode+Cleanup.m
//  Acheron
//
//  Created by Sveinbjorn Thordarson on 11/21/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import "cocos2d.h"


@interface CCNode (Cleanup) 

@end


@implementation CCNode (Cleanup)

-(void)dispose
{
	CCLOG(@"Disposing of %@", [self description]);
	[self.parent removeChild: self cleanup: YES];
}
@end
