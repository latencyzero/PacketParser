//
//  Protocol.h
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//



@class FrameField;


/**
	A Protocol defines a packet or frame. It is created by interpreting the Packet Description
	Language, or programmatically.
	
	Protocols can nest. Usually a field in a Protocol determines what, if any, nested
	Protocol can be found. The nested data, when they conform to a Protocol, are called
	Frames.
*/

@interface
FrameDescription : NSObject




@property (nonatomic, strong, readonly)	NSArray*				fields;



- (void)			appendField: (FrameField*) inField;

@end
