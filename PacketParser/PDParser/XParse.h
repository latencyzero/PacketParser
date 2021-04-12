//
//  XParse.h
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __XParse_h__
#define __XParse_h__

#import "PDToken.h"

/**
	Parser exception.
*/

class
XParse
{
public:
	XParse()
		:
		mMsg(nil)
	{
	}
	
	XParse(NSString* inMsg)
		:
		mMsg([inMsg copy])
	{
	}
	
	XParse(const char* inFile, int inLine, NSString* inMsg)
	{
		mMsg = [NSString stringWithFormat: @"%s:%d: %@", strrchr(inFile, '/') + 1, inLine, inMsg];
	}
	
	NSString*			msg()						{ return mMsg; }
	void				setMsg(NSString* inVal)		{ mMsg = [inVal copy]; }
	
private:
	NSString*			mMsg;
};



class
XUnexpected : public XParse
{
public:
	XUnexpected(const PDToken& inFoundToken, NSUInteger inExpectedType);
	XUnexpected(const PDToken& inFoundToken, NSString* inReservedWord);

private:
	PDToken				mFoundToken;
	NSUInteger			mExpectedType;
};



class
XUnknownType : public XParse
{
public:
	XUnknownType(const PDToken& inToken);
	
private:
	PDToken				mToken;
};


#endif	//	__XParse_h__
