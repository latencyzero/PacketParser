/**
	LZUtils.h
	Telemetry
	
	Created by Roderick Mann on 9/24/10.
	Copyright 2010 Latency: Zero. All rights reserved.
*/


#ifdef __cplusplus
extern "C" {
#endif

bool			isNil(id inObj);

inline
float
max(float inA, float inB)
{
	return inA > inB ? inA : inB;
}

inline
float
min(float inA, float inB)
{
	return inA < inB ? inA : inB;
}

#if TARGET_OS_IPHONE
UIColor*			color8Bit(uint8_t inRed, uint8_t inGreen, uint8_t inBlue);
UIColor*			color8BitAlpha(uint8_t inRed, uint8_t inGreen, uint8_t inBlue, float inAlpha);
#endif

#ifdef __cplusplus
}
#endif


@interface LZUtils : NSObject

+ (bool)					isNumber: (NSNumber*) inNum1 equalTo: (NSNumber*) inNum2;

+ (NSString*)				localizedString: (NSString*) inKey forCount: (NSUInteger) inCount;

@end


#ifdef __cplusplus

#import <string>

std::string		stringWithFormat(const std::string& inFmt, ...);


#endif
