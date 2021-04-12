//
//  Document.m
//  PacketParser
//
//  Created by Roderick Mann on 12/29/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Document.h"


//
//	Library Imports
//

#import "Debug.h"
#import "NSData+LZ.h"

//
//	Project Imports
//

#import "Disassembler.h"
#import "Frame.h"
#import "Packet.h"
#import "ParserByteCode.h"
#import "Parser.h"

#import <Accelerate/Accelerate.h>


@interface Document()

@property (nonatomic, strong)	IBOutlet NSTextView*		rawBytesView;
@property (nonatomic, strong)	IBOutlet NSTextView*		rawGlyphView;
@property (nonatomic, strong)	IBOutlet NSArrayController*	packetsArrayController;
@property (nonatomic, strong)	IBOutlet NSTreeController*	framesTreeController;

@property (nonatomic, strong)	NSArray*					packetSort;
@property (nonatomic, strong)	NSArray*					fieldSort;
@property (nonatomic, strong)	Packet*						packetToDisplayBytes;
@property (nonatomic, strong)	NSMutableData*				inputData;
@property (nonatomic, strong)	NSData*						frameData;

@end

@implementation Document

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		self.packetSort = @[ [NSSortDescriptor sortDescriptorWithKey: @"sequence" ascending: true] ];
		self.fieldSort = @[ [NSSortDescriptor sortDescriptorWithKey: @"sequence" ascending: true] ];

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
	
	//	Initialize the views…
	
	//	Set the font on the raw bytes text view, the setting in IB is ignored…
	
	self.rawBytesView.font = [NSFont fontWithName: @"Menlo" size: 13.0];
	self.rawGlyphView.font = [NSFont fontWithName: @"Menlo" size: 13.0];
	
	//	Set up the view so that it doesn't wrap lines…
	
	self.rawBytesView.textContainer.widthTracksTextView = false;
	self.rawGlyphView.textContainer.widthTracksTextView = false;
	
	//	Bind the selected packet to our raw bytes display…
	
	//[self bind: @"packetToDisplayBytes" toObject: self.packetsArrayController withKeyPath: @"selection" options: nil];
	
	//	TODO: Binding isn't working, try KVO…
	
	[self.packetsArrayController addObserver: self
						forKeyPath: @"selection"
						options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
						context: NULL];

	[self.framesTreeController addObserver: self
						forKeyPath: @"selection"
						options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
						context: NULL];

	//	Create some default packet data…
	
	NSManagedObjectContext* moc = self.managedObjectContext;
#if 0
	NSArray* packets = [Packet allInMOC: moc];
	if (packets.count == 0)
	{
		NSUInteger seq = 0;
		
		CFAbsoluteTime now = CFAbsoluteTimeGetCurrent();
		Packet* p = [Packet createInMOC: moc];
		p.timeStamp = @(0.0);
		p.sequence = @(seq++);
		
		Frame* f = [Frame createInMOC: moc];
		f.summary = @"Packet 0 encapsulation";
		[p addFrame: f];
		
		Frame* f2 = [Frame createInMOC: moc];
		f2.summary = @"Packet 0 subframe";
		[f addFrame: f2];
		
		p = [Packet createInMOC: moc];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		f = [Frame createInMOC: moc];
		f.summary = @"Packet 1 encapsulation";
		[p addFrame: f];
		
		f2 = [Frame createInMOC: moc];
		f2.summary = @"Packet 1 subframe";
		[f addFrame: f2];
		
		f2 = [Frame createInMOC: moc];
		f2.summary = @"Packet 1 subframe 2";
		[f addFrame: f2];
		
#if 0
		p = [Packet createInMOC: moc];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		p = [Packet createInMOC: moc];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);

		p = [Packet createInMOC: moc];
		p.timeStamp = @(CFAbsoluteTimeGetCurrent() - now);
		p.sequence = @(seq++);
#endif
	}
#endif

	[self testParser];
	
	[moc processPendingChanges];
	[moc.undoManager removeAllActions];
	[self updateChangeCount: NSChangeCleared];
}

- (void)
testParser
{
	//	Create a test program for the parser…
	
	NSMutableArray* program = [NSMutableArray array];
	 
	[program addObject: @(makeByteMarkerInstruction(0x7e))];
	
	NSUInteger addr = program.count;
	[program addObject: @(makeU16FieldInstruction(r2))];				//	payload length
	
	appendStringInstruction(program, @"length");
	int32_t offset = (int32_t) (addr - program.count);
	[program addObject: @(makeFrameNameInstruction(offset,offset+1))];
	
	NSUInteger callInstAddr = program.count;
	[program addObject: @(makeCallInstruction(0))];						//	Placeholder for call instruction
	[program addObject: @(makeU8FieldInstruction())];					//	Checksum byte

	[program addObject: @(makeHaltInstruction())];						//	Stop executing
	
	offset = (int32_t) (program.count - callInstAddr);					//	Not likely to overflow
	[program replaceObjectAtIndex: callInstAddr withObject: @(makeCallInstruction(offset))];
	
	[program addObject: @(makeU8FieldInstruction())];					//	API ID byte
	[program addObject: @(makeLoadImmediateInstruction(r3, 1))];		//	payload size…
	[program addObject: @(makeSubUnsignedInstruction(r2, r2, r3))];		//	minus length byte
	[program addObject: @(makeBlockInstruction(r2))];
	[program addObject: @(makeReturnInstruction())];
	
	
	//	Disassemble our program for yucks…
	
	Disassembler* dis = [[Disassembler alloc] init];
	dis.program = program;
	[dis dumpProgram];
	
	//	Create the parser and load some test data…
	
	Parser* p = [[Parser alloc] init];
	p.moc = self.managedObjectContext;
	p.program = program;
	
	NSURL* url = [[NSBundle mainBundle] URLForResource: @"ZigBee031832" withExtension: @"bin"];
	NSError* err = nil;
	NSData* inputData = [NSData dataWithContentsOfURL: url options: 0 error: &err];
	if (inputData == nil)
	{
		NSLogDebug(@"Error reading test data %@: %@", url.path, err);
	}
	self.inputData = [inputData mutableCopy];
	
	[p parseData: inputData];
	//NSLogDebug(@"Finished test parse");
	
	[self.rawBytesView setString: @"Now is the time to add some text"];
}


+ (BOOL)
autosavesInPlace
{
	return true;
}

- (void)
observeValueForKeyPath: (NSString*) inKeyPath
	ofObject: (id) inObject
	change: (NSDictionary*) inChange
	context: (void*) inContext
{
	if ([inKeyPath isEqualToString: @"selection"])
	{
		if (inObject == self.packetsArrayController)
		{
			NSArrayController* ac = inObject;
			if (ac.selectedObjects.count > 0)
			{
				Packet* p = [ac.selectedObjects objectAtIndex: 0];
				self.packetToDisplayBytes = p;
			}
			else
			{
				self.packetToDisplayBytes = nil;
			}
		}
		else if (inObject == self.framesTreeController)
		{
			NSTreeController* tc = inObject;
			if (tc.selectedObjects.count > 0)
			{
				Frame* p = [tc.selectedObjects objectAtIndex: 0];
				//self.packetToDisplayBytes = p;
				//NSLogDebug(@"Range: %@, %@", p.start, p.length);
				NSUInteger start = 3 * p.start.unsignedLongLongValue;
				NSUInteger length = 3 * p.length.unsignedLongLongValue - 1;
				NSRange r = NSMakeRange(start, length);
				//[self.rawBytesView setSelectedRange: r];
				NSColor* calloutOtherColor = [NSColor lightGrayColor];
				NSColor* calloutColor = [NSColor blackColor];
				[self.rawBytesView setTextColor: calloutOtherColor];
				[self.rawBytesView setTextColor: calloutColor range: r];
				
				start = 2 * p.start.unsignedLongLongValue;
				length = 2 * p.length.unsignedLongLongValue - 1;
				r = NSMakeRange(start, length);
				//[self.rawGlyphView setSelectedRange: r];
				[self.rawGlyphView setTextColor: calloutOtherColor];
				[self.rawGlyphView setTextColor: calloutColor range: r];
			}
			else
			{
				//self.packetToDisplayBytes = nil;
			}
		}
	}
	else
	{
		[super observeValueForKeyPath: inKeyPath ofObject: inObject change: inChange context: inContext];
	}
}


#pragma mark -
#pragma mark • Properties

- (void)
setPacketToDisplayBytes: (Packet*) inPacketToDisplayBytes
{
	if (inPacketToDisplayBytes == mPacketToDisplayBytes)
	{
		return;
	}
	
	if (self.inputData.length > 0)		//	TODO: update display when either selected packet or input data changes?
	{
		mPacketToDisplayBytes = inPacketToDisplayBytes;
		
		NSRange r = NSMakeRange(self.packetToDisplayBytes.start.unsignedLongLongValue, self.packetToDisplayBytes.length.unsignedLongLongValue);
		self.frameData = [self.inputData subdataWithRange: r];
		//NSLogDebug(@"packet data:\n%@", [self.frameData hexCharString]);
		
		NSMutableString* s = [NSMutableString string];
		NSMutableString* glyph = [NSMutableString string];
		for (NSUInteger i = 0; i < self.frameData.length; ++i)
		{
			r = NSMakeRange(i, 1);
			uint8_t b;
			[self.frameData getBytes: &b range: r];
			[s appendFormat: @"%02X ", b];
			
			if (b < ' ' || b > '~')		//	Unprintables get a dot
			{
				[glyph appendFormat: @"• "];
			}
			else					//	Everything else is ASCII
			{
				[glyph appendFormat: @"%c ", b];
			}
			
			if (i > 0 && (i+1) % 16 == 0)
			{
				[s replaceCharactersInRange: NSMakeRange(s.length - 1, 1) withString: @"\n"];
				[glyph replaceCharactersInRange: NSMakeRange(glyph.length - 1, 1) withString: @"\n"];
			}
		}

		self.rawBytesView.string = s;
		self.rawGlyphView.string = glyph;
	}
}

@synthesize packetToDisplayBytes					=	mPacketToDisplayBytes;

@end

@interface SyncScrollView : NSScrollView

@property (nonatomic, strong)	IBOutlet	NSView*		otherView;

@end

@implementation SyncScrollView

- (void)
reflectScrolledClipView: (NSClipView*) inClipView
{
	[super reflectScrolledClipView: inClipView];
	[self.otherView scrollRectToVisible: inClipView.documentVisibleRect];
}

@end


