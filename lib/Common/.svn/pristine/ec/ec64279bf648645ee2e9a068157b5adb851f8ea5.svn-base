/*
 *  CString.cpp
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/22/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#include "CString.h"



//
//	Standard Includes
//

#include <cstdio>

//
//	Mac OS Includes
//

#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>


//
//	Project Includes
//

#include "DebugMacros.h"





#define	CheckNull_(x)																			\
	do {																						\
		if ((x) == NULL) {																		\
			std::fprintf(stderr, "Couldn't create CF thing %s %lu\n", __FILE__, __LINE__);		\
		}																						\
	} while (false)






#pragma mark -
#pragma mark • Constructors/Initializers
#pragma mark -



/**
*/

			
CString::CString()
	:
	mStringRef(NULL),
	mData(NULL)
{
	mStringRef = ::CFStringCreateMutable(kCFAllocatorDefault, 0);
	
	//	Avoiding creating an exception here, since many of the exception
	//	classes use CString…
	
	CheckNull_(mStringRef);
}

/**
	Initialize from another CString.
*/

CString::CString(const CString& inString)
	:
	mData(NULL)
{
	*this = inString.mStringRef;
}
	
CString&
CString::operator=(const CString& inString)
{
	delete [] mData;
	*this = inString.mStringRef;
	return *this;
}


/**
	Initialize from a CFStringRef (or CFMutableStringRef).
*/

CString::CString(CFStringRef inString)
	:
	mData(NULL)
{
	*this = inString;
}

CString&
CString::operator=(CFStringRef inString)
{
	delete [] mData;
	mStringRef = ::CFStringCreateMutableCopy(kCFAllocatorDefault, 0, inString);
	CheckNull_(mStringRef);
	return *this;
}

CString::CString(const UInt8* inData, UInt32 inLength, CFStringEncoding inEncoding)
	:
	mData(NULL)
{
	CFStringRef str = ::CFStringCreateWithBytes(kCFAllocatorDefault,
												inData,
												inLength,
												inEncoding,
												false);
	CheckNull_(str);
	*this = str;
}


CString::CString(const char* inCString, CFStringEncoding inEncoding)
	:
	mStringRef(NULL),
	mData(NULL)
{
	CFStringRef str = ::CFStringCreateWithCString(kCFAllocatorDefault,
															inCString,
															inEncoding);
	
	//	Avoiding creating an exception here, since many of the exception
	//	classes use CString…
	
	CheckNull_(str);
	
	*this = str;		//	Calls operator=()
	
	::CFRelease(str);
}
							
/**
*/

CString::~CString()
{
	if (mStringRef != NULL)
	{
		::CFRelease(mStringRef);
	}
	
	delete [] mData;
}


/**
	Create a CString witih a printf-style format specifier and
	variadic arguments.
*/

CString
CString::createWithFormat(const CString& inFormat, ...)
{
	va_list	argList;
	va_start(argList, inFormat);
	CFStringRef resultString = ::CFStringCreateWithFormatAndArguments(kCFAllocatorDefault,
																		NULL,
																		inFormat,
																		argList);
	
	//	Avoiding creating an exception here, since many of the exception
	//	classes use CString…
	
	CheckNull_(resultString);
	
	return resultString;
}

void
CString::format(const CString& inFormat, ...)
{
	va_list	argList;
	va_start(argList, inFormat);
	CFStringRef resultString = ::CFStringCreateWithFormatAndArguments(kCFAllocatorDefault,
																		NULL,
																		inFormat,
																		argList);
	
	//	Avoiding creating an exception here, since many of the exception
	//	classes use CString…
	
	CheckNull_(resultString);
	
	*this = resultString;
	
	::CFRelease(resultString);
}


const char*
CString::getAsCString() const
{
	const char* data = ::CFStringGetCStringPtr(mStringRef, kCFStringEncodingUTF8);
	
	//	If ::CFStringGetCStringPtr() fails, do it another way…
	
	if (data == NULL)
	{
		CFRange fullRange = { 0, getSize() };
		SInt32 size = 0;
		::CFStringGetBytes(mStringRef, fullRange, kCFStringEncodingUTF8, '?', false, NULL, 0, &size);
		size += 1;								//	Make room for trailing null.
		mData = new UInt8[size];
		::CFStringGetBytes(mStringRef, fullRange, kCFStringEncodingUTF8, '?', false, mData, size, &size);
		mData[size] = 0;						//	Append trailing null
		data = reinterpret_cast<const char*> (mData);
	}
	
	return data;
}
	


bool
CString::operator==(const CString& inRHS)
{
	return false;
}


#pragma mark -
#pragma mark • Append Methods
#pragma mark -

/**
	Append
*/

CString&
CString::operator+=(const CString& inString)
{
	*this = inString.mStringRef;		//	Calls operator=()
	return *this;
}

CString&
CString::operator+=(CFStringRef inString)
{
	DebugAssert_(mStringRef != NULL);
	
	::CFStringAppend(mStringRef, inString);
	return *this;
}

CString&
CString::operator+=(UInt32 inVal)
{
	DebugAssert_(mStringRef != NULL);
	
	::CFStringAppendFormat(mStringRef, NULL, CFSTR("%lu"), inVal);
	return *this;
}

CString&
CString::operator+=(const char* inString)
{
	DebugAssert_(mStringRef != NULL);
	
	::CFStringAppendCString(mStringRef, inString, kCFStringEncodingUTF8);
	return *this;
}



CString::VectorT
CString::split(const CString& inDelimiters) const
{
	CFArrayRef strings = ::CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,
																	mStringRef,
																	inDelimiters);
	DebugAssert_(strings != NULL);
	//	Iterate over the CFArray, create a CString for each
	//	CFStringRef in the array, and add them to the vector…
	
	CString::VectorT	results;
	CFIndex arrayLen = ::CFArrayGetCount(strings);
	for (CFIndex i = 0; i < arrayLen; i++)
	{
		CFStringRef cfString = reinterpret_cast<CFStringRef> (::CFArrayGetValueAtIndex(strings, i));
		if (::CFStringGetLength(cfString) > 0)
		{
			results.push_back(cfString);
		}
	}
	
	::CFRelease(strings);
	
	return results;
}


CString&
CString::trim()
{
	::CFStringTrimWhitespace(mStringRef);
	return *this;
}


UInt32
CString::getSize() const
{
	DebugAssert_(mStringRef != NULL);
	
	return ::CFStringGetLength(mStringRef);
}


bool
CString::startsWith(const CString& inStr, CFOptionFlags inOptions) const
{
	inOptions |= kCFCompareAnchored;
	CFRange r = ::CFStringFind(mStringRef, inStr, inOptions);
	
	return r.location == 0 && r.length > 0;
}

