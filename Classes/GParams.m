//
//  GParams.m
//  Pizarro
//
//  Created by Sveinbjorn Thordarson on 2/26/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "GParams.h"
#import "Constants.h"

@implementation GParams

+(NSString *)spriteFileName: (NSString *)spriteFileName
{
	if (IPAD)
	{
		return [NSString stringWithFormat: @"%@-ipad.png", spriteFileName];
	}
	return [NSString stringWithFormat: @"%@.png", spriteFileName];
}


@end
