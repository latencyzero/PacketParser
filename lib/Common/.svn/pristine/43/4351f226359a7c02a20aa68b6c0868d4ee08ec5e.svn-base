/**
	LoggerFactory.h

	Copyright 2010 Latency: Zero. All rights reserved.
*/

#import "LoggerFactory.h"

//
//	Project Imports
//

#import "Logger.h"



@implementation LoggerFactory

+ (LoggerFactory*)
sharedFactory
{
	static LoggerFactory*		sLoggerFactory = nil;
	if (sLoggerFactory == nil)
	{
		sLoggerFactory = [[LoggerFactory alloc] init];
	}
	
	return sLoggerFactory;
}

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		mLoggers = [[NSMutableDictionary dictionaryWithCapacity: 10] retain];
	}
	
	return self;
}

- (void)
dealloc
{
	[mLoggers release];
	
	[super dealloc];
}

- (Logger*)
getLogger: (NSString*) inName
{
	Logger* logger = [mLoggers valueForKey: inName];
	if (logger == nil)
	{
		logger = [[Logger alloc] initWithName: inName];
		[mLoggers setValue: logger forKey: inName];
		[logger release];
	}
	
	return logger;	//	Leak okay; loggers live forever. Perhaps this should be called "createLogger".
}


@end
