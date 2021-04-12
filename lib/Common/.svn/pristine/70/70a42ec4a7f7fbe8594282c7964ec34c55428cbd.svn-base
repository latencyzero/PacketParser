/*
 *  StSaveContext.cpp
 *  Schematic
 *
 *  Created by Roderick Mann on 8/11/08.
 *  Copyright 2008 Latency: Zero. All rights reserved.
 *
 */

#include "StSaveContext.h"

//
//	Mac OS Includes
//

#if TARGET_OS_IPHONE
#include <CoreGraphics/CoreGraphics.h>
#endif

//
//	Project Includes
//

#include "Context.h"



namespace
Graphics
{

StSaveContext::StSaveContext(Context& inCTX)
	:
	mCTX(inCTX)
{
	mCTX.saveState();
	mTextMatrix = inCTX.getTextMatrix();
}

StSaveContext::~StSaveContext()
{
	mCTX.setTextMatrix(mTextMatrix);
	mCTX.restoreState();
}


}
