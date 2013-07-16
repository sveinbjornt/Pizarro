//
//  CCNode+Cleanup.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 11/21/10.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import "CCNode+Cleanup.h"

@implementation CCNode (Cleanup)

- (void)disposeOfIt {
	CCLOG(@"Disposing of %@", [self description]);
	[self.parent removeChild:self cleanup:YES];
}

@end
