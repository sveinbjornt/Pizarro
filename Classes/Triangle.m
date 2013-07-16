//
//  Triangle.m
//  Pithon
//
//  Created by Sveinbjorn Thordarson on 2/16/11.
//  Copyright 2011 Corrino Software. All rights reserved.
//

#import "Triangle.h"


@implementation Triangle

#pragma mark -
#pragma mark Drawing

- (void)draw {
	if (expanding)
		[self drawExpandingTriangle];
	else
		[self drawTriangle];
}

- (void)drawExpandingTriangle {
	CGPoint p = CGPointZero;
    
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_POINT_SMOOTH);
    
	BOOL white = NO;
    
	for (int i = size; i > 0; i -= 8) {
		CGPoint vertices[] = {
			{ p.x, p.y + i },
			{ p.x - (i * 0.69), p.y - (i * 0.69) },
			{ p.x + (i  * 0.69), p.y - (i * 0.69) }
		};
        
		if (white)
			glColor4ub(255, 255, 255, opacity);
		else
			glColor4ub(color.r, color.g, color.b, opacity);
        
		white = !white;
        
		glVertexPointer(2, GL_FLOAT, 0, &vertices);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
	}
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

- (void)drawTriangle {
	CGPoint p = CGPointZero;
    
	glColor4ub(color.r, color.g, color.b, opacity);
    
	CGPoint vertices[] = {
		{ p.x, p.y + size },
		{ p.x - (size * 0.69), p.y - (size * 0.69) },
		{ p.x + (size * 0.69), p.y - (size * 0.69) }
	};
    
    
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	glVertexPointer(2, GL_FLOAT, 0, &vertices);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
    
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
	return @"▴";
}

+ (float)textSymbolSizeForHUD {
	return kHUDFontSize + 12;
}

@end
