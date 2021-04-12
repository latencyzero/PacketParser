/**
	Color.h
	
	Copyright 2007 Latency: Zero. All rights reserved.
*/


#ifndef	__Color_h__
#define __Color_h__

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#else
//#include <ApplicationServices/ApplicationServices.h>
#endif

#include <CoreGraphics/CoreGraphics.h>



namespace
Graphics
{


/**
	Color is an RGBA color.
*/

class
Color
{
public:
	/**
		Default constructor creates a black, fully opaque color.
	*/
	
	Color()
		:
		mColorRef(NULL)
	{
		set(0.0f, 0.0f, 0.0f, 1.0f);
	}
	
	/**
		Creates a color with the specified components.
		
		@param	inRed		The red component, 0.0 to 1.0
		@param	inGreen		The green component, 0.0 to 1.0
		@param	inBlue		The blue component, 0.0 to 1.0
		@param	inAlpha		The alpha component, 0.0 to 1.0, where 0.0 is
							fully transparent, and 1.0 is fully opaque. Optional,
							defaults to 1.0.
	*/
	
	Color(CGFloat inRed,
			CGFloat inGreen,
			CGFloat inBlue,
			CGFloat inAlpha = 1.0f)
		:
		mColorRef(NULL)
	{
		set(inRed, inGreen, inBlue, inAlpha);
	}
	
	Color(const CGColorRef inColor);
	
	~Color();
	
	/**
		Assigns inColor to this Color.
	*/
	
	Color&
	operator=(const Color& inColor)
	{
		mRed = inColor.mRed;
		mGreen = inColor.mGreen;
		mBlue = inColor.mBlue;
		mAlpha = inColor.mAlpha;
		
		return *this;
	}
	
	Color&				operator=(const CGColorRef inColor);
	
	/**
		Sets this color's individual components.
		
		@param	inRed		The red component, 0.0 to 1.0
		@param	inGreen		The green component, 0.0 to 1.0
		@param	inBlue		The blue component, 0.0 to 1.0
		@param	inAlpha		The alpha component, 0.0 to 1.0, where 0.0 is
							fully transparent, and 1.0 is fully opaque. Optional,
							defaults to 1.0.
	*/
	
	void
	set(CGFloat inRed,
		CGFloat inGreen,
		CGFloat inBlue,
		CGFloat inAlpha = 1.0f)
	{
		mRed = inRed;
		mGreen = inGreen;
		mBlue = inBlue;
		mAlpha = inAlpha;
	}
	
	/**
		Get the red color component.
	*/
	
	CGFloat					getRed()			const			{ return mRed; }
	void					setRed(CGFloat inVal)					{ mRed = inVal; }
	
	/**
		Get the green color component.
	*/
	
	CGFloat					getGreen()			const			{ return mGreen; }
	void					setGreen(CGFloat inVal)				{ mGreen = inVal; }
	
	/**
		Get the blue color component.
	*/
	
	CGFloat					getBlue()			const			{ return mBlue; }
	void					setBlue(CGFloat inVal)				{ mBlue = inVal; }
	
	CGFloat					getAlpha()			const			{ return mAlpha; }
	void					setAlpha(CGFloat inVal)				{ mAlpha = inVal; }
	
	/**
		Creates a CGColorRef.
	*/
							operator CGColorRef() const;
private:
	CGFloat		mRed;		///<	The red color component, 0.0 to 1.0.
	CGFloat		mGreen;		///<	The green color component, 0.0 to 1.0.
	CGFloat		mBlue;		///<	The blue color component, 0.0 to 1.0.
	CGFloat		mAlpha;		///<	The alpha component, 0.0 to 1.0.
	CGColorRef	mColorRef;
};








}









#endif	//	__Color_h__
