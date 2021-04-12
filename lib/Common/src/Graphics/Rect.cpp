#include "Rect.h"

//
//	Standard Includes
//

#include <cmath>
//#include <CGFloat.h>



//
//	Project Includes
//

#include "Point.h"




namespace Graphics
{


Rect&
Rect::operator*=(CGFloat inScale)
{
	origin.x *= inScale;
	origin.y *= inScale;
	size.width *= inScale;
	size.height *= inScale;
	
	return *this;
}

Rect&
Rect::setFromTo(const Point& inFrom, const Point& inTo)
{
	origin.x = ::fminf(inFrom.x, inTo.x);
	origin.y = ::fminf(inFrom.y, inTo.y);
	size.width = ::fabsf(inTo.x - inFrom.x);
	size.height = ::fabsf(inTo.y - inFrom.y);
	
	return *this;
}

/*
void
Rect::setNull()
{
	size. = FLT_MAX;
	mXMax = FLT_MIN;
	mYMin = FLT_MAX;
	mYMax = FLT_MIN;
}
*/

void
Rect::encompass(const Point& inPt)
{
	Rect r = ::CGRectMake(inPt.x, inPt.y, 0.0f, 0.0f);
	Rect newR = ::CGRectUnion(*this, r);
	*this = newR;
}

void
Rect::encompass(const Rect& inRect)
{
	CGRect r = ::CGRectUnion(*this, inRect);
	*this = r;
}

void
Rect::bound(const Point& inPt1, const Point& inPt2)
{
	Graphics::Rect b;
	
	b.origin.x = std::min(inPt1.x, inPt2.x);
	CGFloat max = std::max(inPt1.x, inPt2.x);
	b.size.width = max - b.origin.x;
	
	b.origin.y = std::min(inPt1.y, inPt2.y);
	max = std::max(inPt1.y, inPt2.y);
	b.size.height = max - b.origin.y;
	
	*this = b;
}





bool
Rect::contains(const Point& inPt) const
{
	return ::CGRectContainsPoint(*this, inPt);
}

Point
Rect::getOrigin() const
{
	return origin;
}



}	//	namespace Graphics
