/**
	LZTimeUtils.h

	Created by Roderick Mann on 4/17/12.
	Copyright (c) 2012 Latency: Zero. All rights reserved.
*/


/**
	Returns the portion of the current hour for inTime, normalized on the interval
	[0.0, 1.0), for the specified time zone.
*/

#ifdef	__cplusplus
extern "C"
{
#endif


SInt8			currentHour(CFAbsoluteTime inTime, CFTimeZoneRef inTZ);
double			normalizedWallHourFraction(CFAbsoluteTime inTime, CFTimeZoneRef inTZ);
CFAbsoluteTime	timeForHourOfDay(int8_t inHour, CFAbsoluteTime inDay, CFTimeZoneRef inTZ);


#ifdef	__cplusplus
}
#endif



@interface
LZTimeUtils : NSObject
{

}

+ (CFGregorianUnits)		intervalToUnitsHMS: (CFTimeInterval) inInterval;
+ (CFGregorianUnits)		intervalToUnitsDHMS: (CFTimeInterval) inInterval;

+ (NSString*)				formatIntervalHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign;
+ (NSString*)				formatIntervalDHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign;
+ (NSString*)				formatIntervalDHMS2: (CFTimeInterval) inInterval forceSign: (bool) inForceSign;
+ (NSString*)				formatIntervalDaysHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign;


@end


