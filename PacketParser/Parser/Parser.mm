//
//  Parser.m
//  PacketParser
//
//  Created by Roderick Mann on 12/30/12.
//  Copyright (c) 2012 Latency: Zero. All rights reserved.
//

#import "Parser.h"

//
//	Library Imports
//

#import "Debug.h"
#import "NSData+LZ.h"
#import "NSString+LZ.h"

//
//	Project Imports
//

#import "Field.h"
#import "Frame.h"
#import "ParserByteCode.h"
#import "ParserByteCodeDecodeUtils.h"
#import "Packet.h"






@interface Parser()
{
	NSMutableArray*			mFrames;
	NSUInteger				mInputIndex;
	Packet*					mPacket;				///< The Packet currently being built
	Frame*					mFrame;					///< The Frame currently being built
	NSUInteger				mPacketNumber;
	
	NSMutableDictionary*	mThingsByPC;
}

@property (nonatomic, strong)			NSMutableData*	inputData;
@property (nonatomic, assign, readonly)	NSUInteger		remainingBytes;
@property (nonatomic, assign, readonly)	NSUInteger		currentFrameIndex;

@end



@implementation Parser

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		[self resetParser];
	}
	
	return self;
}

- (void)
resetParser
{
	[super reset];
	mFrames = [NSMutableArray array];
	mInputIndex = 0;
	mPacketNumber = 1;
	mThingsByPC = [NSMutableDictionary dictionary];
}

/**
	TODO: Return error.
*/

- (void)
parseData: (NSData*) inData
{
	[self.inputData appendData: inData];
	
	//	Start the parse…
	
	while (true)
	{
		mPacket = [Packet createInMOC: self.moc];
		mPacket.start = @(mInputIndex);
		mPacket.sequence = @(mPacketNumber++);
		
		HaltReason r = [self execute];
		if (r == kHaltReasonInputEnd)
		{
			NSLogDebug(@"End of input, halting");
			break;
		}
		else if (r == kHaltReasonHalt)
		{
			//	End of program, we have a packet…
			
			mPacket.complete = @true;
			mPacket.length = @(mInputIndex - mPacket.start.unsignedLongLongValue);
			
			//	Start over…
			
			self.pc = 0;
		}
		else if (r == kHaltReasonUnknownOpCode)
		{
			NSLogDebug("Unknown opcode, aborting");
			return;
		}
	}
}

- (void)
execMarker: (NSData*) inPreamble
{
	//	Find the marker in the data…
	
	NSRange rangeToSearch = NSMakeRange(mInputIndex, self.remainingBytes);
	NSRange r = [self.inputData rangeOfData: inPreamble options: 0 range: rangeToSearch];
	if (r.location != NSNotFound)
	{
		Field* f = [Field createInMOC: self.moc];
		[mThingsByPC setObject: f forKey: @(self.pc)];
		
		f.start = @(self.currentFrameIndex);
		f.length = @(r.length);
		
		r.length = 1;
		uint8_t b;
		[self.inputData getBytes: &b range: r];
		
		f.name = [NSString stringWithFormat: @"Marker len %lu: 0x%02X", r.length, b];		//TODO!
		f.summary = f.name;//	TODO!
		//f.value = TODO!
		[mPacket addFrame: f];
		mInputIndex += r.length;
		return;
	}
	
	//	TODO: The marker was not found. How we deal with this depends on the
	//	kind of data we're parsing. If it's a fixed block of data (say, a
	//	raw file we imported), then we must give up. But if it's a stream
	//	(say, a serial port or ethernet interface), then we just wait for
	//	more bytes.
	//
	//	Note that this means we need to support incremental parsing.
}

- (void)
execFieldType: (uint8_t) inType
	size: (uint8_t) inSize
	reg: (uint8_t) inTargetRegIdx
{
	//	Ensure we have enough bytes to process this field…
	
	if (self.remainingBytes < inSize)
	{
		self.haltReason = kHaltReasonInputEnd;
		return;
	}
	
	NSNumber* n = nil;
	switch (inType)
	{
		case kFieldTypeIntegerUnsigned:
		{
			switch (inSize)
			{
				case sizeof(uint64_t):	n = @([self.inputData u64At: mInputIndex littleEndian: false]); break;
				case sizeof(uint32_t):	n = @([self.inputData u32At: mInputIndex littleEndian: false]); break;
				case sizeof(uint16_t):	n = @([self.inputData u16At: mInputIndex littleEndian: false]); break;
				case sizeof(uint8_t):	n = @([self.inputData u8At: mInputIndex littleEndian: false]); break;
			}
			Field* f = [Field createInMOC: self.moc];
			[mThingsByPC setObject: f forKey: @(self.pc)];
			
			[mPacket addFrame: f];
			f.start = @(self.currentFrameIndex);
			f.length = @(inSize);
			mInputIndex += inSize;
			f.name = [NSString stringWithFormat: @"Field, unsigned, len: %u, val: %@ (0x%llX)", inSize, n, n.unsignedLongLongValue];	//	TODO:
			f.summary = f.name;//	TODO!
			//f.value = TODO
			
			if (inTargetRegIdx >= kFirstGeneralPurposeRegisterIdx)
			{
				Register v = n.unsignedIntValue;		//	TODO: better way to keep this in sync with changes to Regsiter type?
				[self loadRegister: inTargetRegIdx withValue: v];
			}
			break;
		}
		
		case kFieldTypeIntegerSigned:
		{
			switch (inSize)
			{
				case sizeof(int64_t):	n = @([self.inputData s64At: mInputIndex littleEndian: false]); break;
				case sizeof(int32_t):	n = @([self.inputData s32At: mInputIndex littleEndian: false]); break;
				case sizeof(int16_t):	n = @([self.inputData s16At: mInputIndex littleEndian: false]); break;
				case sizeof(int8_t):	n = @([self.inputData s8At: mInputIndex littleEndian: false]); break;
			}
			break;
		}
	}
}

- (void)
execBlock: (Register) inLength
{
	Field* f = [Field createInMOC: self.moc];
	[mPacket addFrame: f];
	f.start = @(self.currentFrameIndex);
	f.length = @(inLength);
	f.name = [NSString stringWithFormat: @"Block, start %@, len %@", f.start, f.length];	//	TODO
	f.summary = f.name;//	TODO!
	//f.value = TODO
	mInputIndex += inLength;

	//	TODO: if parsing this block leads us past the end of the currently-available input,
	//			we should deal with it by aborting the execution of this instruction,
	//			returning the parser state to what it was at the start of this instruction,
	//			and wait for more data to arrive.
}

- (void)
execLoadCurrentFrameIndex: (uint8_t) inTargetRegIdx
{
	Register idx = (Register) self.currentFrameIndex;		//	TODO: Handle loss of precision here. 64-bit reg?
	[self loadRegister: inTargetRegIdx withValue: idx];
}

- (void)
execLoadImmediate: (uint8_t) inRegIdx
	value: (uint16_t) inVal
{
	[self loadRegister: inRegIdx withValue: inVal];
}


- (void)
execFrame: (int16_t) inFrameOffset
	name: (int16_t) inStringOffset
{
	//	Find the string pointed to…
	
	NSUInteger so = self.pc + inStringOffset;
	NSString* s = [mThingsByPC objectForKey: @(so)];
	
	//	Find the Frame pointed to…
	
	NSUInteger fo = self.pc + inFrameOffset;
	Frame* f = [mThingsByPC objectForKey: @(fo)];
	f.name = s;
}

- (void)
execString: (NSString*) inString
	words: (Register) inNumWords
{
	[mThingsByPC setObject: inString forKey: @(self.pc)];
	self.pc += inNumWords;
}

- (void)
execCall: (int32_t) inOffset
{
	[self execPush: pc];
	[self execPush: sp];
	
	self.pc += inOffset - 1;		//	-1 because the dispatch loop will increment the pc.
}

- (void)
execReturn
{
	[self execPop: sp];
	[self execPop: pc];
}

- (void)
execPush: (uint8_t) inRegIdx
{
	Register v = [self registerValue: inRegIdx];
	[self push: v];
}

- (void)
execPop: (uint8_t) inRegIdx
{
	Register v = [self pop];
	[self loadSpecialRegister: inRegIdx withValue: v];
}



#pragma mark -
#pragma mark • Properties

- (NSUInteger)
remainingBytes
{
	return self.inputData.length - mInputIndex;
}

- (NSUInteger)
currentFrameIndex
{
	return mInputIndex - mPacket.start.unsignedLongLongValue;
}

- (NSMutableData*)
inputData
{
	if (mInputData == nil)
	{
		mInputData = [NSMutableData data];
	}
	
	return mInputData;
}

@synthesize inputData				=	mInputData;

@end
