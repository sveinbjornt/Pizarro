/*
 *  Common.c
 *  Pizarro
 *
 *  Created by Sveinbjorn Thordarson on 2/16/11.
 *  Copyright 2011 Corrino Software. All rights reserved.
 *
 */

#import <stdlib.h>

static inline int RandomBetween(int min_n, int max_n)
{
	return arc4random() % (max_n - min_n + 1) + min_n;
}