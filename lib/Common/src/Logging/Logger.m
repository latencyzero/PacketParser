/**
	Logger.m

	Copyright 2010 Latency: Zero. All rights reserved.
*/

#import "Logger.h"

//
//	Standard Imports
//

#include <stdarg.h>
#include <execinfo.h>

//
//	Project Imports
//

#import "LoggerFactory.h"




@implementation Logger

bool			sEnabled = true;

+ (Logger*)
getLogger: (NSString*) inName
{
	LoggerFactory* factory = [LoggerFactory sharedFactory];
	Logger* logger = [factory getLogger: inName];
	return logger;
}

+ (Logger*)
getCanonicalLogger: (char const*) inFileMacro
{
	NSString* path = [NSString stringWithCString: inFileMacro encoding: NSUTF8StringEncoding];
	path = [path stringByDeletingPathExtension];
	NSArray* components = [path pathComponents];
	
	//	Find the index of the "Source" component.
	//	TODO: parameterize the point in the tree where we chop this off.
	
	uint32_t topIndex = [components indexOfObject: @"src"];
	
	//	TODO: Parameterize the logger name root…
	
	NSMutableString*	name = [NSMutableString stringWithString: @"com.latencyzero.missionclock"];
	
	for (uint32_t idx = topIndex + 1; idx < components.count; idx++)
	{
		NSString* comp = [components objectAtIndex: idx];
		//	TODO: Remove whitespace?
		
		[name appendFormat: @".%@", comp];
	}
	//NSLog(@"Created logger named [%@]", name);
	
	LoggerFactory* factory = [LoggerFactory sharedFactory];
	Logger* logger = [factory getLogger: name];
	return logger;
}

+ (void)
setEnabled: (bool) inEnabled
{
	sEnabled = inEnabled;
}

- (id)
initWithName: (NSString*) inName
{
	self = [super init];
	if (self != nil)
	{
		mName = inName;
		mActive = true;
		mDebugEnabled = true;
	}
	
	return self;
}

- (void)
log:			(const char*)	inFileName
	line:		(uint32_t)		inLineNumber
	cmd:		(SEL)			inCmd
	level:		(LogLevel)		inLevel
	format:		(NSString*)		inFormat
	arguments:	(va_list)		inArgs
{
	[self log: inFileName
			line: inLineNumber
			func: [NSStringFromSelector(inCmd) UTF8String]
			level: inLevel
			format: inFormat
			arguments: inArgs];
}

- (void)
log:			(const char*)	inFileName
	line:		(uint32_t)		inLineNumber
	func:		(char const *)	inFuncName
	level:		(LogLevel)		inLevel
	format:		(NSString*)		inFormat
	arguments:	(va_list)		inArgs
{
	if (!sEnabled || !mActive || (inLevel == kLogLevelDebug && !self.debugEnabled))
	{
		return;
	}
	
#ifdef	kStackTraceExperiment
	void* callstack[128];
	int frames = ::backtrace(callstack, 128);
	char** strs = ::backtrace_symbols(callstack, frames);
	for (int i = 0; i < frames; i++)
	{
		::NSLog(@"BT: %s", strs[i]);
	}
	::free(strs);
#endif
	
	//	Process the filename to get rid of any path that might be attached (Xcode
	//	like full path names, and doesn't even normalize them)…
	
	NSString* fileName = [[NSString stringWithCString: inFileName encoding: NSUTF8StringEncoding] lastPathComponent];
	NSString* funcName = [NSString stringWithCString: inFuncName encoding: NSUTF8StringEncoding];
	
	//	Render the log message…
	
	NSString* s = [NSString stringWithFormat: @"%@ (%@:%u): %@\n", funcName, fileName, inLineNumber, inFormat];
	s = [[NSString alloc] initWithFormat: s arguments: inArgs];
	printf("%s", [s UTF8String]);
	[s release];
	//NSLogv(s, inArgs);
}

- (void)
log:		(const char*)	inFileName
	line:	(uint32_t)		inLineNumber
	cmd:	(SEL)			inCmd
	level:	(LogLevel)		inLevel
	format:	(NSString*)		inFormat,
	...
{
    va_list		args;
    va_start(args, inFormat);
	
	if (!sEnabled || !mActive)
	{
		return;
	}
	
	[self log: inFileName
			line: inLineNumber
			cmd: inCmd
			level: inLevel
			format: inFormat
			arguments: args];
	
	va_end(args);
}

- (void)
log:		(const char*)	inFileName
	line:	(uint32_t)		inLineNumber
	func:	(char const *)	inFuncName
	level:	(LogLevel)		inLevel
	format:	(NSString*)		inFormat,
	...
{
    va_list		args;
    va_start(args, inFormat);
	
	if (!sEnabled || !mActive)
	{
		return;
	}
	
	[self log: inFileName
			line: inLineNumber
			func: inFuncName
			level: inLevel
			format: inFormat
			arguments: args];
	
	va_end(args);
}


- (void)
log: (LogLevel) inLevel
	format: (NSString*) inFormat,
	...
{
    va_list		args;
    va_start(args, inFormat);
	
	if (!sEnabled || !mActive)
	{
		return;
	}
	
    [self log: inLevel format: inFormat arguments: args];
	
	va_end(args);
}

- (void)
log: (LogLevel) inLevel
	format: (NSString*) inFormat
	arguments: (va_list) inArgs
{
	if (!sEnabled || !mActive)
	{
		return;
	}
#if TARGET_IPHONE_SIMULATOR && defined(DEBUG)	
	NSLogv(inFormat, inArgs);
#endif
}

/*
- (void)
debug: (NSString*) inFormat, ...
{
    va_list		args;
    va_start(args, inFormat);
	
    [self log: kLogLevelDebug withFormat: inFormat arguments: args];
	
	va_end(args);
}
*/

@synthesize active = mActive;
@synthesize debugEnabled = mDebugEnabled;


@end
