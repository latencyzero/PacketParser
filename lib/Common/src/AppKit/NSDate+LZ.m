/**
	NSDate+LZ.m

	Created by Roderick Mann on 6/5/12.
	Copyright (c) 2012 Latency: Zero. All rights reserved.
*/

#import "NSDate+LZ.h"

//
//	Library Imports
//

#import "Debug.h"
#import "LZUtils.h"




@implementation NSDate(LZ)

- (NSString*)
relativeString
{
	//	Get the interval in seconds…
	
	CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
	CFAbsoluteTime ourTime = self.timeIntervalSinceReferenceDate;
	CFTimeInterval sec = now - ourTime;
	if (sec < 2.0)
	{
		return NSLocalizedString(@"Just now", @"");
	}
	else if (sec < 58.0)
	{
		return [NSString stringWithFormat: NSLocalizedString(@"%.0f seconds ago", @""), sec];
	}
	else if (sec < 1.5 * 60.0)
	{
		return NSLocalizedString(@"About a minute ago", @"");
	}
	else if (sec < 58.0 * 60.0)
	{
		NSTimeInterval min = sec / 60.0;
		return [NSString stringWithFormat: NSLocalizedString(@"%.0f minutes ago", @""), min];
	}
	else if (sec < 1.5 * 3600.0)
	{
		return NSLocalizedString(@"About an hour ago", @"");
	}
	else if (sec < 23.5 * 3600.0)
	{
		NSTimeInterval hour = round(sec / 3600.0);
		return [NSString stringWithFormat: NSLocalizedString(@"%.0f hours ago", @""), hour];
	}
	else
	{
		//	Now we check the date, and render "yesterday" or day of week, up
		//	to 7 days ago…
		//	TODO: this needs some work, determining how many days back to go.
				
		CFTimeZoneRef tz = CFTimeZoneCopyDefault();
		CFGregorianUnits gu = CFAbsoluteTimeGetDifferenceAsGregorianUnits(ourTime, now, tz, kCFGregorianUnitsDays);
		CFRelease(tz);
		SInt32 days = -gu.days;
		if (days == 1)
		{
			return NSLocalizedString(@"Yesterday", @"");
		}
		else if (days <= 3)
		{

			NSDateFormatter* df = [[NSDateFormatter alloc] init];
			df.dateFormat = @"cccc";
			NSString* s = [df stringFromDate: self];
			//NSLogDebug(@"s: %@", s);
			return s;
		}
		
		//	Finally, just render the date…
		
		NSDateFormatter* df = [[NSDateFormatter alloc] init];
		df.dateStyle = NSDateFormatterMediumStyle;
		return [df stringFromDate: self];
		
		//	TODO: Write version that either returns nil for absolute string,
		//	or takes in a format string.
	}
}



@end
