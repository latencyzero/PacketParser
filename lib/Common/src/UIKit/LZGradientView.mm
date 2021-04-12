//
//  LZGradientView.mm
//
//  Created by Roderick Mann on 6/12/09.
//  Copyright 2009 Latency: Zero. All rights reserved.
//

#import "LZGradientView.h"



//
//	Project Imports
//

#import "Color.h"
#import "Context.h"
#import "Gradient.h"
#import "StSaveContext.h"




@implementation LZGradientView

@synthesize startColor = mStartColor;
@synthesize endColor = mEndColor;
@synthesize borderColor = mBorderColor;
@synthesize cornerRadius = mCornerRadius;



- (id)
initWithFrame: (CGRect) inFrame
{
	self = [super initWithFrame: inFrame];
	if (self != nil)
	{
		self.startColor = [UIColor grayColor];
		self.endColor = [UIColor whiteColor];
		self.borderColor = self.startColor;
		self.cornerRadius = 7.0f;
		self.backgroundColor = [UIColor clearColor];
		self.opaque = false;
	}
	return self;
}

- (void)
awakeFromNib
{
#if 0
	self.startColor = [UIColor grayColor];
	self.endColor = [UIColor whiteColor];
	self.borderColor = self.startColor;
	self.cornerRadius = 7.0f;
	self.backgroundColor = [UIColor clearColor];
	self.opaque = false;
#endif
}

#if !ARC_ENABLED
- (void)
dealloc
{
	[mStartColor release];
	[mEndColor release];
	[mBorderColor release];
	
	[super dealloc];
}
#endif

- (void)
setStartColor: (UIColor*) inVal
{
#if !ARC_ENABLED
	[mStartColor release];
	[inVal retain];
#endif
	mStartColor = inVal;
	[self setNeedsDisplay];
}

- (void)
setEndColor: (UIColor*) inVal
{
#if !ARC_ENABLED
	[mEndColor release];
	[inVal retain];
#endif
	mEndColor = inVal;
	[self setNeedsDisplay];
}

- (void)
setBorderColor: (UIColor*) inVal
{
#if !ARC_ENABLED
	[mBorderColor release];
	[inVal retain];
#endif
	mBorderColor = inVal;
	[self setNeedsDisplay];
}

- (void)
setCornerRadius: (CGFloat) inVal
{
	mCornerRadius = inVal;
	[self setNeedsDisplay];
}


- (void)
drawRect: (CGRect) inRect
{
	CGContextRef sysCTX = ::UIGraphicsGetCurrentContext();
	Graphics::Context ctx(sysCTX);
	
	//	Draw the gradient only within our rounded rect area…
	
	if (self.startColor != nil && self.endColor != nil)
	{
		Graphics::Color c1 = self.startColor.CGColor;
		Graphics::Color c2 = self.endColor.CGColor;
		
		{
			Graphics::StSaveContext		saveCTX(ctx);
			
			ctx.addRect(self.bounds, self.cornerRadius);
			ctx.clipToPath();
			
			Graphics::Gradient gradient(c1, c2);
			gradient.drawLinear(ctx, 0.0f, 0.0f, 0.0f, self.bounds.size.height);
		}
	}
	
	if (self.borderColor != nil)
	{
		Graphics::Color b = self.borderColor.CGColor;
		ctx.setStrokeColor(b);
		ctx.addRect(self.bounds, self.cornerRadius);
		ctx.strokePath();
	}
}



@end
