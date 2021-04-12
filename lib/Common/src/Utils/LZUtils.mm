/**
	LZUtils.m
	Telemetry
	
	Created by Roderick Mann on 9/24/10.
	Copyright 2010 Latency: Zero. All rights reserved.
*/

#import "LZUtils.h"






bool
isNil(id inObj)
{
	return inObj == nil || inObj == [NSNull null];
}


#if TARGET_OS_IPHONE
UIColor*
color8Bit(uint8_t inRed, uint8_t inGreen, uint8_t inBlue)
{
	return color8BitAlpha(inRed, inGreen, inBlue, 1.0f);
}

UIColor*
color8BitAlpha(uint8_t inRed, uint8_t inGreen, uint8_t inBlue, CGFloat inAlpha)
{
	return [UIColor colorWithRed: inRed / 255.0f green: inGreen / 255.0f blue: inBlue / 255.0f alpha: inAlpha];
}
#endif



@implementation LZUtils

+ (bool)
isNumber: (NSNumber*) inNum1 equalTo: (NSNumber*) inNum2
{
	if (inNum1 == nil && inNum2 == nil)
	{
		return true;
	}
	
	if (inNum1 == nil || inNum2 == nil)
	{
		return false;
	}
	
	return [inNum1 isEqualToNumber: inNum2];
}

+ (NSString*)
localizedString: (NSString*) inKey forCount: (NSUInteger) inCount
{
	NSMutableString* key = [NSMutableString stringWithString: inKey];
	
	if (inCount == 0)
	{
		[key appendString: @".0"];
	}
	else if (inCount == 1)
	{
		[key appendString: @".1"];
	}
	else
	{
		[key appendString: @".n"];
	}
	
	return NSLocalizedString(key, @"");
}



@end



#ifdef __cplusplus

#import <string>
#import <stdarg.h>
#import <cstdio>


std::string
stringWithFormat(const std::string& inFmt, ...)
{
	int size = 100;
	std::string str;
	va_list ap;
	
	while (true)
	{
		str.resize(size);
		va_start(ap, inFmt);
		int n = vsnprintf(const_cast<char*> (str.c_str()), size, inFmt.c_str(), ap);
		va_end(ap);
		
		if (n >= 0 && n < size)
		{
			str.resize(n);
			return str;
		}
		
		if (n >= 0)
		{
			size = n + 1;
		}
		else
		{
			size *= 2;
		}
	}
}


#endif
