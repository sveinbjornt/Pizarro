//
//  Square.m
//  Pithon
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Square.h"


@implementation Square


#pragma mark -
#pragma mark Drawing
- (void)draw {
	if (expanding)
		[self drawExpandingSquare];
	else
		[self drawSquare];
}

- (void)drawExpandingSquare {
	CGPoint p = CGPointZero;
    
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_POINT_SMOOTH);
    
	BOOL white = NO;
    
	for (int i = size; i > 0; i -= 8) {
        //		CGPoint vertices =
        //		{
        //			{ p.x - i, p.y - i },
        //			{ p.x + i, p.y - i },
        //			{ p.x + i, p.y + i },
        //			{ p.x - i, p.y + i },
        //		};
        
		if (white)
			glColor4ub(255, 255, 255, opacity);
		else
			glColor4ub(color.r, color.g, color.b, opacity);
        
		white = !white;
        
		glPointSize(i * 2);
		//glEnable(GL_POINT_SMOOTH);
        
		glVertexPointer(2, GL_FLOAT, 0, &p);
		glDrawArrays(GL_POINTS, 0, 1);
	}
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

- (void)drawSquare {
	CGPoint p = CGPointZero;
    
	glColor4ub(color.r, color.g, color.b, opacity);
	glPointSize(size * 2);
	glDisable(GL_POINT_SMOOTH);
    
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	glVertexPointer(2, GL_FLOAT, 0, &p);
	glDrawArrays(GL_POINTS, 0, 1);
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

#pragma mark -
#pragma mark Info

- (float)area {
	return (size * 2) * (size * 2);
}

+ (NSString *)textSymbol {
	return @"■";
}

+ (float)textSymbolSizeForHUD {
	return kHUDFontSize - 21;
}

@end
