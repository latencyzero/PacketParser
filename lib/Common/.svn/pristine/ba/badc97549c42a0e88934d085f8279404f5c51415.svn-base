/**
	Logger.h

	Copyright 2010 Latency: Zero. All rights reserved.
*/

/**
	Having file * line information is very handy. Eventually, this facility
	will dig it out by examining the stack and debug info. For the time begin,
	macros simplify the process of adding __FILE__ and __LINE__ to each call.
	
	There are too many things named "info," etc for the following to work. Since
	the macros are only for determining the call location, we'll do without
	for the more severe errors.
*/

#define	debug		log: __FILE__ line: __LINE__ func: __PRETTY_FUNCTION__ level: kLogLevelDebug format
#define	logError	log: __FILE__ line: __LINE__ func: __PRETTY_FUNCTION__ level: kLogLevelError format

#if 0
#define	info		log: __FILE__ line: __LINE__ level: kLogLevelInfo format
#define	warn		log: __FILE__ line: __LINE__ level: kLogLevelWarn format
#define	fatal		log: __FILE__ line: __LINE__ level: kLogLevelFatal format
#endif

typedef enum
{
	kLogLevelTrace			=	1,
	kLogLevelDebug			=	2,
	kLogLevelInfo			=	3,
	kLogLevelWarn			=	4,
	kLogLevelError			=	5,
	kLogLevelFatal			=	6,
} LogLevel;

/**
	A Logger is the primary object through which logging messages are issued. Typical
	usage is to instantiate a single Logger object per class (typically a static
	class member) using [Logger getLogger: @"MyClassName"].
	
	Since Objective-C lacks static class members, just declare a static
	local variable in the file, and initialize it in the class +initialize
	method:
	
	static Logger*			sLogger;
	
	+ (void)
	initialize
	{
		if (self == [MyClassName class])
		{
			sLogger = [Logger getLogger: @"com.yahoo.projectName.subsection.MyClassName"]
		}
	}
*/

@interface
Logger : NSObject
{
	NSString*			mName;
	bool				mActive;
	bool				mDebugEnabled;
}

@property (nonatomic)							bool		active;
@property (nonatomic, getter=isDebugEnabled)	bool		debugEnabled;

+ (Logger*)				getLogger: (NSString*) inName;
+ (Logger*)				getCanonicalLogger: (char const*) inFileMacro;

+ (void)				setEnabled: (bool) inEnabled;

- (id)					initWithName: (NSString*) inName;

- (void)				log:			(const char*)	inFileName
							line:		(uint32_t)		inLineNumber
							func:		(char const*)	inFuncName
							level:		(LogLevel)		inLevel
							format:		(NSString*)		inFormat
							arguments:	(va_list)		inArgs;

- (void)				log:			(const char*)	inFileName
							line:		(uint32_t)		inLineNumber
							cmd:		(SEL)			inCmd
							level:		(LogLevel)		inLevel
							format:		(NSString*)		inFormat
							arguments:	(va_list)		inArgs;

- (void)				log:			(const char*)	inFileName
							line:		(uint32_t)		inLineNumber
							func:		(char const*)	inFuncName
							level:		(LogLevel)		inLevel
							format:		(NSString*)		inFormat,
							...;

- (void)				log:			(const char*)	inFileName
							line:		(uint32_t)		inLineNumber
							cmd:		(SEL)			inCmd
							level:		(LogLevel)		inLevel
							format:		(NSString*)		inFormat,
							...;

- (void)				log:			(LogLevel)		inLevel
							format:		(NSString*)		inFormat
							arguments:	(va_list)		inArgs;
						
- (void)				log: (LogLevel) inLevel
							format: (NSString*) inFormat,
							...;

//- (void)				debug: (NSString*) inFormat, ...;

@end
