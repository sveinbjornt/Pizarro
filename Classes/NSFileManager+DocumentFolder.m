//
//  NSFileManager+DocumentFolder.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson 10.11.2010.
//  Copyright 2010 Corrino Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DocumentFolder)
+ (NSString *)documentFolder;
- (NSString *)pathOfFileInDocumentFolder:(NSString *)filename;
@end


@implementation NSFileManager (DocumentFolder)

+ (NSString *)documentFolder {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	if ([paths count])
		return [paths objectAtIndex:0];
    
	return nil;
}

- (NSString *)pathOfFileInDocumentFolder:(NSString *)filename {
	return [[NSFileManager documentFolder] stringByAppendingPathComponent:filename];
}

@end
