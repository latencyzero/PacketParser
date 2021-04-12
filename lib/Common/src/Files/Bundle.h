/**
	Bundle.h
	SatTrackX

	Created by Roderick Mann on 11/28/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#ifndef __CBundle_h__
#define	__CBundle_h__




//
//	Mac OS Includes
//

#include <CoreFoundation/CFBundle.h>
#include <CoreFoundation/CFURL.h>





class CString;
class File;




/**
	C++ wrapper for Bundle.
*/

class
Bundle
{
public:
	/**
		Return the main bundle. Not thread safe.
	*/
	
	static Bundle*			getMainBundle();
	
	
	CFURLRef				findFile(const CString& inFileName, const CString& inType) const;
	
	
private:
	CFBundleRef				mBundleRef;
	
	
	static	Bundle*			sMainBundle;
};







#endif	//	__CBundle_h__
