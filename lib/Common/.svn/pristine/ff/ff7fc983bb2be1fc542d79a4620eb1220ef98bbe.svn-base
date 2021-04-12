#ifndef __CTLine_h__
#define	__CTLine_h__

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#include <CoreText/CoreText.h>
#endif

//
//	Project Includes
//

#include "Context.h"
#include "Rect.h"

#if __OBJC__
@class NSAttributedString;
#else
struct NSAttributedString;
#endif

namespace
Graphics
{

/**
*/

class
CTLine
{
public:
						CTLine(NSAttributedString* inString);
						
						CTLine(CFStringRef inString, CFDictionaryRef inAttrs);
						~CTLine();
							
	void				draw(const Context& inCTX) const;
	
	Rect				getImageBounds(const Context& inCTX) const;
	double				getTypographicBounds(CGFloat* outAscent, CGFloat* outDescent, CGFloat* outLeading) const;
	
	operator			CTLineRef() const				{ return mLineRef; }
	
private:
	CTLineRef			mLineRef;
};

inline
CTLine::CTLine(CFStringRef inString, CFDictionaryRef inAttrs)
	:
	mLineRef(NULL)
{
	if (inString != NULL && inAttrs != NULL)
	{
		CFAttributedStringRef attrString
			= ::CFAttributedStringCreate(kCFAllocatorDefault,
											inString,
											inAttrs);
		mLineRef = ::CTLineCreateWithAttributedString(attrString);
		::CFRelease(attrString);
	}
}

inline
CTLine::~CTLine()
{
	if (mLineRef != NULL)
	{
		::CFRelease(mLineRef);
	}
}


inline
void
CTLine::draw(const Context& inCTX) const
{
	if (mLineRef != NULL)
	{
		::CTLineDraw(mLineRef, inCTX);
	}
}

inline
Rect
CTLine::getImageBounds(const Context& inCTX) const
{
	if (mLineRef == NULL)
	{
		return Rect();
	}
	
	//	TODO: This code probably generates a constructor call
	//		that could be avoided with some ugly casting…
	
	Rect r = ::CTLineGetImageBounds(mLineRef, inCTX);
	return r;
}

inline
double
CTLine::getTypographicBounds(CGFloat* outAscent, CGFloat* outDescent, CGFloat* outLeading) const
{
	if (mLineRef == NULL)
	{
		return 0;
	}
	
	return ::CTLineGetTypographicBounds(mLineRef,
										outAscent,
										outDescent,
										outLeading);
}



}

#endif	//	__CTLine_h__
