/*
 *  Debug.cpp
 *  Schematic
 *
 *  Created by Roderick Mann on 8/5/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#include "Debug.h"

//
//	Standard Includes
//

#include <cstdarg>
#include <sys/types.h>





#if qDebugLogging > 0

void
DebugLog(const char* inFileName, u_int32_t inLineNumber, NSString* inFormat, ...)
{
	va_list		args;
	va_start(args, inFormat);
	
	//	Process the filename to get rid of any path that might be attached (Xcode
	//	like full path names, and doesn't even normalize them)…
	
	NSString* fileName = [[NSString stringWithCString: inFileName encoding: NSUTF8StringEncoding] lastPathComponent];
	
	//	Render the log message…
	
	NSString* s = [NSString stringWithFormat: @"(%@, %u): %@\n", fileName, inLineNumber, inFormat];
	::NSLogv(s, args);

	va_end(args);
}


#endif
