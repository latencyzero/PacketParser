/*
 *  File.cpp
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#include "File.h"


//
//	Standard Includes
//

#include <cstring>

//
//	Mac OS Includes
//

#include <CoreFoundation/CFURL.h>


//
//	Project Includes
//

#include "CString.h"
#include "DebugMacros.h"
#include "XFileNotFound.h"







#define	ThrowIfFSError_(inErr, inMsg)														\
	do {																					\
		if (inErr != noErr)																	\
		{																					\
			throwFSException(inErr, inMsg, __FILE__, __LINE__);								\
		}																					\
	} while (false)












static const FSRef	kZeroFSRef					=	{ 0 };




File::File(CFURLRef inURL)
{
	bool success = ::CFURLGetFSRef(inURL, &mFSRef);
	DebugAssert_(success);
	
	mIsValid = true;
}

bool
File::isValid() const
{
	return mIsValid;
}


CString
File::getPath(CFURLPathStyle inPathStyle) const
{
	DebugAssert_(isValid());
	
	CFURLRef url = ::CFURLCreateFromFSRef(kCFAllocatorDefault, &mFSRef);
	CString path = ::CFURLCopyFileSystemPath(url, inPathStyle);
	::CFRelease(url);
	
	return path;
}


void
File::open(SInt8 inPermissions, bool inCreate)
{
	DebugAssert_(isValid());
	DebugAssert_(inCreate == false);
	
	HFSUniStr255		dataForkName;
	OSStatus err = ::FSGetDataForkName(&dataForkName);
	ThrowIfFSError_(err, "FSGetDataForkName");
	
	err = ::FSOpenFork(&mFSRef, dataForkName.length, dataForkName.unicode, inPermissions, &mForkRef);
	ThrowIfFSError_(err, "FSOpenFork");
}


SInt64
File::getLength() const
{
	SInt64		length = 0;
	OSStatus err = ::FSGetForkSize(mForkRef, &length);
	
	DebugAssert_(err == noErr);
	
	return length;
}

UInt32
File::read(void* outBuf, UInt32 inLength) const
{
	UInt32 bytesRead = 0;
	OSStatus err = ::FSReadFork(mForkRef, fsAtMark, 0, inLength, outBuf, &bytesRead);
	ThrowIfFSError_(err, "FSReadFork");
	
	return bytesRead;
}


void
File::init()
{
	mForkRef = 0;
	std::memset(&mFSRef, 0, sizeof(mFSRef));
	mIsValid = false;
}


void
File::throwFSException(OSStatus inErr, const CString& inData, const char* inFile, UInt32 inLine)
{
	switch (inErr)
	{
		case fnfErr:
		{
			XFileNotFound	e(inData);
			e.setLocation(inFile, inLine);
			throw e;
		}
		
		default:
		{
			CString errCode = "FileManager Error: ";
			errCode += inErr;
			XFileNotFound	e(errCode);
			e.setLocation(inFile, inLine);
			throw e;
		}
	}
}
