/**
	LZAttributedLabel.m
	
	Created by Roderick Mann on 1/18/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "LZAttributedLabel.h"

//
//	Standard Imports
//

#import <CoreText/CoreText.h>


//
//	Project Imports
//

#import "LZAttributedStringBuilder.h"

#define	qDrawBoundingRects			0



@interface LZAttributedLabel()

- (void)			updateFramesetter;

@end


@implementation LZAttributedLabel

- (id)
initWithFrame: (CGRect) inFrame
{
	self = [super initWithFrame: inFrame];
	if (self != nil)
	{
		self.enabled = false;
	}
	return self;
}

- (void)
awakeFromNib
{
	[super awakeFromNib];
	
	self.enabled = false;
}

/**
	Given the current dimensions of this view, update the framesetter
	used to render the text in it, and update the text height value.
*/

- (void)
updateFramesetter
{
	//	Delete the old frame setter, if any…
	
	if (mFramesetter != NULL)		CFRelease(mFramesetter);
	
	//	Create a new one with the current string…
	
	mFramesetter = CTFramesetterCreateWithAttributedString(CFBridgingRetain(self.text));
	
	//	Compute the actual string height…
	
	CGSize boundsSize = self.bounds.size;
	boundsSize.height = CGFLOAT_MAX;
	CFRange fitRange = { 0 };
	CGSize actualSize = CTFramesetterSuggestFrameSizeWithConstraints(mFramesetter,
																		CFRangeMake(0, 0),
																		NULL,
																		boundsSize,
																		&fitRange);
	self.textHeight = ceil(actualSize.height) + 1.0f;	//	Add 1 unit to the height; for some
														//	reason, sometimes the last line won't
														//	render without this.
	
	//	Create the frame path…
	
	CGPathRelease(mFramePath); 
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect pathRect = self.bounds;
	//pathRect.size.height = self.textHeight;
	CGPathAddRect(path, NULL, pathRect);
	mFramePath = path;
	
	//NSLog(@"label height: %f, text height: %f; fit range: %ld", self.bounds.size.height, self.textHeight, fitRange.length);
	
	if (mFrame != NULL)				CFRelease(mFrame);
	mFrame = CTFramesetterCreateFrame(mFramesetter, CFRangeMake(0, 0), mFramePath, NULL);
}

- (void)
layoutSubviews
{
	[super layoutSubviews];
	
	[self updateFramesetter];
}

- (void)
drawRect: (CGRect) inDirtyRect
{
	if (self.text == nil || mFramesetter == NULL)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
	
	//	CoreText expects the origin in the lower-left, so invert
	//	the CTM…
	
	CGContextScaleCTM(ctx, 1.0f, -1.0f);
	CGContextTranslateCTM(ctx, 0.0f, -self.bounds.size.height);
	
	CTFrameDraw(mFrame, ctx);
	
#if 0
	CGRect b = self.bounds;
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextStrokeRect(ctx, b);
#endif
}

- (void)
dealloc
{
	if (mFramesetter != NULL)		CFRelease(mFramesetter);
	if (mFrame != NULL)				CFRelease(mFrame);
	CGPathRelease(mFramePath);
	
#if !ARC_ENABLED
	[mText release];
    [super dealloc];
#endif
}

#pragma mark -
#pragma mark • Hit Testing

- (void)
touchesEnded: (NSSet*) inTouches
	withEvent: (UIEvent*) inEvent
{
	//	If we're disabled, or there's not a single touch,
	//	ignore it…
	
	if (!self.enabled || inTouches.count != 1)
	{
		[super touchesEnded: inTouches withEvent: inEvent];
		return;
	}
	
	UITouch* touch = [inTouches anyObject];
	CGPoint loc = [touch locationInView: self];
	loc.y = self.bounds.size.height - loc.y;
	
	//	Iterate over the lines in the CTFrame and build rects to
	//	test…
	
	NSArray* lines = CFBridgingRelease(CTFrameGetLines(mFrame));
	if (lines.count == 0)
	{
		return;
	}
	
	CGPoint* origins = (CGPoint*) calloc(lines.count, sizeof (CGPoint));
	CTFrameGetLineOrigins(mFrame, CFRangeMake(0, 0), origins);
	
	//OKLog(@"Hit: %@", NSStringFromCGPoint(loc));
	
	NSInteger i = 0;
	for (id obj in lines)
	{
		//	If the tap is on a line…
		
		CTLineRef line = CFBridgingRetain(obj);
		
		CGPoint lineOrigin = origins[i];
		
		float ascent;
		float descent;
		float leading;
		float w = CTLineGetTypographicBounds(line,
											&ascent,
											&descent,
											&leading);
		CGRect b;
		b.origin = lineOrigin;
		b.origin.y -= descent;
		b.size.width = w;
		b.size.height = ascent + descent;
		if (CGRectContainsPoint(b, loc))
		{
			CGPoint linePt = { loc.x - lineOrigin.x, loc.y - lineOrigin.y };
			CFIndex pos = CTLineGetStringIndexForPosition(line, linePt);
			if (pos != kCFNotFound && pos < (CFIndex) self.text.length)
			{
				//OKLog(@"Line (%@) pos (%ld)", NSStringFromCGPoint(lineOrigin), pos);
				
				NSRange	 linkRange;
				NSDictionary* attrs = [self.text attributesAtIndex: pos effectiveRange: &linkRange];
				//OKLog(@"Hit attrs: %@", attrs);
				
				YAttributedLabelLinkHit* hit = [[YAttributedLabelLinkHit alloc] init];
				hit.string = self.text;
				hit.linkRange = linkRange;
				hit.context = [attrs valueForKey: kYAttributedStringBuilderKeyLinkContext];
				
				id target = [attrs valueForKey: kYAttributedStringBuilderKeyLinkTarget];
				NSString* s = [attrs valueForKey: kYAttributedStringBuilderKeyLinkSelector];
				SEL sel = NSSelectorFromString(s);
				[target performSelector: sel withObject: hit];
#if !ARC_ENABLED
				[hit release];
#endif
			}
		}
		i += 1;
	}
	
	free(origins);
}


#pragma mark -
#pragma mark • Attributes

- (void)
setText: (NSAttributedString*) inText
{
	if (mText == inText)
	{
		return;
	}
	
#if !ARC_ENABLED
	[mText release];
#endif
	mText = [inText copy];
	
	mNeedsHitBounds = true;
	
	[self updateFramesetter];
	[self setNeedsLayout];
	[self setNeedsDisplay];
}

- (void)
setEnabled: (bool) inEnabled
{
	if (mEnabled == inEnabled)
	{
		return;
	}
	
	mEnabled = inEnabled;
	
	if (mEnabled)
	{
		mNeedsHitBounds = true;
	}
	
	[self setNeedsDisplay];
}

@synthesize text			=	mText;
@synthesize enabled			=	mEnabled;
@synthesize textHeight		=	mTextHeight;

@end


@implementation YAttributedLabelLinkHit

@synthesize string			=	mString;
@synthesize linkRange		=	mLinkRange;
@synthesize context			=	mContext;

@end
