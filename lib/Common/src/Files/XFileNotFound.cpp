/*
 *  XFileNotFound.cpp
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#include "XFileNotFound.h"












XFileNotFound::XFileNotFound(const CString& inFileName)
{
	CString msg;
	msg += "File \"";
	msg += inFileName;
	msg += "\" not found.";
	setMessage(msg);
}
