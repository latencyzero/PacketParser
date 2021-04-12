/**
	LoggerFactory.h

	Copyright 2010 Latency: Zero. All rights reserved.
*/



@class Logger;

@interface
LoggerFactory : NSObject
{
	NSMutableDictionary*		mLoggers;
}


+ (LoggerFactory*)			sharedFactory;

- (id)						init;

- (Logger*)					getLogger: (NSString*) inName;

@end
