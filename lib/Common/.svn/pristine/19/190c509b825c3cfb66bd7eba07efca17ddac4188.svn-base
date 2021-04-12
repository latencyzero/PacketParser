/*
 *  XException.h
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */


#ifndef	__XException_h__
#define	__XException_h__

#include <exception>


//
//	Project Includes
//

#include "CString.h"










class
XException : public std::exception
{
public:
						XException();
						XException(const CString& inMsg);
						
	virtual				~XException() throw();
	
	const CString&		getMessage()						const		{ return mMessage; }
	void				setMessage(const CString& inVal)				{ mMessage = inVal; }
	
	void				setLocation(const char* inFile, UInt32 inLine);
	
private:
	CString				mMessage;
	CString				mLocation;
};
















#endif	//	__XException_h__

