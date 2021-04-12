//
//  Document.m
//  PacketParser
//
//  Created by Roderick Mann on 12/29/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Document.h"



//
//	Project Imports
//

#import "Frame.h"
#import "Packet.h"




@interface Document()

@property (nonatomic, strong)	NSArray*			packetSort;

@end

@implementation Document

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		self.packetSort = @[ [NSSortDescriptor sortDescriptorWithKey: @"sequence" ascending: true] ];

	}
	return self;
}

- (NSString*)
windowNibName
{
	// Override returning the nib file name of the document
	// If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
	return @"Document";
}

- (void)
windowControllerDidLoadNib: (NSWindowController*) inController
{
	[super windowControllerDidLoadNib: inController];
	
	//	Create some default packet data…
	
	NSArray* packets = [Packet allInMOC: self.managedObjectContext];
	if (packets.count == 0)
	{
		NSUInteger seq = 0;
		
		CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
		Packet* p = [Packet createInMOC: self.managedObjectContext];
		p.timeStamp = @(0.0);
		p.sequence = @(seq++);
		
		Frame* f = [Frame createInMOC: self.managedObjectContext];
		f.summary = @"Packet 0 encapsulation";
		[p addFramesObject: f];
		
		Frame* f2 = [Frame createInMOC: self.managedObjectContext];
		f2.summary = @"Packet 0 subframe";
		[f addSubframe: f2];
		
		p = [Packet createInMOC: self.managedObjectContext];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		f = [Frame createInMOC: self.managedObjectContext];
		f.summary = @"Packet 1 encapsulation";
		[p addFramesObject: f];
		
		f2 = [Frame createInMOC: self.managedObjectContext];
		f2.summary = @"Packet 1 subframe";
		[f addSubframe: f2];
		
		f2 = [Frame createInMOC: self.managedObjectContext];
		f2.summary = @"Packet 1 subframe 2";
		[f addSubframe: f2];
		
#if 0
		p = [Packet createInMOC: self.managedObjectContext];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		p = [Packet createInMOC: self.managedObjectContext];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		p = [Packet createInMOC: self.managedObjectContext];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);
#endif
	}
}

+ (BOOL)
autosavesInPlace
{
	return true;
}

@end
