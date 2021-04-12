//
//  ParserLibraryController.m
//  PacketParser
//
//  Created by Roderick Mann on 1/5/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PacketTypesLibraryController.h"



#import "PacketType.h"
#import "PacketTypeWindowController.h"




@interface PacketTypesLibraryController ()

@property (nonatomic, strong)	IBOutlet	NSTableView*					typesList;

@property (nonatomic, strong)				NSMutableArray*					packetTypes;
@property (nonatomic, strong)				NSMapTable*						controllersByType;

@end





@implementation PacketTypesLibraryController

- (id)
init
{
	self = [super initWithWindowNibName: @"PacketTypesLibraryController"];
	if (self != nil)
	{
		self.shouldCloseDocument = false;
		self.packetTypes = [NSMutableArray array];
		self.controllersByType = [NSMapTable strongToStrongObjectsMapTable];
	}

	return self;
}


- (void)
windowDidLoad
{
	[super windowDidLoad];
}

- (void)
windowDidBecomeMain: (NSNotification*) inNotification
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud setBool: true forKey: @"PacketTypesLibraryShowing"];
}

- (void)
windowWillClose: (NSNotification*) inNotification
{
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	[ud setBool: false forKey: @"PacketTypesLibraryShowing"];
}

- (IBAction)
newParserType: (id) inSender
{
}

- (void)
editPacketType: (NSArray*) inSelectedTypes
{
	for (PacketType* pt in inSelectedTypes)
	{
		[self openEditorForType: pt];
	}
}

- (void)
openEditorForType: (PacketType*) inType
{
	PacketTypeWindowController* wc = [self.controllersByType objectForKey: inType];
	if (wc == nil)
	{
		wc = [[PacketTypeWindowController alloc] initWithPacketType: inType];
		[self.controllersByType setObject: wc forKey: inType];
	}
	
	[wc.window makeKeyAndOrderFront: nil];
}


@end
