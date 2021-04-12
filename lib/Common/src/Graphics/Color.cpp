/**
	@file	Color.cpp
	
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#include "Color.h"

//
//	Mac OS X Includes
//

#if TARGET_OS_IPHONE
//#include <CoreGraphics/CoreGraphics.h>
#endif



namespace
Graphics
{

Color::Color(const CGColorRef inColor)
	:
	mColorRef(NULL)
{
	*this = inColor;
	//	TODO: Get color components!
}


Color::~Color()
{
	if (mColorRef != NULL)			::CFRelease(mColorRef);
}


Color&
Color::operator=(const CGColorRef inColor)
{
	//	TODO: Assumes RGBA!
	
	size_t numComps = ::CGColorGetNumberOfComponents(inColor);
	const CGFloat* comps = ::CGColorGetComponents(inColor);
	
	mRed = comps[0];
	if (numComps == 2)
	{
		//	TODO: assumes gray
		mGreen = mRed;
		mBlue = mRed;
	}
	else if (numComps == 4)
	{
		mGreen = comps[1];
		mBlue = comps[2];
	}
	else
	{
		//	TODO: Fail/report error
	}
	mAlpha = ::CGColorGetAlpha(inColor);
	
	return *this;
}

Color::operator CGColorRef() const
{
	//	TODO: Thread safety?
	//	TOOD: Generic on Mac OS X, Device on iPhone
	
	if (mColorRef == NULL)
	{
		CGColorSpaceRef colorSpace = ::CGColorSpaceCreateDeviceRGB();
		CGFloat comps[] = { mRed, mGreen, mBlue, mAlpha };
		const_cast<Color*> (this)->mColorRef = ::CGColorCreate(colorSpace, comps);
		::CFRelease(colorSpace);
	}
	return mColorRef;
}

}
