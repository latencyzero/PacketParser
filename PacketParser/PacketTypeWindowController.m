//
//  ParserDefControllerWindowController.m
//  PacketParser
//
//  Created by Roderick Mann on 1/5/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PacketTypeWindowController.h"


//
//	Library Imports
//


//
//	Project Imports
//

#import "PacketType.h"




@interface PacketTypeWindowController ()

@property (nonatomic, strong) IBOutlet NSTextView*			sourceView;

@end








@implementation PacketTypeWindowController

- (id)
initWithPacketType: (PacketType*) inPacketType
{
	self = [super initWithWindowNibName: @"PacketTypeWindowController"];
	if (self != nil)
	{
		self.packetType = inPacketType;
		self.windowFrameAutosaveName = self.packetType.name;
	}

	return self;
}

- (void)
windowDidLoad
{
	[super windowDidLoad];
}

- (void)
textDidChange: (NSNotification*) inNotification
{
	self.window.documentEdited = true;
}

- (IBAction)
compile: (id) inSender
{
}

@end
