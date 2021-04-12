//
//  UIView+LZ.m
//
//  Created by Roderick Mann on 11/19/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "UIView+LZ.h"

//
//	Standard Imports
//

#import <QuartzCore/QuartzCore.h>







@implementation UIView (LZ)

- (UIImage*)
renderImage
{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext: UIGraphicsGetCurrentContext()];
	UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}


@end
