//
//  LZCappedImageView.m
//  FantasyBaseball
//
//  Created by Roderick Mann on 2/8/10.
//  Copyright 2010 Latency: Zero All rights reserved.
//

#import "LZCappedImageView.h"


@implementation LZCappedImageView

- (void)
awakeFromNib
{
    UIImage* image = self.image;
    if (image != nil)
	{
        image = [image stretchableImageWithLeftCapWidth: image.size.width / 2
                        topCapHeight: 0];
        self.image = image;
    }
}



@end
