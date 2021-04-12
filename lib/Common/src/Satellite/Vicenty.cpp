/**
	Computes the ellipsoidal distance along the surface of the Earth
	between the two points. The code uses Vicenty's Formulæ, as
	described on Wikipedia:
	
		http://en.wikipedia.org/wiki/Vincenty%27s_formulae
	
	According to the article, points on opposite sides of the
	ellipsoid may not converge to a value. This code makes
	no attempt to detect this condition and abort.
	
	The points should be supplied in degrees, not radians.
	
	©2011 Latency: Zero and Roderick L. Mann. All rights reserved.
	Permission to use this code is granted, provided that you leave
	this copyright notice intact, and send any corrections to
	rmann@latencyzero.com.
	
	@param	outAzimuth		Can be NULL.
*/

#include "Vicenty.h"

//
//	Project Includes
//

#include <math.h>






double
computeDistanceAndAzimuth(double inLon1, double inLat1, double inLon2, double inLat2, double* outAzimuth)
{
#define kUseUpdate			1

//	systime_t start = chTimeNow();
	
	const double kEarthMajorAxis			=	6378137.0;
	const double kEarthMajorAxis2			=	kEarthMajorAxis * kEarthMajorAxis;
	const double kEarthMinorAxis			=	6356752.314;
	const double kEarthMinorAxis2			=	kEarthMinorAxis * kEarthMinorAxis;
	const double kFlattening				=	0.003352810664747;
	const double kLambdaThreshold			=	1.0e-12;
	const double kDegreesToRadians			=	M_PI / 180.0;
	
	double lon1 = inLon1 * kDegreesToRadians;
	double lat1 = inLat1 * kDegreesToRadians;
	double lon2 = inLon2 * kDegreesToRadians;
	double lat2 = inLat2 * kDegreesToRadians;
	
	double U1 = atan((1.0 - kFlattening) * tan(lat1));
	double U2 = atan((1.0 - kFlattening) * tan(lat2));
	
	double cosU1 = cos(U1);
	double sinU1 = sin(U1);
	double cosU2 = cos(U2);
	double sinU2 = sin(U2);
	double cosU1cosU2 = cosU1 * cosU2;
	double sinU1sinU2 = sinU1 * sinU2;
		
	double L = lon2 - lon1;
	double l = L;
	double deltaLambda;
	double cos2Alpha;
	double sinAlpha;
	double sinS;
	double cosS;
	double cos2SigmaM;
	double s;
	
	do
	{
		double cosl = cos(l);
		double sinl = sin(l);
		
		double t1 = cosU2 * sinl;
		double t2 = cosU1 * sinU2 - sinU1 * cosU2 * cosl;
		sinS = sqrt(t1 * t1 + t2 * t2);
		
		cosS = sinU1sinU2 + cosU1cosU2 * cosl;
		
		s = atan2(sinS, cosS);
		
		sinAlpha = cosU1cosU2 * sinl / sinS;
		
		cos2Alpha = 1.0 - sinAlpha * sinAlpha;
		cos2SigmaM = cosS - 2.0 * sinU1sinU2 / cos2Alpha;
		
		double C = (kFlattening / 16.0) * cos2Alpha * (4.0 + kFlattening * (4.0 - 3.0 * cos2Alpha));
		
		double lastLambda = l;
		l = L + (1.0 - C) * kFlattening * sinAlpha * (s + C * sinS * (cos2SigmaM + C * cosS * (-1.0 + 2.0 * cos2SigmaM * cos2SigmaM)));
		deltaLambda = fabs(l - lastLambda);
	} while (deltaLambda > kLambdaThreshold);
	
	double u2 = cos2Alpha * (kEarthMajorAxis2 - kEarthMinorAxis2) / kEarthMinorAxis2;
	
#if kUseUpdate
	double sqrtu2Plu1 = sqrt(1.0 + u2);
	double k1 = (sqrtu2Plu1 - 1.0) / (sqrtu2Plu1 + 1.0);
	double k12 = k1 * k1;
	double A = (1.0 + 0.25 * k12);
	double B = k1 * (1.0 - (3.0/8.0) * k12);
#else
	double A = 1.0 + (u2 / 16384.0) * (4096.0 + u2 * (-768.0 + u2 * (320.0 - 175.0 * u2)));
	double B = (u2 / 1024.0) * (256.0 + u2 * (-128.0 + u2 * (74.0 - 47* u2)));
#endif
	
	double deltaS = B * sinS * (cos2SigmaM + 0.25 * B * (cosS * (-1.0 + 2.0 * cos2SigmaM) - (B / 6.0) * cos2SigmaM * (-3.0 + 4.0 * sinS * sinS) * (-3.0 + 4.0 * cos2SigmaM)));
	
	double dist = kEarthMajorAxis * A * (s - deltaS);
	
	if (outAzimuth != NULL)
	{
		double numer = cosU2 * sin(l);
		double denom = cosU1 * sinU2 - sinU1 * cosU2 * cos(l);
		double alpha1 = atan2(numer, denom);
		
		*outAzimuth = alpha1;
	}
		
//	systime_t end = chTimeNow();
//	sLogger.log("Time to compute distance: %lu ms\n", end - start);
	
	return dist;
}
