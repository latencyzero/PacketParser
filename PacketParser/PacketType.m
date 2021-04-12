//
//  PacketType.m
//  PacketParser
//
//  Created by Roderick Mann on 1/5/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PacketType.h"








@implementation PacketType

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		self.name = NSLocalizedString(@"Untitled", @"New PacketType name");
	}
	
	return self;
}

@end
