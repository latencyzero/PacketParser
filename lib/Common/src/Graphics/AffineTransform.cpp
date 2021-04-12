#include "AffineTransform.h"


//
//	Standard Includes
//

#include <cmath>

//
//	Mac OS Includes
//



namespace Graphics
{

AffineTransform	AffineTransform::sZero(0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
AffineTransform	AffineTransform::sIdentity(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);





//	Make functions make this matrix into
//	the specified matrix.

void
AffineTransform::makeZero()
{
	a = 0.0;
	b = 0.0;
	c = 0.0;
	d = 0.0;
	tx = 0.0;
	ty = 0.0;
}


void
AffineTransform::makeIdentity()
{
	a = 1.0;
	b = 0.0;
	c = 0.0;
	d = 1.0;
	tx = 0.0;
	ty = 0.0;
}


void
AffineTransform::makeTranslation(CGFloat inTX, CGFloat inTY)
{
	a = 1.0;
	b = 0.0;
	c = 0.0;
	d = 1.0;
	tx = inTX;
	ty = inTY;
}


void
AffineTransform::makeScale(CGFloat inSX, CGFloat inSY)
{
	a = inSX;
	b = 0.0;
	c = 0.0;
	d = inSY;
	tx = 0.0;
	ty = 0.0;
}


void
AffineTransform::makeRotation(CGFloat inAngle)
{
	CGFloat	sinVal = std::sin(inAngle);
	CGFloat	cosVal = std::cos(inAngle);
	
	a = cosVal;
	b = sinVal;
	c = -sinVal;
	d = cosVal;
	tx = 0.0;
	ty = 0.0;
}



//	These functions apply a matrix of the
//	specified type to this matrix.


void
AffineTransform::invert()
{
	CGFloat	pA = d;
	CGFloat	pB = -c;
	CGFloat	pC = c * ty - d * tx;
	
	CGFloat	pD = -b;
	CGFloat	pE = a;
	CGFloat	pF = -(a * ty - b * tx);
	
	//CGFloat	G = 0.0;
	//CGFloat	H = 0.0;
	//CGFloat	I = a * d - b * c;
	
	CGFloat	s = 1.0 / (a * pA + b * pB + c * pC);
	
	a = pA * s;
	b = pD * s;
	c = pB * s;
	d = pE * s;
	tx = pC * s;
	ty = pF * s;
}

void
AffineTransform::getInverse(AffineTransform& outTxfm) const
{
	CGFloat	pA = d;
	CGFloat	pB = -c;
	CGFloat	pC = c * ty - d * tx;
	
	CGFloat	pD = -b;
	CGFloat	pE = a;
	CGFloat	pF = -(a * ty - b * tx);
	
	//CGFloat	G = 0.0;
	//CGFloat	H = 0.0;
	//CGFloat	I = a * d - b * c;
	
	CGFloat	s = 1.0 / (a * pA + b * pB + c * pC);
	
	outTxfm.a = pA * s;
	outTxfm.b = pD * s;
	outTxfm.c = pB * s;
	outTxfm.d = pE * s;
	outTxfm.tx = pC * s;
	outTxfm.ty = pF * s;
}


AffineTransform
AffineTransform::operator*(const AffineTransform& inT2) const
{
	AffineTransform	temp = *this;
	
#if	1	//	Set to 0 to reverse the order of the multiply…

	temp.a = inT2.a * a + inT2.b * c;
	temp.b = inT2.a * b + inT2.b * d;
	temp.c = inT2.c * a + inT2.d * c;
	temp.d = inT2.c * b + inT2.d * d;
	temp.tx = inT2.tx * a + inT2.ty * c + tx;
	temp.ty = inT2.tx * b + inT2.ty * d + ty;

#else

	temp.a = a * inT2.a + b * inT2.c;
	temp.b = a * inT2.b + b * inT2.d;
	temp.c = c * inT2.a + d * inT2.c;
	temp.d = c * inT2.b + d * inT2.d;
	temp.tx = tx * inT2.a + ty * inT2.c + inT2.tx;
	temp.ty = tx * inT2.b + ty * inT2.d + inT2.ty;

#endif
	
	return temp;
}

AffineTransform&
AffineTransform::operator*=(CGFloat inS)
{
	a *= inS;
	b *= inS;
	c *= inS;
	d *= inS;
	tx *= inS;
	ty *= inS;
	
	return *this;
}

AffineTransform&
AffineTransform::operator*=(const AffineTransform& inT2)
{
	*this = *this * inT2;
	return *this;
}


#include <cstdio>

void
AffineTransform::print() const
{
	std::printf("+--                         --+\n");
	std::printf("|  %7.3f  %7.3f  %7.3f  |\n", a, b, 0.0);
	std::printf("|  %7.3f  %7.3f  %7.3f  |\n", c, d, 0.0);
	std::printf("|  %7.3f  %7.3f  %7.3f  |\n", tx, ty, 1.0);
	std::printf("+--                         --+\n");
}



}	//	namespace Graphics

