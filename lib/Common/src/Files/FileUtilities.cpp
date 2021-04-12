/*
 *  FileUtilities.cpp
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */

#include "FileUtilities.h"

//
//	Project Includes
//

#include "CString.h"
#include "DebugMacros.h"
#include "File.h"




CString
FileUtilities::getFileText(const File& inFile)
{
	UInt8* buf = NULL;
	File& file = const_cast<File&> (inFile);
	
	try
	{
		file.open();
		
		SInt64 len = file.getLength();
		buf = new UInt8[len];
		
		UInt32 bytesRead = file.read(buf, len);
		DebugAssert_(bytesRead == len);
		
		CString text(buf, len);
		return text;
	}
	
	catch (...)
	{
		delete [] buf;
		//•••inFile.close();
		throw;
	}
}

