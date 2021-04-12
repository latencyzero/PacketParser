/**
	GraphicsContext.h
	SatTrackX

	Created by Roderick Mann on 11/26/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#ifndef __GraphicsContext_h__
#define	__GraphicsContext_h__


//
//	Standard Includes
//

#include <cmath>

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#endif


//
//	Project Includes
//

#include "AffineTransform.h"
#include "Color.h"
#include "Image.h"
#include "Rect.h"



//
//	Forward Declarations
//

class CString;


namespace
Graphics
{

class Gradient;

/**
	C++ wrapper for a Quartz (CoreGraphics) CGContextRef.
	
	To get at this from Cocoa:
	
	NSGraphicsContext* cocoaCTX = [NSGraphicsContext currentContext];
	CGContextRef cgCTX = (CGContextRef) [cocoaCTX graphicsPort];
	Graphics::Context ctx(cgCTX);
	
	From UIKit:

*/

class
Context
{
public:
					Context();
					Context(CGContextRef inRef);
					
					/**
						Creates a bitmap context
					*/
					
					Context(size_t inWidth,
							size_t inHeight,
							size_t inBitsPerComponent,
							size_t inBytesPerRow,
							CGColorSpaceRef inColorSpace,
							CGBitmapInfo inInfo,
							void* inData = NULL);
							
					Context(size_t inWidth,
							size_t inHeight);
					Context(const Rect& inFrame);
							
	CGContextRef	getCGContext() const						{ return mCGContext; }
					operator CGContextRef() const				{ return mCGContext; }
	
	void			translate(CGFloat inX, CGFloat inY);
	void			translate(const Point& inVal);
	void			scale(CGFloat inX, CGFloat inY);
	void			rotate(CGFloat inAngle);
	void			rotateAbout(CGFloat inAngle, CGFloat inX, CGFloat inY);
	void			rotateAbout(CGFloat inAngle, const Point& inP);
	
	
	void			scaleText(CGFloat inX, CGFloat inY);
	void			rotateText(CGFloat inAngle);
	AffineTransform getTextMatrix() const;
	void			setTextMatrix(const AffineTransform& inVal);
	void			setTextPosition(CGFloat inX, CGFloat inY);
	void			setTextMatrixToIdentity();
	
#if !TARGET_OS_IPHONE	
	void			setShouldSubpixelPositionFonts(bool inVal);
	void			setAllowsSubpixelFontsPositioning(bool inVal);
	void			setShouldSubpixelQuantizeFonts(bool inVal);
	void			setAllowsSubpixelQuantizeFonts(bool inVal);
#endif

	/**
		getCoordinateScale() returns the first scaling component. Most
		drawing operatins use uniform scaling. This convenience method makes
		it easy to keep line widths and radii unscaled.
	*/
	CGFloat			getCoordinateScale() const					{ return getCTM().a; }
	
	void			beginPath();
	void			moveTo(CGFloat inX, CGFloat inY);
	void			moveTo(const Point& inPt);
	void			moveTo(const CGPoint& inPt);
	void			addLineTo(CGFloat inX, CGFloat inY);
	void			addLineTo(const Point& inPt);
	void			addLineTo(const CGPoint& inPt);
	void			addRect(const Rect& inRect) const;
	void			addRect(const Rect& inRect, CGFloat inRadius) const;
	void			addCircle(const Point& inCenter, CGFloat inRadius);
	void			addCircle(CGFloat inRadius);
	void			addArc(const Point& inCenter,
							CGFloat inRadius,
							CGFloat inStartAngle,
							CGFloat inEndAngle,
							bool inCW = true);
	void			addArc(CGFloat inRadius,
							CGFloat inStartAngle,
							CGFloat inEndAngle,
							bool inCW = true);
	
	void			closePath();
	
	void			clipToRect(const Rect& inRect);
	void			clipToRect(const CGRect& inRect);
	void			clipToPath();
	
	void			fillRect(const Rect& inRect);
	void			fillRect(const CGRect& inRect);
	
	void			strokeRect(const Rect& inRect);
	void			strokeRect(const CGRect& inRect);
	
	void			strokeRectInset(const Rect& inRect);
	void			strokeRectInset(const CGRect& inRect);
	
	void			strokeAndFillRect(const Rect& inRect);
	void			strokeAndFillRect(const CGRect& inRect);
	
	void			drawPath(CGPathDrawingMode inMode = kCGPathFillStroke);
	void			strokePath();
	void			fillPath();
	void			fillEOPath();
	
	void			setLineWidth(CGFloat inWidth);
	void			setLineCap(CGLineCap inCap);
	void			setLineJoin(CGLineJoin inJoin);
	void			setLineDash(CGFloat inPhase, const CGFloat* inDashLengths, UInt32 inNumLengths);
	void			setStrokeColor(CGFloat inWhite, CGFloat inAlpha = 1.0);
	void			setStrokeColor(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha = 1.0);
	void			setStrokeColor(const Color& inColor);
	void			setStrokeColor(CGColorRef inColor);
	void			setFillColor(CGFloat inWhite, CGFloat inAlpha = 1.0);
	void			setFillColor(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha = 1.0);
	void			setFillColor(const Color& inColor);
	void			setFillColor(CGColorRef inColor);
	
	void			setShadow(CGFloat inOffsetX,
								CGFloat inOffsetY,
								CGFloat inBlur,
								CGFloat inRed,
								CGFloat inGreen,
								CGFloat inBlue,
								CGFloat inAlpha = 1.0f);
	void			clearShadow();
	
	void			beginTransparencyLayer(CFDictionaryRef inAuxInfo = NULL);
	void			endTransparencyLayer();
	
	void			setAntiAlias(bool inVal);
	
	void			fillRectWithVerticalGradient(const Rect& inRect, const Gradient& inGradient);
	
	void			draw(const CFStringRef inText, const Point& inPt);
	void			draw(const CString& inText, const Point& inPt);
	void			draw(const CGImageRef inImage, const Rect& inRect);
	void			draw(const Image& inImage, const Rect& inRect);
	
	void			saveState();
	void			restoreState();
	
	void			flush();
	
	void			transform(CGPoint& ioPt) const;
	AffineTransform	getCTM() const;

private:
	CGContextRef	mCGContext;
	CGFloat			mCoordinateScale;
};




inline
Context::Context(CGContextRef inRef)
	:
	mCGContext(inRef),
	mCoordinateScale(1.0f)
{
	CGContextSelectFont(getCGContext(), "Helvetica Neue", 20.0f, kCGEncodingMacRoman); 
}




inline
void
Context::translate(CGFloat inX, CGFloat inY)
{
	::CGContextTranslateCTM(getCGContext(), inX, inY);
}

inline
void
Context::translate(const Point& inVal)
{
	translate(inVal.getX(), inVal.getY());
}

inline
void
Context::scale(CGFloat inX, CGFloat inY)
{
	::CGContextScaleCTM(getCGContext(), inX, inY);
}

inline
void
Context::rotate(CGFloat inAngle)
{
	::CGContextRotateCTM(getCGContext(), inAngle);
}

inline
void
Context::rotateAbout(CGFloat inAngle, CGFloat inX, CGFloat inY)
{
	translate(inX, inY);
	rotate(inAngle);
	translate(-inX, -inY);
}

inline
void
Context::rotateAbout(CGFloat inAngle, const Point& inP)
{
	translate(inP);
	rotate(inAngle);
	translate(-inP);
}

inline
void
Context::scaleText(CGFloat inX, CGFloat inY)
{
	AffineTransform t = ::CGContextGetTextMatrix(getCGContext());
	t.a *= inX;
	t.d *= inY;
	::CGContextSetTextMatrix(getCGContext(), t);
}

inline
void
Context::rotateText(CGFloat inAngle)
{
	AffineTransform t = CGAffineTransformMakeRotation(inAngle);
	setTextMatrix(t);
}


inline
AffineTransform
Context::getTextMatrix() const
{
	return ::CGContextGetTextMatrix(getCGContext());
}

inline
void
Context::setTextMatrix(const AffineTransform& inVal)
{
	::CGContextSetTextMatrix(getCGContext(), inVal);
}

inline
void
Context::setTextMatrixToIdentity()
{
	::CGContextSetTextMatrix(getCGContext(), CGAffineTransformIdentity);
}

#if !TARGET_OS_IPHONE
inline
void
Context::setShouldSubpixelPositionFonts(bool inVal)
{
	::CGContextSetShouldSubpixelPositionFonts(getCGContext(), inVal);
}

inline
void
Context::setAllowsSubpixelFontsPositioning(bool inVal)
{
	::CGContextSetAllowsFontSubpixelPositioning(getCGContext(), inVal);
}

inline
void
Context::setShouldSubpixelQuantizeFonts(bool inVal)
{
	::CGContextSetShouldSubpixelQuantizeFonts(getCGContext(), inVal);
}

inline
void
Context::setAllowsSubpixelQuantizeFonts(bool inVal)
{
	::CGContextSetAllowsFontSubpixelQuantization(getCGContext(), inVal);
}
#endif

inline
void
Context::setTextPosition(CGFloat inX, CGFloat inY)
{
	::CGContextSetTextPosition(getCGContext(), inX, inY);
}

inline
void
Context::beginPath()
{
	::CGContextBeginPath(getCGContext());
}

inline
void
Context::moveTo(CGFloat inX, CGFloat inY)
{
	::CGContextMoveToPoint(getCGContext(), inX, inY);
}

inline
void
Context::moveTo(const Point& inPt)
{
	moveTo(inPt.getX(), inPt.getY());
}

inline
void
Context::moveTo(const CGPoint& inPt)
{
	moveTo(inPt.x, inPt.y);
}

inline
void
Context::addLineTo(CGFloat inX, CGFloat inY)
{
	::CGContextAddLineToPoint(getCGContext(), inX, inY);
}

inline
void
Context::addLineTo(const Point& inPt)
{
	addLineTo(inPt.getX(), inPt.getY());
}

inline
void
Context::addLineTo(const CGPoint& inPt)
{
	addLineTo(inPt.x, inPt.y);
}

inline
void
Context::addRect(const Rect& inRect) const
{
	::CGContextAddRect(getCGContext(), inRect);
}

inline
void
Context::addCircle(const Point& inCenter, CGFloat inRadius)
{
	moveTo(inCenter.getX() + inRadius, inCenter.getY());
	::CGContextAddArc(getCGContext(), inCenter.getX(), inCenter.getY(), inRadius, 0.0f, M_PI * 2.0f, true);
}

inline
void
Context::addCircle(CGFloat inRadius)
{
	//moveTo(0.0f, 0.0f);
	::CGContextAddArc(getCGContext(), 0.0f, 0.0f, inRadius, 0.0f, M_PI * 2.0f, true);
}

inline
void
Context::closePath()
{
	::CGContextClosePath(getCGContext());
}
	
inline
void
Context::strokeRect(const CGRect& inRect)
{
	::CGContextStrokeRect(getCGContext(), inRect);
}

inline
void
Context::drawPath(CGPathDrawingMode inMode)
{
	::CGContextDrawPath(getCGContext(), inMode);
}

inline
void
Context::strokePath()
{
	::CGContextStrokePath(getCGContext());
}

inline
void
Context::fillPath()
{
	::CGContextFillPath(getCGContext());
}

inline
void
Context::fillEOPath()
{
	::CGContextEOFillPath(getCGContext());
}


inline
void
Context::strokeRect(const Rect& inRect)
{
	CGRect	r = inRect;
	strokeRect(r);
}

inline
void
Context::strokeRectInset(const Rect& inRect)
{
	Rect r = inRect;
	r.origin.x += 0.5f;
	r.origin.y += 0.5f;
	r.size.width -= 1.0f;
	r.size.height -= 1.0f;
	strokeRect(r);
}

inline
void
Context::strokeRectInset(const CGRect& inRect)
{
	Rect r = inRect;
	r.origin.x += 0.5f;
	r.origin.y += 0.5f;
	r.inset(1.0f, 1.0f);
	strokeRect(r);
}


inline
void
Context::strokeAndFillRect(const Rect& inRect)
{
	CGRect	r = inRect;
	strokeAndFillRect(r);
}

inline
void
Context::strokeAndFillRect(const CGRect& inRect)
{
	addRect(inRect);
	drawPath(kCGPathFillStroke);
}

inline
void
Context::clipToRect(const Rect& inRect)
{
	CGRect	r = inRect;
	clipToRect(r);
}

inline
void
Context::clipToRect(const CGRect& inRect)
{
	::CGContextClipToRect(getCGContext(), inRect);
}

inline
void
Context::clipToPath()
{
	::CGContextClip(getCGContext());
}

inline
void
Context::fillRect(const Rect& inRect)
{
	CGRect	r = inRect;
	fillRect(r);
}

inline
void
Context::fillRect(const CGRect& inRect)
{
	::CGContextFillRect(getCGContext(), inRect);
}

inline
void
Context::setLineWidth(CGFloat inWidth)
{
	inWidth /= mCoordinateScale;
	::CGContextSetLineWidth(getCGContext(), inWidth);
}

inline
void
Context::setLineCap(CGLineCap inCap)
{
	::CGContextSetLineCap(getCGContext(), inCap);
}

inline
void
Context::setLineJoin(CGLineJoin inJoin)
{
	::CGContextSetLineJoin(getCGContext(), inJoin);
}

inline
void
Context::setLineDash(CGFloat inPhase, const CGFloat* inDashLengths, UInt32 inNumLengths)
{
	::CGContextSetLineDash(getCGContext(), inPhase, reinterpret_cast<const CGFloat*>(inDashLengths), inNumLengths);
}

inline
void
Context::setStrokeColor(CGFloat inWhite, CGFloat inAlpha)
{
	::CGContextSetRGBStrokeColor(getCGContext(), inWhite, inWhite, inWhite, inAlpha);
}

inline
void
Context::setStrokeColor(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha)
{
	::CGContextSetRGBStrokeColor(getCGContext(), inRed, inGreen, inBlue, inAlpha);
}

inline
void
Context::setStrokeColor(CGColorRef inColor)
{
	::CGContextSetStrokeColorWithColor(getCGContext(), inColor);
}

inline
void
Context::setStrokeColor(const Color& inColor)
{
	::CGContextSetRGBStrokeColor(getCGContext(), inColor.getRed(), inColor.getGreen(), inColor.getBlue(), inColor.getAlpha());
}


inline
void
Context::setFillColor(CGFloat inWhite, CGFloat inAlpha)
{
	::CGContextSetRGBFillColor(getCGContext(), inWhite, inWhite, inWhite, inAlpha);
}

inline
void
Context::setFillColor(CGFloat inRed, CGFloat inGreen, CGFloat inBlue, CGFloat inAlpha)
{
	::CGContextSetRGBFillColor(getCGContext(), inRed, inGreen, inBlue, inAlpha);
}

inline
void
Context::setFillColor(CGColorRef inColor)
{
	::CGContextSetFillColorWithColor(getCGContext(), inColor);
}

inline
void
Context::setFillColor(const Color& inColor)
{
	::CGContextSetRGBFillColor(getCGContext(), inColor.getRed(), inColor.getGreen(), inColor.getBlue(), inColor.getAlpha());
}

inline
void
Context::draw(const CGImageRef inImage, const Rect& inRect)
{
	::CGContextDrawImage(getCGContext(), inRect, inImage);
}

inline
void
Context::draw(const Image& inImage, const Rect& inRect)
{
	::CGContextDrawImage(getCGContext(), inRect, inImage.getImageRef());
}

inline
void
Context::saveState()
{
	::CGContextSaveGState(getCGContext());
}

inline
void
Context::restoreState()
{
	::CGContextRestoreGState(getCGContext());
}
	
inline
void
Context::beginTransparencyLayer(CFDictionaryRef inAuxInfo)
{
	::CGContextBeginTransparencyLayer(getCGContext(), inAuxInfo);
}

inline
void
Context::endTransparencyLayer()
{
	::CGContextEndTransparencyLayer(getCGContext());
}

inline
void
Context::setAntiAlias(bool inVal)
{
	::CGContextSetShouldAntialias(getCGContext(), inVal);
}

inline
void
Context::transform(CGPoint& ioPt) const
{
	AffineTransform txfm = getCTM();
	txfm.transform(ioPt);
}


inline
AffineTransform
Context::getCTM() const
{
	return ::CGContextGetCTM(getCGContext());
}



}	//	namespace Graphics


#endif	//	__GraphicsContext_h__
