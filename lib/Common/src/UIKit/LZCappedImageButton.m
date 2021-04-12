//
//  LZCappedImageButton.m
//
//  Created by Roderick Mann on 1/22/10.
//  Copyright 2010 Latency: Zero. All rights reserved.
//

#import "LZCappedImageButton.h"

//
//  Project Imports
//

#import "UIButton+LZ.h"


@implementation LZCappedImageButton

/**
	Horizontally stretch the background image, and set the selected-depressed
	state.
*/

- (void)
awakeFromNib
{
    [self stretchCappedBackgroundsHorizontally];
	[self setHighlightedSelectedState];
}

@end
