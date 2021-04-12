/**
*/

#ifndef	__GraphicsRect_h__
#define	__GraphicsRect_h__




//
//	Standard Includes
//

#include <vector>

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#endif

//
//	Project Includes
//

#include "Point.h"





namespace Graphics
{




class Point;


/**
	An axis-aligned rectangle.
*/

class
Rect : public CGRect
{
public:
	typedef	std::vector<Rect>				VectorT;
	
	
					Rect();
					Rect(const Rect& inRect);
					Rect(const CGRect& inRect);
					Rect(CGFloat inXOrigin, CGFloat inYOrigin, CGFloat inWidth, CGFloat inHeight);
					
	Rect&			zero();
	
	Rect&			setFromTo(const Point& inFrom, const Point& inTo);
	
	Rect&			operator=(const CGRect&  inRect);
	Rect&			operator=(const Rect&  inRect);
	
	Rect&			operator*=(CGFloat inScale);
	
//	void			setNull();
	
	void			inset(CGFloat inXDelta, CGFloat inYDelta);
	
					/**
						Grow the rect to include inPt.
					*/
					
	void			encompass(const Point& inPt);
	
					/**
						Grow the rect to include inRect.
					*/
					
	void			encompass(const Rect& inRect);
					
					/**
						Set the rect to exactly bound the supplied points.
					*/
					
	void			bound(const Point& inPt1, const Point& inPt2);
	
	bool			contains(const Point& inPt) const;
	
	CGFloat			minX() const							{ return origin.x; }
	CGFloat			maxX() const							{ return origin.x + size.width; }
	CGFloat			minY() const							{ return origin.y; }
	CGFloat			maxY() const							{ return origin.y + size.height; }
	
	Point			getOrigin() const;
	Point			center() const;
	
	CGFloat			width() const							{ return size.width; }
	CGFloat			height() const							{ return size.height; }
	
	CGFloat&		width()									{ return size.width; }
	CGFloat&		height()								{ return size.height; }
	
	CGFloat			midX() const							{ return ::CGRectGetMidX(*this); }
	CGFloat			midY() const							{ return ::CGRectGetMidY(*this); }
	
	Rect&			translate(const Point& inT);
	
	bool			intersects(const Rect& inRect) const;
	
//					operator CGRect() const					{ return *this; }
};





inline
Rect::Rect()
{
	origin.x = 0;
	origin.y = 0;
	size.width = 0;
	size.height = 0;
}

inline
Rect::Rect(const Rect& inRect)
{
	origin.x = inRect.origin.x;
	origin.y = inRect.origin.y;
	size.width = inRect.size.width;
	size.height = inRect.size.height;
}

inline
Rect::Rect(const CGRect& inRect)
{
	origin.x = inRect.origin.x;
	origin.y = inRect.origin.y;
	size.width = inRect.size.width;
	size.height = inRect.size.height;
}

inline
Rect::Rect(CGFloat inXOrigin, CGFloat inYOrigin, CGFloat inWidth, CGFloat inHeight)
{
	origin.x = inXOrigin;
	origin.y = inYOrigin;
	size.width = inWidth;
	size.height = inHeight;
}

inline
Rect&
Rect::zero()
{
	origin.x = 0.0f;
	origin.y = 0.0f;
	size.width = 0.0f;
	size.height = 0.0f;
	
	return *this;
}

inline
Rect&
Rect::operator=(const CGRect& inRect)
{
	origin.x = inRect.origin.x;
	origin.y = inRect.origin.y;
	size.width = inRect.size.width;
	size.height = inRect.size.height;
	
	return *this;
}

inline
Rect&
Rect::operator=(const Rect& inRect)
{
	origin.x = inRect.origin.x;
	origin.y = inRect.origin.y;
	size.width = inRect.size.width;
	size.height = inRect.size.height;
	
	return *this;
}

inline
void
Rect::inset(CGFloat inXDelta, CGFloat inYDelta)
{
	origin.x += inXDelta;
	origin.y += inYDelta;
	size.width -= 2.0f * inXDelta;
	size.height -= 2.0f * inYDelta;
}

inline
Rect&
Rect::translate(const Point& inT)
{
	origin.x += inT.x;
	origin.y += inT.y;
	
	return *this;
}

inline
bool
Rect::intersects(const Rect& inRect) const
{
	return ::CGRectIntersectsRect(*this, inRect);
}

inline
Point
Rect::center() const
{
	CGFloat x = midX();
	CGFloat y = midY();
	Point p(x, y);
	return p;
}

}	//	namespace Graphics



#endif	//	__GraphicsRect_h__
