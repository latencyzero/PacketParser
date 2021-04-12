//
//  LZCappedImageView.h
//  FantasyBaseball
//
//  Created by Roderick Mann on 2/8/10.
//  Copyright 2010 Latency: Zero All rights reserved.
//

#import <UIKit/UIKit.h>

/**
	This image class automatically caps and stretches the image to half
	the image size.
	
	Currently only does this horiztonally. If we need it vertically as
	well, we'll add two properties for stretching in H and V, and have
	H default to true and V to false.
*/

@interface
LZCappedImageView : UIImageView
{

}

@end
