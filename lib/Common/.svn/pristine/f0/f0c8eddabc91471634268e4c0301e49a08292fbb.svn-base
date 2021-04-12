//
//  PortParameters.h
//  IchibotConsole
//
//  Created by Roderick Mann on 9/19/08.
//  Copyright 2008 Latency: Zero. All rights reserved.
//


enum FlowControl
{
	kFlowControlNone		=	0,
	kFlowControlHardware	=	1,
	kFlowControlSoftware	=	2,
};
typedef enum FlowControl FlowControl;

enum Parity
{
	kParityNone		=	0,
	kParityOdd		=	1,
	kParityEven		=	2,
};
typedef enum Parity Parity;

/**
*/

@interface
PortParameters : NSObject<NSCoding>
{
	NSInteger				mSpeed;
	FlowControl				mFlowControl;
	NSInteger				mDataBits;
	Parity					mParity;
	NSInteger				mStopBits;
}

@property 				NSInteger			speed;
@property 				FlowControl			flowControl;
@property 				NSInteger			dataBits;
@property 				Parity				parity;
@property 				NSInteger			stopBits;

@end
