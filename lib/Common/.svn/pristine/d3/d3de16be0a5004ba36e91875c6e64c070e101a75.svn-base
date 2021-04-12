/**
	Bundle.cpp
	SatTrackX

	Created by Roderick Mann on 11/28/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#include "Bundle.h"


//
//	Mac OS Includes
//

#include <CoreFoundation/CFBundle.h>
#include <CoreFoundation/CFURL.h>



//
//	Project Includes
//

#include "XFileNotFound.h"

#include "CString.h"






Bundle*			Bundle::sMainBundle;




Bundle*
Bundle::getMainBundle()
{
	if (sMainBundle == NULL)
	{
		sMainBundle = new Bundle();
		sMainBundle->mBundleRef = ::CFBundleGetMainBundle();
	}
	
	return sMainBundle;
}





CFURLRef
Bundle::findFile(const CString& inFileName, const CString& inType) const
{
	CFStringRef f = inFileName;
	CFStringRef t = inType;
	CFURLRef url = ::CFBundleCopyResourceURL(mBundleRef, f, t, NULL);
	if (url == NULL)
	{
		throw XFileNotFound(inFileName);
	}
	
	return url;
}
