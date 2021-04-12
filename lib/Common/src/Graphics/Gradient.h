/*
 *  Gradient.h
 *  MissionClock
 *
 *  Created by Roderick Mann on 6/10/09.
 *  Copyright 2009 Latency: Zero. All rights reserved.
 *
 */

#ifndef	__Graphics_Gradient_h__
#define __Graphics_Gradient_h__

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#else
#include <ApplicationServices/ApplicationServices.h>
#endif



namespace Graphics
{

class Color;
class Context;


class
Gradient
{
public:
	Gradient()
		:
		mGradientRef(NULL)
	{
	}
	
	Gradient(const Color& inColor1, const Color& inColor2);
	Gradient(CGFloat inRed1, CGFloat inGreen1, CGFloat inBlue1,
				CGFloat inRed2, CGFloat inGreen2, CGFloat inBlue2,
				CGFloat inAlpha1 = 1.0f, CGFloat inAlpha2 = 1.0f);
	
	/**
		inNumStops must be at least 2.
		
		For each stop, pass a CGColorRef and a CGFloat.
	*/
	
	Gradient(uint32_t inNumStops, ...);
	
	virtual		~Gradient();
	
	void		set(uint32_t inNumStops, ...);
	
	void		drawLinear(Context& inCTX, CGFloat inX1, CGFloat inY1, CGFloat inX2, CGFloat inY2) const;
	
				operator CGGradientRef() const			{ return mGradientRef; }
				
private:
	CGGradientRef			mGradientRef;
};



}	//	namespace Graphics


#endif	//	__Graphics_Gradient_h__
