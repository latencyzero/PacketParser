/*
 *  CString.h
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/22/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */


#ifndef	__CString_h__
#define	__CString_h__



//
//	Standard Includes
//

#include <vector>


//
//	Mac OS Includes
//

#include <CoreServices/CoreServices.h>
//#include <CarbonCore/MacTypes.h>
#include <CoreFoundation/CoreFoundation.h>
//#include <CoreFoundation/CFBase.h>
//#include <CoreFoundation/CFString.h>


//
//	Project Includes
//

#include "Debug.h"






class
CString
{
public:
	typedef	std::vector<CString>					VectorT;

	
	/**
		No-argument constructor makes an empty CFString.
	*/
	
							CString();
	
	/**
		Initialize from another CString.
	*/
	
							CString(const CString& inString);
	CString&				operator=(const CString& inString);
	
	/**
		Initialize from a CFStringRef (or CFMutableStringRef).
	*/
	
							CString(CFStringRef inString);
	CString&				operator=(CFStringRef inString);
	

	/**
		Initialize from a CFStringRef (or CFMutableStringRef).
	*/
	
							CString(const UInt8* inData, UInt32 inLength, CFStringEncoding inEncoding = kCFStringEncodingUTF8);
	
	CString(const char* inCString, CFStringEncoding inEncoding = kCFStringEncodingUTF8);
							
							operator CFStringRef() const				{ return mStringRef; }
	
	
	~CString();
	
	/**
		Create a CString witih a printf-style format specifier and
		variadic arguments.
	*/
	
	static	CString			createWithFormat(const CString& inFormat, ...);
	void					format(const CString& inFormat, ...);
	
	
	const char*				getAsCString() const;
	
	operator const char*() const
	{
		return getAsCString();
	}
	
	
	bool					operator==(const CString& inRHS);
	
	/**
		Append
	*/
	
	CString&				operator+=(const CString& inString);
	CString&				operator+=(CFStringRef inString);
	CString&				operator+=(const char* inString);
	
	CString&				operator+=(UInt32 inVal);
	
	
	
	
	UInt32					getSize() const;
	
	VectorT					split(const CString& inDelimiters) const;
	CString&				trim();
	
	bool					startsWith(const CString& inStr, CFOptionFlags inOptions = 0) const;
	
private:
	CFMutableStringRef		mStringRef;
	mutable UInt8*			mData;
};




#endif	//	__CString_h__
