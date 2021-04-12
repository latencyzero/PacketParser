/*
 *  XException.cpp
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#include "XException.h"
















XException::XException()
{
}

XException::XException(const CString& inMsg)
{
}

XException::~XException()
	throw()
{
}

void
XException::setLocation(const char* inFile, UInt32 inLine)
{
	mLocation = "File: [";
	mLocation += inFile;
	mLocation += "], Line: ";
	mLocation += inLine;
}
