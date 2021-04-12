#import "UIButton+LZ.h"


//
//	Project Imports
//

#import "UILabel+LZ.h"



@implementation UIButton(LZ)

- (void)
stretchCappedBackgroundsHorizontally
{
    [self stretchCappedBackgroundsHorizontallyForState: UIControlStateNormal];
    [self stretchCappedBackgroundsHorizontallyForState: UIControlStateHighlighted];
    [self stretchCappedBackgroundsHorizontallyForState: UIControlStateDisabled];
    [self stretchCappedBackgroundsHorizontallyForState: UIControlStateSelected];
    [self stretchCappedBackgroundsHorizontallyForState: UIControlStateHighlighted | UIControlStateSelected];
}

- (void)
stretchCappedBackgroundsHorizontallyForState: (UIControlState) inState
{
    UIImage* image = [self backgroundImageForState: inState];
    if (image != nil)
	{
        image = [image stretchableImageWithLeftCapWidth: image.size.width / 2
                        topCapHeight: 0];
        [self setBackgroundImage: image forState: inState];
    }
}

- (void)
setHighlightedSelectedState
{
    UIImage* image = [self backgroundImageForState: UIControlStateHighlighted];
    [self setBackgroundImage: image forState: UIControlStateHighlighted | UIControlStateSelected];
    
    UIColor* textColor = [self titleColorForState: UIControlStateSelected];
    [self setTitleColor: textColor forState: UIControlStateHighlighted | UIControlStateSelected];
}

- (void)
replaceFont: (NSString*) inFontName
{
	[self.titleLabel replaceFont: inFontName];
}

@end
