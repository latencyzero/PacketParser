/*
	File:		Vector.h
	Author:		Roderick L. Mann
	Date:		February 19, 1994
 
		This file implements 3-D vectors(also
	used to represent points) and 4-space homogeneous
	transformations(struct CXform).
 
		For the sake of simplicity, the classes are being
	implemented in the most straightforward form. It may
	prove to be more efficient if certain values are
	precomputed(such as the length of a vector), and
	stored in an instance variable. This will have to
	be examined with data from profiling.
	
	Vectors are row vectors. Transformations should be premultiplied.
	
	Note that the “Make” routines assume they are being called on an
	identity matrix.
	
	960710	Changed some routines to use memset() and memcpy().
	950306	Changed Make routines to assume they were given a zero matrix.
			Changed some routines to use ::BlockMoveData under MacOS.
*/
 

#include <cstring>


template<typename T> class CXform;

//
//	Constants
//


//
//  Miscellaneous Routines
//

#ifndef	M_PI
#define	M_PI	3.141592654
#endif

inline double Rad(const double deg) { return deg *(M_PI / 180.0); }

//
//  struct Vector
//

#if defined(powerc) || defined(__powerc)
#pragma options align=power
#endif

template<typename T>
class Vector
{
public:
	T			x, y, z;
	
				Vector(void)											{ x = 0.0; y = 0.0; z = 0.0; }
				Vector(const T initX, const T initY, const T initZ)		{ x = initX; y = initY; z = initZ; }
				Vector(const Vector& initV)								{ x = initV.x; y = initV.y; z = initV.z; }

	Vector		operator+(const Vector& v) const						{ return Vector(x + v.x, y + v.y, z + v.z); }
	Vector		operator+(const T d) const								{ return Vector(x + d, y + d, z + d); }
	Vector		operator-(void) const									{ return Vector(-x, -y, -z); }
	Vector		operator-(const Vector& v) const						{ return Vector(x - v.x, y - v.y, z - v.z); }
	Vector		operator-(const T d) const								{ return Vector(x - d, y - d, z - d); }

	Vector		operator*(const T d) const								{ return Vector(x * d, y * d, z * d); }
	
	template<typename U>
	friend
	Vector<U>	operator*(const U d, const Vector<U>& v);
	
	Vector&		operator*=(const CXform<T>& m);
	
	Vector		operator*(const CXform<T>& m) const;
	Vector		operator*(const Vector& m) const						{ return Vector(y * m.z - z * m.y, z * m.x - x * m.z, x * m.y - y * m.x); }

	Vector		operator/(const T d) const								{ T r = 1.0 / d; return Vector(x * r, y * r, z * r); }

	Vector&		operator=(const Vector& v)								{ x = v.x; y = v.y; z = v.z; return *this; }

	Vector&		operator+=(const Vector& v)								{ x += v.x; y += v.y; z += v.z; return *this; }
	Vector&		operator-=(const Vector& v)								{ x -= v.x; y -= v.y; z -= v.z; return *this; }
	Vector&		operator*=(const T d)									{ x *= d; y *= d; z *= d; return *this; }
	Vector&		operator*=(const Vector& m);
	Vector		operator/=(const T d)									{ T r = 1 / d; x *= r; y *= r; z *= r; return *this; }

	void		multIncr(const Vector& v, const T d)					{ x += v.x * d; y += v.y * d; z += v.z * d; }
	
	Vector&		operator()(const T ix, const T iy, const T iz = 0)		{ set(ix, iy, iz); return *this; }
	
	int			operator==(const Vector& v) const						{ if(x == v.x && y == v.y && z == v.z) return 1; else return 0; }
	int			operator!=(const Vector& m) const						{ if(x != m.x || y != m.y || z != m.z) return 1; else return 0; }
	
	Vector&		normalize(const T len = 1.0);
	Vector&		normalize(const Vector& v);
	
	T			magnitude(void) const									{ return sqrt(x * x + y * y + z * z); }
	T			magnitudeSqr(void) const								{ return x * x + y * y + z * z; }
	T			dot(const Vector& v) const								{ return x * v.x + y * v.y + z * v.z; }

	void		set(const T ix, const T iy, const T iz = 0)				{ x = ix; y = iy; z = iz; }
	void		setX(const T ix)										{ x = ix; }
	void		setY(const T iy)										{ y = iy; }
	void		setZ(const T iz)										{ z = iz; }
	
	void		zero(void)												{ x = 0; y = 0; z = 0; }
	
	#if	qUseStdIO
	void		Read(FILE *theFile);
	void		Print(FILE *theFile);
	#endif
};

///////////////////
//
//	class CXform
//
///////////////////

template<typename T>
class CXform
{
protected:
	T		fElement[4][4];				//	[row][col]
	bool			fIsIdentity;
	
public:
	CXform(void);
	CXform(const CXform& m);

	T&		Element(const short row, const short col)
					{ fIsIdentity = false; return fElement[row][col]; }

	void		MakeIdentity(void);
	void		SetIdentity(const bool inIdent) { fIsIdentity = inIdent; }
	void		MakeTranslate(const T dx, const T dy, const T dz);
	void		MakeTranslate(const Vector<T>& deltaPos);
	void		MakeScale(const T sx, const T sy, const T sz);
	void		MakeRotX(const T rad);
	void		MakeRotY(const T rad);
	void		MakeRotZ(const T rad);
	void		MakeRot(const T theta, const T phi, const T rho);
	void		MakeRotCol(const Vector<T>& rX, const Vector<T>& rY, const Vector<T>& rZ);
	void		MakeRotRow(const Vector<T>& rX, const Vector<T>& rY, const Vector<T>& rZ);
	void		MakeProj(const T d);
	void		MakeShear(const T shx, const T shy);
	CXform<T>&	operator=(const CXform& m);

	CXform<T>		operator*(const CXform<T>& m) const;
	CXform<T>&		operator*=(const CXform<T>& m);
	CXform			operator*(const Vector<T>& v) const;
	Vector<T>		operator()(const Vector<T>& v) const;
	const CXform&	MakeInverse(void) const;
	
	void			Zero(void)
					{
						std::memset(fElement, 0, sizeof(fElement));
						fIsIdentity = false;
					 }
	
	#if	qUseStdIO
	void			Print(FILE *theFile);
	#endif

	friend class Vector<T>;
};

template<typename T>
inline
Vector<T>&
Vector<T>::normalize(const T len)
{
	T d = magnitude();
	#if qSlowAndSafe
	if(d == 0.0)
		return;
	#endif
	T r = len / d;
	x *= r;
	y *= r;
	z *= r;
	
	return *this;
}


template<typename T>
inline
Vector<T>&
Vector<T>::normalize(const Vector<T>& v)
{
	T len = v.Magnitude();
	return Normalize(len);
}

template<typename T>
inline
Vector<T>&
Vector<T>::operator*=(const CXform<T>& m)
{
	T sumX = m.fElement[0][0] * x;
	T sumY = m.fElement[0][1] * x;
	T sumZ = m.fElement[0][2] * x;
	
	sumX += m.fElement[1][0] * y;
	sumY += m.fElement[1][1] * y;
	sumZ += m.fElement[1][2] * y;
	
	sumX += m.fElement[2][0] * z;
	sumY += m.fElement[2][1] * z;
	sumZ += m.fElement[2][2] * z;
	
	sumX += m.fElement[3][0];		//	* W, but w is always 1.
	sumY += m.fElement[3][1];		//	* W, but w is always 1.
	sumZ += m.fElement[3][2];		//	* W, but w is always 1.
	
	x = sumX;
	y = sumY;
	z = sumZ;
	
	return *this;
}

template<typename T>
inline
Vector<T>
operator*(const T d, const Vector<T>& v)
{
	return Vector<T>(d * v.x, d * v.y, d * v.z);
}

//
//
//	class CXform inline functions
//
//

template<typename T>
inline
CXform<T>&
CXform<T>::operator=(const CXform<T>& m)
{
	fIsIdentity = m.fIsIdentity;
#if	qUseBlockMove
	::BlockMoveData(m.fElement, fElement, sizeof(fElement));
#else
	for(register short i = 0; i < 4; i++)
		for(register short j = 0; j < 4; j++)
			fElement[i][j] = m.fElement[i][j];
#endif
	return *this;
}

template<typename T>
inline
CXform<T>&
CXform<T>::operator*=(const CXform<T>& m)
{
	*this = *this * m;
	return *this;
}

template<typename T>
inline
CXform<T>::CXform(const CXform<T>& m)
{
	*this = m;
}

template<typename T>
inline
void
CXform<T>::MakeTranslate(const T dx, const T dy, const T dz)
{
	fElement[3][0] = dx;
	fElement[3][1] = dy;
	fElement[3][2] = dz;
	
	fElement[0][0] = 1.0;
	fElement[1][1] = 1.0;
	fElement[2][2] = 1.0;
	fElement[3][3] = 1.0;
}

template<typename T>
inline
void
CXform<T>::MakeTranslate(const Vector<T>& deltaPos)
{
	MakeTranslate(deltaPos.x, deltaPos.y, deltaPos.z);
}

template<typename T>
inline
void
CXform<T>::MakeScale(const T sx, const T sy, const T sz)
{
	Element(0, 0) = sx;
	Element(1, 1) = sy;
	Element(2, 2) = sz;
	Element(3, 3) = 1.0;
}

template<typename T>
inline
void
CXform<T>::MakeRotX(const T rad)
{
	T c = cos(rad);
	T s = sin(rad);

	Element(0, 0) = 1.0;
	Element(1, 1) = c;		Element(1, 2) = s;
	Element(2, 1) = -s;	Element(2, 2) = c;
	Element(3, 3) = 1.0;
}

template<typename T>
inline
void
CXform<T>::MakeRotY(const T rad)
{
	T c = cos(rad);
	T s = sin(rad);

	Element(0, 0) = c;		Element(0, 2) = s;
	Element(1, 1) = 1.0;
	Element(2, 0) = -s;	Element(2, 2) = c;
	Element(3, 3) = 1.0;
}

template<typename T>
inline
void
CXform<T>::MakeRotZ(const T rad)
{
	T c = cos(rad);
	T s = sin(rad);

	Element(0, 0) = c;		Element(0, 1) = s;
	Element(1, 0) = -s;	Element(1, 1) = c;
	Element(2, 2) = 1.0;
	Element(3, 3) = 1.0;
}

template<typename T>
inline
void
CXform<T>::MakeRot(const T theta, const T phi, const T rho)
{
	CXform<T> rotX;
	rotX.MakeRotX(theta);

	CXform<T> rotY;
	rotY.MakeRotY(phi);
	
	CXform<T> rotZ;
	rotZ.MakeRotZ(rho);
	
	*this = rotX * rotY * rotZ;
}

template<typename T>
inline
void
CXform<T>::MakeProj(const T d)
{
	Element(2, 2) = 0.0;
	Element(2, 3) = 1.0 / d;
}

template<typename T>
inline
void
CXform<T>::MakeShear(const T shx, const T shy)
{
	Element(2, 0) = shx;
	Element(2, 1) = shy;
}

template<typename T>
inline
Vector<T>
CXform<T>::operator()(const Vector<T>& v) const
{
	return v * *this;
}

#ifdef	Debug_Profile
#pragma profile reset
#endif

#if defined(powerc) || defined(__powerc)
#pragma options align=power
#endif
