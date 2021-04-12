//
//  FrameField.h
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//



//
//	Library Imports
//





@interface FrameField : NSObject

@property (nonatomic, copy)		NSString*				name;
@property (nonatomic, assign)	NSUInteger				size;	///< Size of this field in the data stream in octets

@end
