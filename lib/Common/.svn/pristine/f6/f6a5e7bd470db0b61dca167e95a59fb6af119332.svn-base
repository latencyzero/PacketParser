/**
*/

#ifndef	__AffineTransform_h__
#define __AffineTransform_h__



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

class
AffineTransform : public CGAffineTransform
{
public:
								AffineTransform();
								AffineTransform(const AffineTransform& inMatrix);
								AffineTransform(const CGAffineTransform& inMatrix);
								AffineTransform(CGFloat inA, CGFloat inB,
													CGFloat inC, CGFloat inD,
													CGFloat inTX, CGFloat inTY);
							
	AffineTransform&			operator=(const AffineTransform& inMatrix);
	
								//	Make functions make this matrix into
								//	the specified matrix.
							
	void						makeZero();
	void						makeIdentity();
	void						makeTranslation(CGFloat inTX, CGFloat inTY);
	void						makeScale(CGFloat inSX, CGFloat inSY);
	void						makeRotation(CGFloat inAngle);
							
								//	These functions apply a matrix of the
								//	specified type to this matrix.
							
	void						translate(CGFloat inTX, CGFloat inTY);
	void						scale(CGFloat inSX, CGFloat inSY);
	void						rotate(CGFloat inAngle);
	void						invert();
	void						getInverse(AffineTransform& outTxfm) const;
	
	AffineTransform				operator*(const AffineTransform& inT2) const;
	AffineTransform&			operator*=(CGFloat inS);
	AffineTransform&			operator*=(const AffineTransform& inT2);
	
	void						transform(Point& ioPoint) const;
	void						transform(CGPoint& ioPoint) const;
	void						transform(CGSize& ioSize) const;
	void						transform(CGFloat& ioX, CGFloat& ioY) const;
	void						transform(CGRect& ioRect) const;
	
	void						print() const;
	
	static	AffineTransform&	zero() { return sZero; }
	static	AffineTransform&	identity() { return sIdentity; }
	
private:
	static	AffineTransform	sZero;
	static	AffineTransform	sIdentity;
};




inline
AffineTransform::AffineTransform()
{
	makeIdentity();
}

inline
AffineTransform::AffineTransform(const AffineTransform& inMatrix)
{
	a = inMatrix.a;
	b = inMatrix.b;
	c = inMatrix.c;
	d = inMatrix.d;
	tx = inMatrix.tx;
	ty = inMatrix.ty;
}

inline
AffineTransform::AffineTransform(const CGAffineTransform& inMatrix)
{
	a = inMatrix.a;
	b = inMatrix.b;
	c = inMatrix.c;
	d = inMatrix.d;
	tx = inMatrix.tx;
	ty = inMatrix.ty;
}

inline
AffineTransform::AffineTransform(CGFloat inA, CGFloat inB, CGFloat inC, CGFloat inD, CGFloat inTX, CGFloat inTY)
{
	a = inA;
	b = inB;
	c = inC;
	d = inD;
	tx = inTX;
	ty = inTY;
}

inline
AffineTransform&
AffineTransform::operator=(const AffineTransform& inMatrix)
{
	a = inMatrix.a;
	b = inMatrix.b;
	c = inMatrix.c;
	d = inMatrix.d;
	tx = inMatrix.tx;
	ty = inMatrix.ty;
	
	return *this;
}


inline
void
AffineTransform::translate(CGFloat inTX, CGFloat inTY)
{
	AffineTransform	temp;
	temp.makeTranslation(inTX, inTY);
	
	*this *= temp;
}

inline
void
AffineTransform::scale(CGFloat inSX, CGFloat inSY)
{
	AffineTransform	temp;
	temp.makeScale(inSX, inSY);
	
	*this *= temp;
}

inline
void
AffineTransform::rotate(CGFloat inAngle)
{
	AffineTransform	temp;
	temp.makeRotation(inAngle);
	
	*this *= temp;
}



inline
void
AffineTransform::transform(Point& ioPoint) const
{
	Point		p;
	p.x = a * ioPoint.x + c * ioPoint.y + tx;
	p.y = b * ioPoint.x + d * ioPoint.y + ty;
	
	ioPoint = p;
}

inline
void
AffineTransform::transform(CGPoint& ioPoint) const
{
	CGPoint		p;
	p.x = a * ioPoint.x + c * ioPoint.y + tx;
	p.y = b * ioPoint.x + d * ioPoint.y + ty;
	
	ioPoint = p;
}

inline
void
AffineTransform::transform(CGFloat& ioX, CGFloat& ioY) const
{
	CGFloat x = a * ioX + c * ioY + tx;
	CGFloat y = b * ioX + d * ioY + ty;
	
	ioX = x;
	ioY = y;
}

inline
void
AffineTransform::transform(CGSize& ioSize) const
{
	CGSize		s;
	s.width = a * ioSize.width + c * ioSize.height;
	s.height = b * ioSize.width + d * ioSize.height;
	
	ioSize = s;
}

inline
void
AffineTransform::transform(CGRect& ioRect) const
{
	transform(ioRect.origin);
}


}	//	namespace Graphics



#endif	//	__AffineTransform_h__
