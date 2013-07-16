//
//  Reward.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/2/12.
//  Copyright 2012 Corrino Software. All rights reserved.
//

#import "Reward.h"

@implementation Reward
@synthesize cpShape, cpBody, size;

- (void)addToSpace:(cpSpace *)space {
	self.cpBody = cpBodyNew(20, INFINITY);
	self.cpBody->p = self.position;
    
	cpSpaceAddBody(space, self.cpBody);
    
	self.cpShape = cpCircleShapeNew(self.cpBody, self.size / 2, cpvzero);
	self.cpShape->e = 1.0;
	self.cpShape->u = 0.0;
	self.cpShape->data = self;
	self.cpShape->collision_type = 1;
    
	cpSpaceAddShape(space, self.cpShape);
}

@end
