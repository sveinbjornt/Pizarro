//
//  ScoreManager.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 05/02/11.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import "cocos2d.h"
#import "ScoreManager.h"
#import "NSFileManager+DocumentFolder.m"

@implementation ScoreManager

#pragma mark -
#pragma mark Local High Score

+ (NSUInteger)localHighScore {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSFileManager defaultManager] pathOfFileInDocumentFolder:kSavedHighscoreFilename]];
    
	if (dict == nil)
		return 0;
    
	NSString *scoreStr = [dict objectForKey:kSavedHighscorePlistKey];
	return [scoreStr intValue];
}

+ (void)saveLocalHighScore:(NSUInteger)score {
	if (score < [self localHighScore])
		return;
    
	// OK, it's a bigger score than the one archived, so we replace it with the new, higher number
	NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", (int)score]
	                                                 forKey:kSavedHighscorePlistKey];
	[dict writeToFile:[[NSFileManager defaultManager] pathOfFileInDocumentFolder:kSavedHighscoreFilename] atomically:YES];
}

@end
