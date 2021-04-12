/**
*/

#ifndef	__Point_h__
#define	__Point_h__



//
//	Standard Includes
//

#include <vector>


//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#else
#include <ApplicationServices/ApplicationServices.h>
#endif

//#include <CoreServices/CoreServices.h>
//#include <CarbonCore/MacTypes.h>






namespace Graphics
{

/**
	Point is a C++ wrapper around CGPoint. Because it inherits from CGPoint
	and introduces no new members, you can safely cast from CGPoint to Point.
*/

class
Point : public CGPoint
{
public:
	typedef	std::vector<Point>				VectorT;
	
	
					Point();
					//Point(const Point& inPt);
					Point(const CGPoint& inPt);
					Point(CGFloat inX, CGFloat inY);
					
	void			set(CGFloat inX, CGFloat inY);
	
	bool			operator==(const Point& inRHS) const;
	Point&			operator=(const Point&  inPt);
	//CGFloat&			operator[](uint32_t inIndex)			{ return mCoord[inIndex]; }
	
	Point			operator*(CGFloat inScale) const;
	Point&			operator*=(CGFloat inScale);
	
	CGFloat			getX() const							{ return x; }
	CGFloat			getY() const							{ return y; }
	
#if 0
	Point			operator+(const Point& inPt) const;
	Point			operator-(const CGPoint& inPt) const;
#endif

	Point			operator-() const;
	
	Point&			operator+=(const Point& inPt);
	Point&			operator-=(const CGPoint& inPt);
	
	Point			add(CGFloat inX, CGFloat inY) const;
	
	CGFloat			magnitudeSqr() const;
	
	/**
		Return the squared distance from this point to the specified inPt.
	*/
	
	CGFloat			distanceSquared(const Point& inPt) const;
	
#if	__OBJC__
	NSString*		toString() const;
#endif
};








inline
Point::Point()
{
	x = 0.0;
	y = 0.0;
}

/*
inline
Point::Point(const Point& inPt)
{
	*this = inPt;
}
*/

inline
Point::Point(const CGPoint& inPt)
{
	set(inPt.x, inPt.y);
}

inline
Point::Point(CGFloat inX, CGFloat inY)
{
	set(inX, inY);
}

inline
void
Point::set(CGFloat inX, CGFloat inY)
{
	x = inX;
	y = inY;
}

inline
bool
Point::operator==(const Point& inRHS) const
{
	//	TODO: Need to check within specified tolerance, not straight equality.
	//			Problem is, how to define tol range?
	return x == inRHS.x && y == inRHS.y;
}

inline
Point&
Point::operator=(const Point&  inPt)
{
	x = inPt.x;
	y = inPt.y;
	
	return *this;
}

#if 0
inline
Point
Point::operator+(const Point& inPt) const
{
	return Point(getX() + inPt.getX(), getY() + inPt.getY());
}

inline
Point
Point::operator-(const CGPoint& inPt) const
{
	return Point(getX() - inPt.x, getY() - inPt.y);
}
#endif

inline
Point
Point::operator-() const
{
	Point p(-x, -y);
	return p;
}

inline
Point&
Point::operator+=(const Point& inPt)
{
	x += inPt.x;
	y += inPt.y;
	
	return *this;
}

inline
Point&
Point::operator-=(const CGPoint& inPt)
{
	x -= inPt.x;
	y -= inPt.y;
	
	return *this;
}

inline
Point
Point::add(CGFloat inX, CGFloat inY) const
{
	return Point(x + inX, y + inY);
}

inline
Point
Point::operator*(CGFloat inScale) const
{
	return Point(getX() * inScale, getY() * inScale);
}

inline
Point&
Point::operator*=(CGFloat inScale)
{
	x *= inScale;
	y *= inScale;
	
	return *this;
}

inline
CGFloat
Point::magnitudeSqr() const
{
	return x * x + y * y;
}


inline
CGFloat
Point::distanceSquared(const Point& inPt) const
{
	CGFloat	dX = inPt.x - x;
	CGFloat	dY = inPt.y - y;
	return dX * dX + dY * dY; 
}





}	//	namespace Graphics


//
//	Global Operator Methods
//

inline
Graphics::Point
operator+(const CGPoint& inPt1, const Graphics::Point& inPt2)
{
	return Graphics::Point(inPt1.x + inPt2.x, inPt1.y + inPt2.y);
}

inline
Graphics::Point
operator-(const CGPoint& inPt1, const Graphics::Point& inPt2)
{
	return Graphics::Point(inPt1.x - inPt2.x, inPt1.y - inPt2.y);
}

inline
CGPoint
operator+(const CGPoint& inPt1, const CGPoint& inPt2)
{
	CGPoint pt = { inPt1.x + inPt2.x, inPt1.y + inPt2.y };
	
	return pt;
}

inline
CGPoint
operator-(const CGPoint& inPt1, const CGPoint& inPt2)
{
	CGPoint pt = { inPt1.x - inPt2.x, inPt1.y - inPt2.y };
	
	return pt;
}

#endif	//	__Point_h__

