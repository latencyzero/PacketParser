/*
 *  Debug.h
 *  Schematic
 *
 *  Created by Roderick Mann on 8/5/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#ifndef	__Debug_h__
#define	__Debug_h__

#ifndef	qDebugLogging
#define qDebugLogging			0
#endif

#if	qDebugLogging > 0

#if __OBJC__

@class NSString;


void    DebugLog(const char* inFileName, uint32_t inLineNumber, NSString* inFormat, ...);

#define DebugLog_(...)									\
    do													\
	{													\
        ::DebugLog( __FILE__, __LINE__, __VA_ARGS__ );	\
    } while (false);

#endif


#else	//	qDebugLogging > 0

#define DebugLog_(...)




#endif	//	qDebugLogging > 0


/**
	Thanks to George Warner for this.
*/

#if qDebugLogging > 1

#define NSLogDebug(format, ...)									\
	NSLog(@"<%s:%d> %s: " format,								\
	strrchr("/" __FILE__, '/') + 1,								\
	__LINE__,													\
	__PRETTY_FUNCTION__,										\
	## __VA_ARGS__)

#elif qDebugLogging > 0

#define NSLogDebug(format, ...)									\
	NSLog(@"<%s:%d>: " format,								\
	strrchr("/" __FILE__, '/') + 1,								\
	__LINE__,													\
	## __VA_ARGS__)

#else

	#define NSLogDebug(format, ...)

#endif





#endif	//	__Debug_h__
