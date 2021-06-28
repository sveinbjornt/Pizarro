//
//  ExpandingMenuItemToggle.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "ExpandingMenuItemToggle.h"
#import "Instrument.h"
#import "SimpleAudioEngine.h"
#import "Common.c"
#import "Constants.h"

@implementation ExpandingMenuItemToggle

- (void)setSelectedIndex:(NSUInteger)index {
	[super setSelectedIndex:index];
    
	int dir = RandomBetween(0, 1) ? -1 : 1;
    
	for (CCNode *n in self.children) {
		[n runAction:[CCSequence actions:
		              [CCScaleTo actionWithDuration:0.2 scale:1.3],
		              [CCScaleTo actionWithDuration:0.2 scale:1.0],
		              nil]];
        
//		[n runAction:[CCSequence actions:
//		              [CCRotateTo actionWithDuration:0.2 angle:RandomBetween(7, 20) * dir],
//		              [CCRotateTo actionWithDuration:0.2 angle:0],
//		              nil]];
	}
    
	if ([self.parent isKindOfClass:[CCMenu class]]) {
		CCArray *mItems = self.parent.children;
		int i = [mItems indexOfObject:self];
        
        
		float pitch = [Instrument bluesPitchForIndex:i + 2 + index + dir];
		if (SOUND_ENABLED)
			[[SimpleAudioEngine sharedEngine] playEffect:kTrumpetSoundEffect pitch:pitch pan:0.0f gain:0.3f];
	}
}

@end
