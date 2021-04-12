/**
	File.h
	SatTrackX

	Created by Roderick Mann on 11/28/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#ifndef	__File_h__
#define	__File_h__





//
//	Mac OS Includes
//

#include <CoreFoundation/CoreFoundation.h>
//#include <CoreFoundation/CFURL.h>
#include <CoreServices/CoreServices.h>
//#include <CarbonCore/Files.h>
//#include <CarbonCore/MacTypes.h>





class CString;






/**
	Fork-specific methods that do not name a particular fork apply to the data fork.
*/

class
File
{
public:
						File(CFURLRef inURL);
					
	bool				isValid() const;
	CString				getPath(CFURLPathStyle inPathStyle = kCFURLPOSIXPathStyle) const;
	
	void				open(SInt8 inPermissions = fsRdPerm, bool inCreate = false);
	
	SInt64				getLength() const;
	UInt32				read(void* outBuf, UInt32 inLength) const;
	
protected:
	void				init();
	static	void		throwFSException(OSStatus inErr, const CString& inData, const char* inFile, UInt32 inLine);
	
private:
	FSRef				mFSRef;
	bool				mIsValid;
	FSIORefNum			mForkRef;
};





#endif	//	__File_h__
