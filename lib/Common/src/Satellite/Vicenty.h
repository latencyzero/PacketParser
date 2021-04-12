




#ifndef	__Vicenty_h__
#define __Vicenty_h__



#ifdef __cplusplus
extern "C"
{
#endif


double			computeDistanceAndAzimuth(double inLon1, double inLat1, double inLon2, double inLat2, double* outAzimuth);


inline
double
computeDistance(double inLon1, double inLat1, double inLon2, double inLat2)
{
	return computeDistanceAndAzimuth(inLon1, inLat1, inLon2, inLat2, NULL);
}

#ifdef __cplusplus
}
#endif

#endif	//	__Vicenty_h__
