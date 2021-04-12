/**
	GraphicsUtils.h
	SatTrackX

	Created by Roderick Mann on 12/4/07.
	Copyright 2007 Latency: Zero. All rights reserved.
*/

#ifndef	__GraphicsUtils_h__
#define __GraphicsUtils_h__




//
//	Project Includes
//

#include "Context.h"



class CString;




namespace
Graphics
{


/**
	Save the CG context, and automatically restore it when exiting scope
*/

class
StSaveCGContext
{
public:
	StSaveCGContext(Context& inCTX)
		:
		mCTX(inCTX)
	{
		mCTX.saveState();
	}
	
	~StSaveCGContext()
	{
		mCTX.restoreState();
	}
				
private:
	Context&	mCTX;
};


/*

CGFloat			GetTextDimensions(const CString&			inText,
								  CGSize&					inSize,
								  const HIThemeTextInfo&	inInfo,
								  bool*						outTruncated = NULL);

*/

}	//	namespace Graphics










#endif	//	__GraphicsUtils_h__
