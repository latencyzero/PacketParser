/*
 *  Gradient.cpp
 *  MissionClock
 *
 *  Created by Roderick Mann on 6/10/09.
 *  Copyright 2009 Latency: Zero. All rights reserved.
 *
 */

#include "Gradient.h"



//
//	Mac OS Includes
//


//
//	Project Includes
//

#include "Color.h"
#include "Context.h"



namespace Graphics
{

Gradient::Gradient(const Color& inColor1, const Color& inColor2)
{
	CGColorSpaceRef colorSpace = ::CGColorSpaceCreateDeviceRGB();
	CGFloat		components[] = { inColor1.getRed(), inColor1.getGreen(), inColor1.getBlue(), inColor1.getAlpha(),
								inColor2.getRed(), inColor2.getGreen(), inColor2.getBlue(), inColor2.getAlpha() };
	mGradientRef = ::CGGradientCreateWithColorComponents(colorSpace,
															components,
															NULL,
															2);
    ::CFRelease(colorSpace);
}

Gradient::Gradient(CGFloat inRed1, CGFloat inGreen1, CGFloat inBlue1,
					CGFloat inRed2, CGFloat inGreen2, CGFloat inBlue2,
					CGFloat inAlpha1, CGFloat inAlpha2)
{
	CGColorSpaceRef colorSpace = ::CGColorSpaceCreateDeviceRGB();
	CGFloat		components[] = { inRed1, inGreen1, inBlue1, inAlpha1,
								inRed2, inGreen2, inBlue2, inAlpha2 };
	mGradientRef = ::CGGradientCreateWithColorComponents(colorSpace,
															components,
															NULL,
															2);
    ::CFRelease(colorSpace);
}

Gradient::Gradient(uint32_t inNumStops, ...)
{
	if (inNumStops < 2)
	{
		return;				//	TODO: throw exception
	}
	
	//	Allocate the color and location arrays…
	
	va_list		arg;
	va_start(arg, inNumStops);
	
	CGColorRef* colorArray = (CGColorRef*) malloc(inNumStops * sizeof(CGColorRef));
	if (colorArray == NULL)
	{
		return;				//	TODO: throw exception
	}
	
	CGFloat* locations = (CGFloat*) malloc(inNumStops * sizeof(CGFloat));
	if (locations == NULL)
	{
		free(colorArray);
		return;				//	TODO: throw exception
	}
	
	uint32_t numStops = 0;
	for (uint32_t i = 0; i < inNumStops; i++)
	{
		CGColorRef c = va_arg(arg, CGColorRef);
		double l = va_arg(arg, double);
		
		if (c != nil)		//	Ignore any null stops
		{
			colorArray[numStops] = c;
			locations[numStops] = l;
			numStops += 1;
		}
	}
	
    //  Create the array of colors…
    
    CFArrayRef colors = CFArrayCreate(kCFAllocatorDefault,
                                        (const void**) colorArray,
                                        numStops,
                                        &kCFTypeArrayCallBacks);
	free(colorArray);
	
	if (colors == NULL)
	{
		free(locations);
		return;				//	TODO: throw exception
	}
	
    //  Create the gradient…
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        colors,
                                                        locations);
    CFRelease(colorSpace);
    CFRelease(colors);
	free(locations);
	
	va_end(arg);
	
	mGradientRef = gradient;
}

Gradient::~Gradient()
{
	::CFRelease(mGradientRef);
}

void
Gradient::set(uint32_t inNumStops, ...)
{
	if (inNumStops < 2)
	{
		return;				//	TODO: throw exception
	}
	
	if (mGradientRef != nil)
	{
		::CFRelease(mGradientRef);
	}
	
	//	Allocate the color and location arrays…
	
	va_list		arg;
	va_start(arg, inNumStops);
	
	CGColorRef* colorArray = (CGColorRef*) malloc(inNumStops * sizeof(CGColorRef));
	if (colorArray == NULL)
	{
		return;				//	TODO: throw exception
	}
	
	CGFloat* locations = (CGFloat*) malloc(inNumStops * sizeof(CGFloat));
	if (locations == NULL)
	{
		free(colorArray);
		return;				//	TODO: throw exception
	}
	
	uint32_t numStops = 0;
	for (uint32_t i = 0; i < inNumStops; i++)
	{
		CGColorRef c = va_arg(arg, CGColorRef);
		double l = va_arg(arg, double);
		
		if (c != nil)		//	Ignore any null stops
		{
			colorArray[numStops] = c;
			locations[numStops] = l;
			numStops += 1;
		}
	}
	
    //  Create the array of colors…
    
    CFArrayRef colors = CFArrayCreate(kCFAllocatorDefault,
                                        (const void**) colorArray,
                                        numStops,
                                        &kCFTypeArrayCallBacks);
	free(colorArray);
	
	if (colors == NULL)
	{
		free(locations);
		return;				//	TODO: throw exception
	}
	
    //  Create the gradient…
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,
                                                        colors,
                                                        locations);
    CFRelease(colorSpace);
    CFRelease(colors);
	free(locations);
	
	va_end(arg);
	
	mGradientRef = gradient;
}


void
Gradient::drawLinear(Context& inCTX, CGFloat inX1, CGFloat inY1, CGFloat inX2, CGFloat inY2) const
{
	CGPoint	startPt = { inX1, inY1 };
	CGPoint	endPt = { inX2, inY2 };
	::CGContextDrawLinearGradient(inCTX, mGradientRef, startPt, endPt, 0);
}


}	//	namespace Graphics
