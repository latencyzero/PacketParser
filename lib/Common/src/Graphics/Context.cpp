/**
	GraphicsContext.h
	SatTrackX

	Created by Roderick Mann on 11/26/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#include "Context.h"

//
//	Standard Includes
//

#include <cstdio>

//
//	Project Includes
//

//#include "CString.h"
#include "Gradient.h"
#include "Point.h"







namespace Graphics
{

const CGFloat kEpsilon				=	0.000000001f;


Context::Context(size_t inWidth,
					size_t inHeight,
					size_t inBitsPerComponent,
					size_t inBytesPerRow,
					CGColorSpaceRef inColorSpace,
					CGBitmapInfo inInfo,
					void* inData)
	:
	mCGContext(NULL),
	mCoordinateScale(1.0f)
{
	mCGContext = ::CGBitmapContextCreate(inData,
											inWidth,
											inHeight,
											inBitsPerComponent,
											inBytesPerRow,
											inColorSpace,
											inInfo);
	if (mCGContext == NULL)
	{
		std::printf("Error creating CGBitmapContext\n");
	}
}

Context::Context(size_t inWidth,
					size_t inHeight)
	:
	mCGContext(NULL),
	mCoordinateScale(1.0f)
{
	CGColorSpaceRef colorSpace = ::CGColorSpaceCreateDeviceRGB();
	mCGContext = ::CGBitmapContextCreate(NULL,
											inWidth,
											inHeight,
											8,
											inWidth * 4,
											colorSpace,
											kCGImageAlphaPremultipliedLast);
	::CFRelease(colorSpace);
	if (mCGContext == NULL)
	{
		std::printf("Error creating simple CGBitmapContext\n");
	}
}

Context::Context(const Rect& inFrame)
	:
	mCGContext(NULL),
	mCoordinateScale(1.0f)
{
	size_t	width = (size_t) inFrame.width();
	size_t	height = (size_t) inFrame.height();
	
	CGColorSpaceRef colorSpace = ::CGColorSpaceCreateDeviceRGB();
	mCGContext = ::CGBitmapContextCreate(NULL,
											width,
											height,
											8,
											width * 4,
											colorSpace,
											kCGImageAlphaPremultipliedLast);
	::CFRelease(colorSpace);
	if (mCGContext == NULL)
	{
		std::printf("Error creating frame CGBitmapContext\n");
	}
}

void
Context::addArc(const Point& inCenter,
				CGFloat inRadius,
				CGFloat inStartAngle,
				CGFloat inEndAngle,
				bool inCW)
{
#if TARGET_OS_IPHONE
	int cw = !inCW;
#else
	int cw = inCW;
#endif

	::CGContextAddArc(getCGContext(),
						inCenter.x,
						inCenter.y,
						inRadius,
						inStartAngle,
						inEndAngle,
						cw);
}

void
Context::addArc(CGFloat inRadius,
				CGFloat inStartAngle,
				CGFloat inEndAngle,
				bool inCW)
{
#if TARGET_OS_IPHONE
	int cw = !inCW;
#else
	int cw = inCW;
#endif

	::CGContextAddArc(getCGContext(),
						0.0f,
						0.0f,
						inRadius,
						inStartAngle,
						inEndAngle,
						cw);
}


void
Context::addRect(const Rect& inRect, CGFloat inRadius) const
{
	if (-kEpsilon < inRadius && inRadius < kEpsilon)
	{
		::CGContextAddRect(getCGContext(), inRect);
	}
	else	// Add a round-rect
	{
		
		// Get the state we need
		CGPoint topMiddle;
		topMiddle.x = inRect.midX();
		topMiddle.y = inRect.maxY();
		
		CGPoint topLeft;
		topLeft.x = inRect.minX();
		topLeft.y = inRect.maxY();
		
		CGPoint bottomLeft;
		bottomLeft.x = inRect.minX();
		bottomLeft.y = inRect.minY();
		
		CGPoint bottomRight;
		bottomRight.x = inRect.maxX();
		bottomRight.y = inRect.minY();
		
		CGPoint topRight;
		topRight.x = inRect.maxX();
		topRight.y = inRect.maxY();


		// Add the rect
		::CGContextMoveToPoint(   getCGContext(),	topMiddle.x,		topMiddle.y);
		::CGContextAddArcToPoint( getCGContext(),	topLeft.x,			topLeft.y,			bottomLeft.x,		bottomLeft.y,	inRadius);
		::CGContextAddArcToPoint( getCGContext(),	bottomLeft.x,		bottomLeft.y,		bottomRight.x,		bottomRight.y,	inRadius);
		::CGContextAddArcToPoint( getCGContext(),	bottomRight.x,		bottomRight.y,		topRight.x,			topRight.y,		inRadius);
		::CGContextAddArcToPoint( getCGContext(),	topRight.x,			topRight.y,			topMiddle.x,		topMiddle.y,	inRadius);
		::CGContextAddLineToPoint(getCGContext(),	topMiddle.x,		topMiddle.y);
	}
}

#if 0
void
Context::draw(const CString& inText, const Point& inPt)
{
	const char* s = inText.getAsCString();
	size_t len = inText.getSize();
	::CGContextShowTextAtPoint(getCGContext(),
								inPt.getX(),
								inPt.getY(),
								s,
								len);
}
#endif

void
Context::draw(const CFStringRef inText, const Point& inPt)
{
	CFIndex		bufLen = 0;
	(void) ::CFStringGetBytes(inText, CFRangeMake(0, CFStringGetLength(inText)), kCFStringEncodingUTF8, '?', false, NULL, 0, &bufLen);
	uint8_t* s = new uint8_t[bufLen + 1];
	(void) ::CFStringGetBytes(inText, CFRangeMake(0, CFStringGetLength(inText)), kCFStringEncodingUTF8, '?', false, s, bufLen, NULL);
	s[bufLen] = 0;
	::CGContextShowTextAtPoint(getCGContext(),
								inPt.getX(),
								inPt.getY(),
								(char const*) s,
								bufLen);
}

void
Context::setShadow(CGFloat inOffsetX,
					CGFloat inOffsetY,
					CGFloat inBlur,
					CGFloat inRed,
					CGFloat inGreen,
					CGFloat inBlue,
					CGFloat inAlpha)
{
	CGSize offset = { inOffsetX, inOffsetY };
	Color color(inRed, inGreen, inBlue, inAlpha);
	::CGContextSetShadowWithColor(getCGContext(),
									offset,
									inBlur,
									color);
}

void
Context::clearShadow()
{
	CGSize offset = { 0.0f, 0.0f };
	::CGContextSetShadowWithColor(getCGContext(),
									offset,
									0.0f,
									NULL);
}

void
Context::fillRectWithVerticalGradient(const Rect& inRect, const Gradient& inGradient)
{
    //  Clip to the supplied rect (and restore when done)…
    
    CGContextSaveGState(getCGContext());
    CGContextClipToRect(getCGContext(), inRect);
    
    //  Draw a linear gradient from top to bottom…
    
	CGPoint	startPt = inRect.origin;
	CGPoint	endPt = startPt;
    endPt.y += inRect.size.height;
	::CGContextDrawLinearGradient(getCGContext(), inGradient, startPt, endPt, 0);
    
    //  Restore the GState…
    
    CGContextRestoreGState(getCGContext());
}

}	//	namespace Graphics
