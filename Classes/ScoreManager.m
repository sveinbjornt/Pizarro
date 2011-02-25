//
//  ScoreManager.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 05/02/11.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import "ScoreManager.h"
#import "NSFileManager+DocumentFolder.m"

@implementation ScoreManager

#pragma mark -
#pragma mark Local High Score

+(NSUInteger)localHighScore
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [[NSFileManager defaultManager] pathOfFileInDocumentFolder: kSavedHighscoreFilename]];
	
	if (dict == nil)
		return 0;
	
	NSString *scoreStr = [dict objectForKey: kSavedHighscorePlistKey];
	return [scoreStr intValue];
	
}

+(void)saveLocalHighScore: (NSUInteger)score
{
	if (score < [self localHighScore])
		return;
	
	// OK, it's a bigger score than the one archived, so we replace it with the new, higher number
	NSDictionary *dict = [NSDictionary dictionaryWithObject: [NSString stringWithFormat: @"%d", score]
													 forKey: kSavedHighscorePlistKey];
	[dict writeToFile: [[NSFileManager defaultManager] pathOfFileInDocumentFolder: kSavedHighscoreFilename] atomically: YES];
}

#pragma mark -
#pragma mark Leaderboard High Scores

+(void)reportGameScore: (NSUInteger)score level: (NSUInteger)level
{
	[self reportArchivedScores]; // every time a score is submitted, we try to submit our archived scores as well
	
	[self reportNewGKScore: score forCategory: kGameCenterScoreCategory];
	[self reportNewGKScore: level forCategory: kGameCenterLevelCategory];
}

+(void)reportNewGKScore: (NSUInteger)score forCategory: (NSString*)category
{
	// create new GKScore object and send it to Apple's servers
    GKScore *gkScore = [[[GKScore alloc] initWithCategory:category] autorelease];
    gkScore.value = score;
	
	[self reportGKScore: gkScore];
}

// If a score report fails for some reason, the score/combos/level is 
// written to files and resubmitted at a later date

+(void)reportGKScore: (GKScore *)theScore
{
	[theScore reportScoreWithCompletionHandler:^(NSError *error) 
	 {
		 if (error != nil)
		 {
			 //NSLog(@"%@", [error localizedDescription]);
			 
			 // we only archive score if there is a player ID 
			 if (theScore.playerID != nil)
				 [self archiveScore: theScore];
		 }
		 else
		 {
			 //NSLog(@"Posted");
		 }
	 }];
}

+(void)archiveScore: (GKScore *)theScore
{	
	// filename for each archived score is RAND-UNIXDATE-SCOREVALUE.SUFFIX to guarantee uniqueness
	uint32_t rand = arc4random() % 100000;
	NSString *scoreFileName = [NSString stringWithFormat: @"%d-%f-%d%@", rand, [[theScore date] timeIntervalSince1970], (NSUInteger)theScore.value, kSavedGKScoreSuffix];
	NSString *scoresPath = [[NSFileManager documentFolder] stringByAppendingPathComponent: scoreFileName];
	[NSKeyedArchiver archiveRootObject: theScore toFile: scoresPath];
//	NSLog(@"Archiving score to %@", scoresPath);
}


// go through all files in the documents folder, read the score from them, delete them and submit their data
// if they fail, they'll just end up being written back to the folder

+(void)reportArchivedScores
{
	NSString *saveFolder = [NSFileManager documentFolder];
	NSError *err;
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: saveFolder error: &err];
	
	// find all saved score files in the folder and report the scores they contain
	for (NSString *file in files)
	{
		if ([file hasSuffix: kSavedGKScoreSuffix])
		{
			NSString *scoreFilePath = [saveFolder stringByAppendingPathComponent: file];
			GKScore *gkScore = [NSKeyedUnarchiver unarchiveObjectWithFile: scoreFilePath];
			
			if (gkScore == nil)
			{
//				NSLog(@"Error reading score from %@", scoreFilePath);
			}
			else
			{
				[[NSFileManager defaultManager] removeItemAtPath: scoreFilePath error: &err];
//				NSLog(@"Reporting archived score %@", scoreFilePath);
				[self reportGKScore: gkScore];
			}
		}
	}
}


#pragma mark -
#pragma mark Achievements

+(void)reportAchievement: (NSString *)identifier
{
	GKAchievement *achievement= [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
	achievement.percentComplete = 100.0f;
	
	if (achievement != NULL)
	{
		//Submit the Achievement...
		[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
		 {
			 if (error != nil)
			 {
				 //NSLog(@"%@", [error localizedDescription]);
			 }
			 else
			 {
				 //NSLog(@"Achievement posted");
			 }			 
		 }];
	}
}

@end
