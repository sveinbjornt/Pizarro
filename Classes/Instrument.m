//
//  Instrument.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/17/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Instrument.h"
#import "SimpleAudioEngine.h"
#import "cocos2d.h"
#import "Constants.h"

@implementation Instrument
@synthesize tempo, pitch, gain, numberOfNotes, delegate, selector;

- (void)dealloc {
	[name release];
	[super dealloc];
}

- (id)initWithName:(NSString *)n numberOfNotes:(int)numNotes tempo:(NSTimeInterval)tmpo {
	if ((self = [super init])) {
		name = [n retain];
		numberOfNotes = numNotes;
		tempo = tmpo;
		pitch = 1.0f;
		gain = 0.3f;
		delegate = nil;
		selector = nil;
	}
	return self;
}

+ (id)instrumentWithName:(NSString *)n numberOfNotes:(int)numNotes tempo:(NSTimeInterval)tmpo {
	return [[[self alloc] initWithName:n numberOfNotes:numNotes tempo:tmpo] autorelease];
}

- (void)playSequence:(NSString *)seq {
	int iterator = 0;
	for (NSString *str in[seq componentsSeparatedByString : @","]) {
		if (![str isEqualToString:@" "]) {
			int note = [str intValue];
			[self performSelector:@selector(playNoteNumber:) withObject:[NSNumber numberWithInteger:note] afterDelay:iterator * tempo];
		}
		iterator++;
	}
}

- (void)playNote:(int)note {
	if (note > numberOfNotes)
		CCLOG(@"Warning, note index %d out of bounds", note);
    
	if (SOUND_ENABLED)
		[[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"%@%d.wav", name, note] pitch:pitch pan:0.0f gain:gain];
    
	if (delegate) {
		if ([delegate respondsToSelector:selector])
			[delegate performSelector:selector withObject:[NSNumber numberWithInt:note]];
		else
			CCLOG(@"Delegate %@ does not respond to selector", [delegate description]);
	}
}

- (void)playChord:(NSString *)chordStr {
	for (NSString *str in[chordStr componentsSeparatedByString : @","]) {
		int note = [str intValue];
		if (note > numberOfNotes || note < 0)
			CCLOG(@"Warning: Instrument note out of bounds");
		else
			[self playNote:note];
	}
}

- (void)playWithInterval:(NSTimeInterval)interval afterDelay:(NSTimeInterval)delay chords:(NSString *)chord1, ...
{
	NSString *currChord;
	int iterator = 0;
    
	va_list params;
	va_start(params, chord1);
    
	while (chord1) {
		currChord = va_arg(params, NSString *);
		if (currChord) {
			[self performSelector:@selector(playChord:) withObject:currChord afterDelay:delay + (interval * iterator)];
			iterator++;
		}
		else
			break;
	}
	va_end(params);
}


- (void)playNoteNumber:(NSNumber *)num {
	[self playNote:[num integerValue]];
}

+ (CCFiniteTimeAction *)getActionSequence:(NSArray *)actions {
	CCFiniteTimeAction *seq = nil;
	for (CCFiniteTimeAction *anAction in actions) {
		if (!seq) {
			seq = anAction;
		}
		else {
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
	return seq;
}

+ (float)bluesPitchForIndex:(int)index {
	float pitches[] = { 1.0, 0.891, 0.75, 0.707, 0.665, 0.595, 0.5 };
	return pitches[index];
}

@end
