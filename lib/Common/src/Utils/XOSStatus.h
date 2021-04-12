/*
 *  XOSStatus.h
 *  SatTrackX
 *
 *  Created by Roderick Mann on 12/23/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#ifndef	__XOSStatus_h__
#define __XOSStatus_h__

#include "XException.h"








class
XOSStatus : public XException
{
public:
						XOSStatus(OSStatus inError)
						{
							mError = inError;
						}
						
	OSStatus			getError()					const		{ return mError; }
	void				setError(OSStatus inVal)				{ mError = inVal; }
	
private:
	OSStatus			mError;
};















#endif	//	__XResourceAllocationFailed_h__