//
//  ParserDefControllerWindowController.h
//  PacketParser
//
//  Created by Roderick Mann on 1/5/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//




@class PacketType;





@interface PacketTypeWindowController : NSWindowController<NSTextViewDelegate>

@property (nonatomic, strong)	PacketType*						packetType;


- (id)			initWithPacketType: (PacketType*) inPacketType;

@end
