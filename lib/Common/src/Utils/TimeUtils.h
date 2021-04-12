//
//  TimeUtils.h
//  PlanetaryClock
//
//  Created by Roderick Mann on 8/22/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#ifndef __TimeUtils_h__
#define __TimeUtils_h__


const double kEarthSecondsPerMarsSecond			=	1.027491252;
const double kSecondsPerDay						=	24 * 3600.0;


double		CFAbsoluteTimeGetJulianDate(CFAbsoluteTime inAT);
double		unixTimeToJulianUT(double inAT);
double		julianUTGetJ2000(double inJUT);
double		UTCtoTTConversion(double inMJD);
double		julianUTGetJulianTT(double inJUT);
double		julianTTGetJulian2000TT(double inJTT);
double		marsMeanAnomaly(double inJ2000TT);
double		angleOfFMS(double inJ2000TT);
double		perturber(double inJ2000TT, double inA, double inTau, double inPsi);
double		perturbers(double inJ2000TT);
double		eoc(double inJ2000TT, double inM, double inPBS);
double		aerocentricSolarLon(double inFMS, double inEOC);
double		eot(double inAeroSolarLon, double inEOC);
double		j2000TTToMSD(double inJ2000TT);
double		j2000TTToMTC(double inJ2000TT);
double		lonToTimeZone(double inLonWest);
double		j2000TTToZonalDay(double inJ2000TT, double inLonWest);
double		j2000TTToZonalTime(double inJ2000TT, double inLonWest);
double		MSDtoZonalTime(double inMSD, double inLonWest);

double			CFAbsoluteTimeGetMSD(double inUnixTime);
CFAbsoluteTime	MSDToCFAbsoluteTime(double inMSD);

double		unixTimeToMSD(double inUnixTime);
double		msdToMST(double inMSD);

void		hoursToHMS(double inHours, uint16_t* outHour, uint16_t* outMin, double* outSec);
void		timeOfDayToHMS(double inTimeOfDay, uint16_t* outHour, uint16_t* outMin, double* outSec);

int32_t		gregorianToMJD(int32_t inYear, int8_t inMonth, int8_t inDay);
int32_t		gregorianToJDN(int32_t inYear, int8_t inMonth, int8_t inDay);
int32_t		gregorianToJDN2(int32_t inYear, int8_t inMonth, int8_t inDay);

double		mjdToMTC(double inMJD);

#endif	//	__TimeUtils_h__
