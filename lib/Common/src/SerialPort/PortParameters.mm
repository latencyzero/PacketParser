//
//  PortParameters.mm
//  IchibotConsole
//
//  Created by Roderick Mann on 9/19/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//

#import "PortParameters.h"


@implementation PortParameters

@synthesize	speed = mSpeed;
@synthesize	flowControl = mFlowControl;
@synthesize	dataBits = mDataBits;
@synthesize	parity = mParity;
@synthesize	stopBits = mStopBits;

- (id)
init
{
	self = [super init];
	if (self)
	{
		mStopBits = 1;
		mParity = kParityNone;
		mDataBits = 8;
		mFlowControl = kFlowControlNone;
		mSpeed = 115200;
	}
	return self;
}

- (id)
initWithCoder: (NSCoder*) inCoder
{
	self = [super init];
	if (self)
	{
		mStopBits = [inCoder decodeInt32ForKey: @"stopBits"];
		mParity = (Parity) [inCoder decodeInt32ForKey: @"parity"];
		mDataBits = [inCoder decodeInt32ForKey: @"dataBits"];
		mFlowControl = (FlowControl) [inCoder decodeInt32ForKey: @"flowControl"];
		mSpeed = [inCoder decodeInt32ForKey: @"speed"];
	}
	return self;
}

- (void)
encodeWithCoder: (NSCoder*) inCoder
{
	[inCoder encodeInteger: mSpeed forKey: @"speed"];
	[inCoder encodeInteger: mFlowControl forKey: @"flowControl"];
	[inCoder encodeInteger: mDataBits forKey: @"dataBits"];
	[inCoder encodeInteger: mParity forKey: @"parity"];
	[inCoder encodeInteger: mStopBits forKey: @"stopBits"];
}

- (void)
setValue: (id) inValue forKey: (id) inKey
{
	[super setValue: inValue forKey: inKey];
	NSLog(@"Setting value %@ on %@ for key %@", inValue, self, inKey);
}

- (NSString*)
description
{
	char const* parity = "?";
	switch (mParity)
	{
		case kParityNone:	parity = "N";		break;
		case kParityOdd:	parity = "O";		break;
		case kParityEven:	parity = "E";		break;
		default:			parity = "?";
	}
	
	char const* flowControl = "?";
	switch (mParity)
	{
		case kFlowControlNone:		flowControl = "no flow control";	break;
		case kFlowControlHardware:	flowControl = "RTS/CTS";			break;
		case kFlowControlSoftware:	flowControl = "XOn/XOff";			break;
		default:					flowControl = "?";
	}
	
	return [NSString stringWithFormat: @"%lu bps, %lu%s%lu, %s",
			mSpeed,
			mDataBits,
			parity,
			mStopBits,
			flowControl];
			
}

@end
