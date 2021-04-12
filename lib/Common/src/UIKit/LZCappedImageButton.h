//
//  LZCappedImageButton.h
//
//  Created by Roderick Mann on 1/22/10.
//  Copyright 2010 Latency: Zero. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    Simple UIButton subclass simply replaces all of a button's
    background images with horiztonally stretched versions. The caps
    for the stretching are set at 1/2 the width of the image used.
    
    To take advantage of this class, specify the background images you
    want your buttons to have in IB, and set the button's class to
    YCappedImageButton. That's it. They'll look wrong in IB, but you'll
    see something for the button. But they'll behave correctly at
    runtime.
    
    Once UIButton and IB are enhanced to allow you to specify the cap/
    stretch directly, we can get rid of this subclass.
*/

@interface
LZCappedImageButton : UIButton
{
}

@end
