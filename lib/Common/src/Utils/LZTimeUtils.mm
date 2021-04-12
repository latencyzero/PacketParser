#import "LZTimeUtils.h"

//
//	Standard Imports
//

#import <cmath>

//
//	Library Imports
//

#import "LZConstants.h"
#import "LZTimeUtils.h"
#import "LZUtils.h"

//
//	Project Imports
//

#import "LZConstants.h"


SInt8
currentHour(CFAbsoluteTime inTime, CFTimeZoneRef inTZ)
{
	CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(inTime, inTZ);
	return gd.hour;
}

double
normalizedWallHourFraction(CFAbsoluteTime inTime, CFTimeZoneRef inTZ)
{
	CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(inTime, inTZ);
	CFGregorianDate lastHour = gd;
	lastHour.minute = 0;
	lastHour.second = 0.0;
	CFAbsoluteTime lastHourAbs = CFGregorianDateGetAbsoluteTime(lastHour, inTZ);
	CFTimeInterval interval = inTime - lastHourAbs;
	double normalizedInterval = interval / kCFTimeIntervalHour;
	
	return normalizedInterval;
}

CFAbsoluteTime
timeForHourOfDay(int8_t inHour, CFAbsoluteTime inDay, CFTimeZoneRef inTZ)
{
	CFGregorianDate gd = CFAbsoluteTimeGetGregorianDate(inDay, inTZ);
	gd.hour = inHour;
	gd.minute = 0;
	gd.second = 0.0;
	
	CFAbsoluteTime hour = CFGregorianDateGetAbsoluteTime(gd, inTZ);
	
	return hour;
}


@implementation LZTimeUtils

+ (CFGregorianUnits)
intervalToUnitsHMS: (CFTimeInterval) inInterval
{
	CFGregorianUnits remaining = { 0 };
	
	int64_t interval = static_cast<int64_t>(inInterval);
	remaining.hours = interval / 3600;
	interval -= remaining.hours * 3600;
	remaining.minutes = interval / 60;
	interval -= remaining.minutes * 60;
	remaining.seconds = interval;
	
	return remaining;
}

+ (CFGregorianUnits)
intervalToUnitsDHMS: (CFTimeInterval) inInterval
{
	CFGregorianUnits remaining = { 0 };
	
	int64_t interval = static_cast<int64_t>(inInterval);
	
	remaining.days = interval / (24 * 3600);
	interval -= remaining.days * 24 * 3600;
	
	remaining.hours = interval / 3600;
	interval -= remaining.hours * 3600;
	
	remaining.minutes = interval / 60;
	interval -= remaining.minutes * 60;
	
	remaining.seconds = interval;
	
	return remaining;
}

+ (NSString*)
formatIntervalHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign
{
	CFGregorianUnits interval = [LZTimeUtils intervalToUnitsHMS: std::abs(inInterval)];
	char const* sign = "";
	if (inForceSign && inInterval >= 0.0)
	{
		if (inInterval > 0.0)
		{
			sign = "+";
		}
		else
		{
			sign = "-";
		}
	}
	else if (inInterval < 0.0)
	{
		sign = "-";
	}
	
	int32_t secs = interval.seconds;
	
	NSString* s = [NSString stringWithFormat: @"%s%02d:%02d:%02d",
								sign,
								interval.hours,
								interval.minutes,
								secs];
	return s;
}

+ (NSString*)
formatIntervalDHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign
{
	CFGregorianUnits interval = [LZTimeUtils intervalToUnitsDHMS: std::abs(inInterval)];
	char const* sign = "";
	if (inForceSign && inInterval >= 0.0)
	{
		if (inInterval > 0.0)
		{
			sign = "+";
		}
		else
		{
			sign = "-";
		}
	}
	else if (inInterval < 0.0)
	{
		sign = "-";
	}
	
	int32_t secs = interval.seconds;
	
	NSMutableString* s = [NSMutableString stringWithFormat: @"%s", sign];
	if (true || interval.days != 0)
	{
		[s appendFormat: @"%03d/", interval.days];
	}
	
	[s appendFormat: @"%02d:%02d",
						interval.hours,
						interval.minutes];
	
	//	We don’t show the seconds if the mission is more than 1000 days along…
	
	if (interval.days < 1000)
	{
		[s appendFormat: @":%02d", secs];
	}
	
	return s;
}

+ (NSString*)
formatIntervalDHMS2: (CFTimeInterval) inInterval forceSign: (bool) inForceSign
{
	CFGregorianUnits interval = [LZTimeUtils intervalToUnitsDHMS: std::abs(inInterval)];
	char const* sign = "";
	if (inForceSign && inInterval >= 0.0)
	{
		if (inInterval > 0.0)
		{
			sign = "+";
		}
		else
		{
			sign = "-";
		}
	}
	else if (inInterval < 0.0)
	{
		sign = "-";
	}
	
	int32_t secs = interval.seconds;
	
	NSMutableString* s = [NSMutableString stringWithFormat: @"%s", sign];
	if (true || interval.days != 0)
	{
		[s appendFormat: @"%d/", interval.days];
	}
	
	[s appendFormat: @"%02d:%02d",
						interval.hours,
						interval.minutes];
	
	//	We don’t show the seconds if the mission is more than 1000 days along…
	
	if (interval.days < 1000)
	{
		[s appendFormat: @":%02d", secs];
	}
	
	return s;
}

+ (NSString*)
formatIntervalDaysHMS: (CFTimeInterval) inInterval forceSign: (bool) inForceSign
{
	CFGregorianUnits interval = [LZTimeUtils intervalToUnitsDHMS: std::abs(inInterval)];
	char const* sign = "";
	if (inForceSign && inInterval >= 0.0)
	{
		if (inInterval > 0.0)
		{
			sign = "+";
		}
		else
		{
			sign = "-";
		}
	}
	else if (inInterval < 0.0)
	{
		sign = "-";
	}
	
	int32_t secs = interval.seconds;
	
	NSMutableString* s = [NSMutableString stringWithFormat:@"%s", sign];
	[s appendFormat: @"%d %@, %02d:%02d",
			interval.days,
			[LZUtils localizedString: @"day" forCount: interval.days],
			interval.hours,
			interval.minutes];
	
	//	We don’t show the seconds if the interval is more than 1000 days along…
	
	if (interval.days < 1000)
	{
		[s appendFormat: @":%02d", secs];
	}
	
	return s;
}

@end
