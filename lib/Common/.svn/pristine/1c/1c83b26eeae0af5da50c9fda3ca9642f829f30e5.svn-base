#import <UIKit/UIKit.h>


@interface UIButton(LZ)

/**
    A very common design involves custom buttons with background images that
    match the button vertically, but need to be stretched horizontally to
    match the button width. The provided image is just wide enough to define the
    two end caps, and so must be split down the middle and stretched.
    
    This method replaces the image specified in the button (usually in IB) with
    a horizontally stretched version of the image, capped at one-half the width
    of the image. For each OS-defined button state (normal, highighted, selected,
    disabled) with an image, a new image is created to replace it.
*/

- (void)    stretchCappedBackgroundsHorizontally;
- (void)    stretchCappedBackgroundsHorizontallyForState: (UIControlState) inState;

/**
    IB doesn't allow us to set the image to be used when a button
    is both highlighted and selected. This method just grabs the
    image used when highlighted and sets it for highlighted & selected as
    well. (Background images only.)
    
    It also sets the text color for the H&S state to be the same as for the
    selected state.
*/

- (void)	setHighlightedSelectedState;


/**
	Replaces the label’s font with the specified font. Maintains the size
	and other attributes. This is necessary until IB is fixed to allow
	specifying custom fonts directly.
*/

- (void)	replaceFont: (NSString*) inFontName;

@end
