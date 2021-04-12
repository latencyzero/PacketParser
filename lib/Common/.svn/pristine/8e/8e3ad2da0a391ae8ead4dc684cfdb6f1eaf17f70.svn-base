/*
 *  Point3D.h
 *  OtiruTouch
 *
 *  Created by Roderick Mann on 10/27/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#ifndef	__Point3D_h__
#define __Point3D_h__

#import <CoreGraphics/CoreGraphics.h>


class
Point3D
{
public:
					Point3D()
					{
						x = 1.0f;
						y = 1.0f;
						z = 1.0f;
					}
					
					Point3D(CGFloat inX, CGFloat inY, CGFloat inZ)
					{
						x = inX;
						y = inY;
						z = inZ;
					}

	Point3D			operator*(const CGFloat inScale) const
					{
						Point3D		result(x * inScale, y * inScale, z * inScale);
						return result;
					}
					
	Point3D&		operator+=(const Point3D& inRHS)
					{
						x += inRHS.x;
						y += inRHS.y;
						z += inRHS.z;
						return *this;
					}
					
public:
	CGFloat			x;
	CGFloat			y;
	CGFloat			z;
	

};




#endif	//	__Point3D_h__
