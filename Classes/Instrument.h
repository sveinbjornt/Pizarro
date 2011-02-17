//
//  Instrument.h
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Instrument : NSObject 
{
	NSString			*name;
	NSTimeInterval		tempo;
	float				pitch, gain;
	int					numberOfNotes;
	
	id					delegate;
	SEL					selector;
}
@property (assign, readwrite) NSTimeInterval tempo;
@property (assign, readwrite) float pitch, gain;
@property (assign, readwrite) int numberOfNotes;
@property (assign, readwrite) id delegate;
@property (assign, readwrite) SEL selector;

-(id)initWithName: (NSString *)n numberOfNotes: (int)numNotes tempo: (NSTimeInterval)tmpo;
+(id)instrumentWithName: (NSString *)n numberOfNotes: (int)numNotes tempo: (NSTimeInterval)tmpo;
-(void)playSequence: (NSString *)seq;
-(void)playNote:(int)note;
-(void)playNoteNumber: (NSNumber *)num;
@end
