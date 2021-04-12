//
//  TimeUtils.cpp
//  PlanetaryClock
//
//  Created by Roderick Mann on 8/22/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#include "TimeUtils.h"






double
CFAbsoluteTimeGetJulianDate(CFAbsoluteTime inAT)
{
	double jUT = 2451910.5 + inAT / kSecondsPerDay;
	return jUT;
}

CFAbsoluteTime
JulianDateGetCFAbsoluteTime(double inJUT)
{
	CFAbsoluteTime at = (inJUT - 2451910.5) * kSecondsPerDay;
	return at;
}

double
unixTimeToJulianUT(double inAT)
{
	double jut = 2440587.5 + inAT / kSecondsPerDay;
	return jut;
}

/**
	Determine the elapsed time in Julian centuries from 2000-01-01 12:00:00 (UT)
*/

double
julianUTGetJ2000(double inJUT)
{
	double j2000 = (inJUT - 2451545.0) / 36525.0;
	return j2000;
}

double
UTCtoTTConversion(double inMJD)
{
	if (inMJD < 2441317.5)
	{
		//NSAssert(false, @"Oops, gotta write empirical formula for dates prior to 1972");
		return 0.0;
	}
	
	if (inMJD < 2441499.5)		return 32.184 + 10.0;
	if (inMJD < 2441683.5)		return 32.184 + 11.0;
	if (inMJD < 2442048.5)		return 32.184 + 12.0;
	if (inMJD < 2442413.5)		return 32.184 + 13.0;
	if (inMJD < 2442778.5)		return 32.184 + 14.0;
	if (inMJD < 2443144.5)		return 32.184 + 15.0;
	if (inMJD < 2443509.5)		return 32.184 + 16.0;
	if (inMJD < 2443874.5)		return 32.184 + 17.0;
	if (inMJD < 2444239.5)		return 32.184 + 18.0;
	if (inMJD < 2444786.5)		return 32.184 + 19.0;
	if (inMJD < 2445151.5)		return 32.184 + 20.0;
	if (inMJD < 2445516.5)		return 32.184 + 21.0;
	if (inMJD < 2446247.5)		return 32.184 + 22.0;
	if (inMJD < 2447161.5)		return 32.184 + 23.0;
	if (inMJD < 2447892.5)		return 32.184 + 24.0;
	if (inMJD < 2448257.5)		return 32.184 + 25.0;
	if (inMJD < 2448804.5)		return 32.184 + 26.0;
	if (inMJD < 2449169.5)		return 32.184 + 27.0;
	if (inMJD < 2449534.5)		return 32.184 + 28.0;
	if (inMJD < 2450083.5)		return 32.184 + 29.0;
	if (inMJD < 2450630.5)		return 32.184 + 30.0;
	if (inMJD < 2451179.5)		return 32.184 + 31.0;
	if (inMJD < 2453736.5)		return 32.184 + 32.0;
	if (inMJD < 2454832.5)		return 32.184 + 33.0;
	if (inMJD < 2456109.5)		return 32.184 + 34.0;
	
	return 32.184 + 35.0;	//	from 2012 July 1, 0h UTC, until further notice : UTC-TAI = -35 s
}

double
TTtoUTCConversion(double inJTT)
{
	//	TODO: update this to check inJTT for the appropriate conversion!
	
	return -(32.184 + 35.0);
}

double
julianUTGetJulianTT(double inJUT)
{
	double ttUTC = UTCtoTTConversion(inJUT);
	double julianTT = inJUT + ttUTC / kSecondsPerDay;
	return julianTT;
}

double
JulianTTGetJulianUT(double inJTT)
{
	double utcTT = TTtoUTCConversion(inJTT);
	double jUT = inJTT + utcTT / kSecondsPerDay;
	return jUT;
}

double
julianTTGetJulian2000TT(double inJTT)
{
	double j2000TT = inJTT - 2451545.0;
	return j2000TT;
}

double
marsMeanAnomaly(double inJ2000TT)
{
	double M = 19.3870 + 0.52402075 * inJ2000TT;
	return M;
}

double
angleOfFMS(double inJ2000TT)
{
	double a = 270.3863 + 0.52403840 * inJ2000TT;
	return a;
}

double
perturber(double inJ2000TT, double inA, double inTau, double inPsi)
{
	const double k = 360.0 / 365.25;
	double p = inA * cos(k * inJ2000TT / inTau) + inPsi;
	return p;
}

double
perturbers(double inJ2000TT)
{
	double p1 = perturber(inJ2000TT, 0.0071,  2.2353,  49.409);
	double p2 = perturber(inJ2000TT, 0.0057,  2.7543, 168.173);
	double p3 = perturber(inJ2000TT, 0.0039,  1.1177, 191.837);
	double p4 = perturber(inJ2000TT, 0.0037, 15.7866,  21.736);
	double p5 = perturber(inJ2000TT, 0.0021,  2.1354,  15.704);
	double p6 = perturber(inJ2000TT, 0.0020,  2.4694,  95.528);
	double p7 = perturber(inJ2000TT, 0.0018, 32.8493,  49.095);
	
	return p1 + p2 + p3 + p4 + p5 + p6 + p7;
}

double
eoc(double inJ2000TT, double inM, double inPBS)
{
	double eoc = (10.691 + 3.0e-7 * inJ2000TT) * sin(inM)
					+ 0.623 * sin(2 * inM)
					+ 0.050 * sin(3 * inM)
					+ 0.005 * sin(4 * inM)
					+ 0.0005 * sin(5 * inM)
					+ inPBS;
	return eoc;
}

double
aerocentricSolarLon(double inFMS, double inEOC)
{
	double l = inFMS + inEOC;
	return l;
}

double
eot(double inAeroSolarLon, double inEOC)
{
	double eot = 2.861 * sin(2 * inAeroSolarLon)
				- 0.071 * sin(4 * inAeroSolarLon)
				+ 0.002 * sin(6 * inAeroSolarLon)
				- inEOC;
	return eot;
}

double
j2000TTToMSD(double inJ2000TT)
{
	inJ2000TT -= 2451549.5;
	double msd = inJ2000TT / kEarthSecondsPerMarsSecond + 44796.0 - 0.00096;
	return msd;
}

double
MSDToJ2000(double inMSD)
{
	double j2000 = (inMSD - 44796.0 + 00.00096) * kEarthSecondsPerMarsSecond;
	j2000 += 2451549.5;
	return j2000;
}


double
j2000TTToMTC(double inJ2000TT)
{
	double mtc = 24.0 * j2000TTToMSD(inJ2000TT);
	mtc = fmod(mtc, 24.0);
	return mtc;
}

double
lonToTimeZone(double inLonWest)
{
	//	TODO: wrap lon greater than ±180
	
	double l = -inLonWest + 7.5;
	
	double z = l / 15.0;
	z = floor(z);
	
	return z;
}

double
j2000TTToZonalDay(double inJ2000TT, double inLonWest)
{
	inJ2000TT -= 2451549.5;
	double msd = inJ2000TT / kEarthSecondsPerMarsSecond + 44796.0 - 0.00096;
	double z = lonToTimeZone(inLonWest);
	msd += z / 24.0;
	
	return msd;
}

double
j2000TTToZonalTime(double inJ2000TT, double inLonWest)
{
	double mtc = 24.0 * j2000TTToZonalDay(inJ2000TT, inLonWest);
	mtc = fmod(mtc, 24.0);
	return mtc;
}

double
MSDtoZonalTime(double inMSD, double inLonWest)
{
	//	TODO: wrap lon greater than ±180
	
	double l = -inLonWest + 7.5;
	
	double z = l / 15.0;
	z = floor(z);
	
	double t = 24.0 * inMSD + z;
	t = fmod(t, 24.0);
	return t;
}

double
CFAbsoluteTimeGetMSD(CFAbsoluteTime inAT)
{
	double jUT = CFAbsoluteTimeGetJulianDate(inAT);
	double jTT = julianUTGetJulianTT(jUT);
	double msd = j2000TTToMSD(jTT);
	return msd;
}

CFAbsoluteTime
MSDToCFAbsoluteTime(double inMSD)
{
	double jTT = MSDToJ2000(inMSD);
	double jUT = JulianTTGetJulianUT(jTT);
	CFAbsoluteTime at = JulianDateGetCFAbsoluteTime(jUT);
	return at;
}

double
unixTimeToMSD(double inUnixTime)
{
	double jUT = unixTimeToJulianUT(inUnixTime);
	double jTT = julianUTGetJulianTT(jUT);
	double msd = j2000TTToMSD(jTT);
	return msd;
}

double
msdToMST(double inMSD)
{
	double mst = 24.0 * inMSD;
	mst = fmod(mst, 24.0);
	return mst;
}

void
hoursToHMS(double inHours, uint16_t* outHour, uint16_t* outMin, double* outSec)
{
	double truncHour = trunc(inHours);
	
	if (outHour != NULL)
	{
		*outHour = truncHour;
	}
	
	double f = inHours - truncHour;
	double min = f * 60.0;
	min = trunc(min);
	f -= min / 60.0;
	
	double sec = f * 3600.0;
	
	if (outMin != NULL)
	{
		*outMin = min;
	}
	
	if (outSec != NULL)
	{
		*outSec = sec;
	}
}

void
timeOfDayToHMS(double inTimeOfDay, uint16_t* outHour, uint16_t* outMin, double* outSec)
{
	inTimeOfDay = fmod(inTimeOfDay, kSecondsPerDay);
	
	double v = trunc(inTimeOfDay / 3600.0);
	if (outHour != NULL)
	{
		*outHour = v;
		inTimeOfDay -= v * 3600.0;
	}
	
	v = trunc(inTimeOfDay / 60.0);
	if (outMin != NULL)
	{
		*outMin = v;
		inTimeOfDay -= v * 60.0;
	}
	
	if (outSec != NULL)
	{
		*outSec = v;
	}
}


#if 0
//	Don't know why this formula doesn't work.
int32_t
gregorianToMJD(int32_t inYear, int8_t inMonth, int8_t inDay)
{
	int8_t mm = 14 - inMonth;
	int8_t a = mm / 12;
	int32_t y = inYear + 4800 - a;
	int8_t m = inMonth + mm - 3;
	
	int32_t jdn = inDay
				+ (153 * m + 2) / 5
				+ 365 * y
				+ y / 4
				- y / 100
				+ y / 400
				- 32045;
	jdn -= 2400000;
	return jdn;
}
#else
int32_t
gregorianToMJD(int32_t inYear, int8_t inMonth, int8_t inDay)
{
	int8_t mm = 14 - inMonth;
	int8_t a = mm / 12;

	int32_t jd12h = inDay - 32075L
						+ 1461L * (inYear + 4800L - a) / 4L
						+ 367L * (inMonth - 2L + a * 12L) / 12L
						- 3L * ((inYear + 4900L - a) / 100L) / 4L;
	jd12h -= 2400001;
	return jd12h;
}
#endif

int32_t
gregorianToJDN(int32_t inYear, int8_t inMonth, int8_t inDay)
{
	int32_t jd12h = inDay - 32075L + 1461L * (inYear + 4800L
						+ (inMonth - 14L) / 12L) / 4L
						+ 367L * (inMonth - 2L - (inMonth - 14L) / 12L * 12L)
						/ 12L - 3L * ((inYear + 4900L + (inMonth - 14L) / 12L)
						/ 100L) / 4L;
	return jd12h;
}

double
mjdToMTC(double inMJD)
{
	double utcToTT = UTCtoTTConversion(inMJD + 2400000.5);
	inMJD += utcToTT / kSecondsPerDay;
	inMJD -= 51549.0;
	double msd = inMJD / kEarthSecondsPerMarsSecond + 44796.0 - 0.00096;
	return msd;
}

