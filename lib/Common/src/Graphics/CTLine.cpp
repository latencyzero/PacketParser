/*
 *  CTLine.cpp
 *  Schematic
 *
 *  Created by Roderick Mann on 12/28/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#include "CTLine.h"


namespace
Graphics
{

CTLine::CTLine(NSAttributedString* inString)
{
	if (inString != NULL)
	{
		CFAttributedStringRef as = reinterpret_cast<CFAttributedStringRef> (inString);
		mLineRef = ::CTLineCreateWithAttributedString(as);
	}
}






}
