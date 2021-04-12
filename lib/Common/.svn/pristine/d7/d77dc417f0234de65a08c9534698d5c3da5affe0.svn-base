#include		"Vector.h"
#include <stdint.h>
#include <cstring>

#if	qUseStdIO
#include		<stdio.h>
#endif

template<typename T>
Vector<T>
Vector<T>::operator* (const CXform<T>& m) const
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
	
	return Vector (sumX, sumY, sumZ);
}

#if	qUseStdIO

void Vector::Read (FILE *theFile)
{
	fscanf (theFile, "%Lf", &x);
	fscanf (theFile, "%Lf", &y);
	fscanf (theFile, "%Lf", &z);
}

void Vector::Print (FILE *theFile)
{
	fprintf (theFile, "<% 5.2Lg, % 5.2Lg, % 5.2Lg>", x, y, z);
}

void CXform::Print (FILE *theFile)
{
	for (register i = 0; i < 4; i++)
	{
		for (register j = 0; j < 4; j++)
			fprintf (theFile, "%10.3g ", fElement[j][i]);
		fprintf (theFile, "\n");
	}
	fprintf (theFile, "\n\n");
}

#endif	//  qUseStdIO

template<typename T>
CXform<T>::CXform(void)
{
	Zero();
}

template<typename T>
void
CXform<T>::MakeIdentity(void)
{
	if (fIsIdentity)
		return;
	
	//  Change the following code to be a fast memfill operation, or something similar.

	for (uint32_t i = 0; i < 4; i++)
		for (uint32_t j = 0; j < 4; j++)
				fElement[i][j] = 0.0;
	
	for (uint32_t i = 0; i < 4; i++)
	{
		fElement[i][i] = 1.0;
	}
	
	fIsIdentity = true;
}

template<typename T>
const CXform<T>&
CXform<T>::MakeInverse() const
{
	return *this;
}

template<typename T>
CXform<T>
CXform<T>::operator* (const CXform<T>& m) const
{
	if (m.fIsIdentity)			//	If m is the identity matrix, then just return this one.
		return *this;
	
	if (fIsIdentity)			//	If this is the identity matrix, then just return m.
		return m;
	
	CXform cross;
	
	for (register short i = 0; i < 4; i++)
		for (register short j = 0; j < 4; j++)
			for (register short k = 0; k < 4; k++)
				cross.fElement[i][j] += fElement[i][k] * m.fElement[k][j];
	
	return cross;
}

// ----------------------------------------------------------------------------------
//	[public]
//	• void MakeRotCol (const Vector& rX, const Vector& rY, const Vector& rZ)
// ----------------------------------------------------------------------------------
//		Make a rotation matrix by replacing the upper-left three columns of fElement
//	with the parameters.

template<typename T>
void
CXform<T>::MakeRotCol (const Vector<T>& rX, const Vector<T>& rY, const Vector<T>& rZ)
{
	//	Element accesses are done in the following order to
	//	improve cache hit efficiency.
	
	fElement[0][0] = rX.x;
	fElement[0][1] = rY.x;
	fElement[0][2] = rZ.x;
	fElement[0][3] = 0.0;
	
	fElement[1][0] = rX.y;
	fElement[1][1] = rY.y;
	fElement[1][2] = rZ.y;
	fElement[1][3] = 0.0;
	
	fElement[2][0] = rX.z;
	fElement[2][1] = rY.z;
	fElement[2][2] = rZ.z;
	fElement[2][3] = 0.0;
	
	fElement[3][0] = 0.0;
	fElement[3][1] = 0.0;
	fElement[3][2] = 0.0;
	fElement[3][3] = 1.0;
	
	fIsIdentity = false;
}

// ----------------------------------------------------------------------------------
//	[public]
//	• void MakeRotRow (const Vector& rX, const Vector& rY, const Vector& rZ)
// ----------------------------------------------------------------------------------
//		Make a rotation matrix by replacing the upper-left three rows of fElement
//	with the parameters.

template<typename T>
void
CXform<T>::MakeRotRow (const Vector<T>& rX, const Vector<T>& rY, const Vector<T>& rZ)
{
	fElement[0][0] = rX.x;
	fElement[0][1] = rX.y;
	fElement[0][2] = rX.z;
	fElement[0][3] = 0.0;
	
	fElement[1][0] = rY.x;
	fElement[1][1] = rY.y;
	fElement[1][2] = rY.z;
	fElement[1][3] = 0.0;
	
	fElement[2][0] = rZ.x;
	fElement[2][1] = rZ.y;
	fElement[2][2] = rZ.z;
	fElement[2][3] = 0.0;
	
	
	fElement[3][0] = 0.0;
	fElement[3][1] = 0.0;
	fElement[3][2] = 0.0;
	fElement[3][3] = 1.0;
	
	fIsIdentity = false;
}

