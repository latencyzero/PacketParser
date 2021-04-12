//
//  DecoderRuntime.mm
//  PacketParser
//
//  Created by Roderick Mann on 1/15/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "DecoderRuntime.h"


//
//	Library Imports
//

#import "llvm/Module.h"
#import "llvm/ExecutionEngine/ExecutionEngine.h"
#import "llvm/ExecutionEngine/GenericValue.h"
#import "llvm/ExecutionEngine/JIT.h"
#import "llvm/Support/TargetSelect.h"

#import "Debug.h"
#import "NSData+LZ.h"
#import "NSString+LZ.h"

//
//	Project Imports
//

#import "Field.h"
#import "Packet.h"




@interface DecoderRuntime()
{
	std::string					mEEBuildErrors;
	NSOperationQueue*			mExecutionQueue;
	llvm::Function*				mDecodePacket;			///< The main entry point of a decoder
	
	NSUInteger					mInputIndex;			///< Input index since decoding started
	NSUInteger					mInputBufferIndex;		///< Input index of current buffer
	Packet*						mPacket;				///< The Packet currently being built
	Frame*						mFrame;					///< The Frame currently being built
	NSUInteger					mPacketNumber;
}

@property (nonatomic, assign, readonly)	llvm::ExecutionEngine*				engine;
@property (nonatomic, strong)			NSMutableData*						inputData;
@property (nonatomic, assign, readonly)	NSUInteger							remainingBytes;
@property (nonatomic, assign, readonly)	NSUInteger							currentFrameIndex;
@property (nonatomic, strong)			void								(^parseCompletion)();

@end



@implementation DecoderRuntime

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		mInputIndex = 0;
		mPacketNumber = 1;
	}
	
	return self;
}

- (void)
dealloc
{
	//[mExecutionQueue addOperationWithBlock:
	//^{
		self.engine->runStaticConstructorsDestructors(false);
	//}];
		
	//[mExecutionQueue waitUntilAllOperationsAreFinished];
	
	delete mEngine;
	mEngine = NULL;
}

- (void)
parseData: (NSData*) inData
	completion: (void (^)()) inCompletion
{
	self.parseCompletion = inCompletion;
	
	[self.inputData appendData: inData];
	[self invokeDecodePacket];
}

void
MyDecodePacketCompletionProc(PDPacket* inPacket, void* inContext)
{
	NSLogDebug(@"MyDecodePacketCompletionProc(): packet decode completed!");
	
	//	TODO: For now, we call the parse completion routine as soon as
	//			the first packet is done. But we really only do this
	//			if all the data has been parsed…
	
	DecoderRuntime* dr = (__bridge DecoderRuntime*) inContext;
	dr.parseCompletion();
}

- (void)
invokeDecodePacket
{
	void* drSelf = (__bridge void*) self;

	std::vector<llvm::GenericValue>		args;
	args.push_back(llvm::GenericValue(drSelf));
	args.push_back(llvm::PTOGV((void*) MyDecodePacketCompletionProc));
	args.push_back(llvm::PTOGV(NULL));
	
	NSLog(@"Invoking decodePacket(%p, %p, NULL)", self, MyDecodePacketCompletionProc);
	
	llvm::Function* decodePacket = self.packetDecoder->getFunction("XBeePacket.decode");	//	TODO: lookup name dynamically.
	self.engine->runFunction(decodePacket, args);
}

#pragma mark -
#pragma mark • Getting Data

/**
	Attempts to fill inBuffer with inCount bytes. Blocks if
	insufficient bytes are available. Returns false if the
	input stream has ended.
*/

- (bool)
getNext: (NSUInteger) inCount
	bytes: (void*) inBuffer
{
	NSUInteger remaining = self.inputData.length - mInputBufferIndex;
	if (remaining <= inCount)
	{
		//	Block
		//NSConditionLock
		
	}
	
	return true;
}


#pragma mark -
#pragma mark • Runtime Interface

- (Packet*)
createPacket
{
	mPacket = [Packet createInMOC: self.moc];
	mPacket.start = @(mInputIndex);
	mPacket.sequence = @(mPacketNumber++);
	
	return mPacket;
}

- (Field*)
createFieldWithType: (NSString*) inType
	name: (NSString*) inName
{
	//	Decode the type…
	
	if ([inType hasPrefix: @"u"] || [inType hasPrefix: @"s"])
	{
		NSString* widthStr = [inType substringFromIndex: 1];
		NSInteger width = widthStr.integerValue;
		NSInteger size = width / 8;
		
		NSNumber* n = nil;
		bool isUnsigned = [inType hasPrefix: @"u"];
		if (isUnsigned)
		{
			switch (size)
			{
				case sizeof(uint64_t):	n = @([self.inputData u64At: mInputIndex littleEndian: false]); break;
				case sizeof(uint32_t):	n = @([self.inputData u32At: mInputIndex littleEndian: false]); break;
				case sizeof(uint16_t):	n = @([self.inputData u16At: mInputIndex littleEndian: false]); break;
				case sizeof(uint8_t):	n = @([self.inputData u8At: mInputIndex littleEndian: false]); break;
			}
			Field* f = [Field createInMOC: self.moc];
			
			[mPacket addFrame: f];
			f.start = @(self.currentFrameIndex);
			f.length = @(size);
			mInputIndex += size;
			f.name = [NSString stringWithFormat: @"Field, unsigned, len: %ld, val: %@ (0x%llX)", size, n, n.unsignedLongLongValue];	//	TODO:
			f.summary = f.name;//	TODO!
			//f.value = TODO
		}
		else
		{
			switch (size)
			{
				case sizeof(int64_t):	n = @([self.inputData s64At: mInputIndex littleEndian: false]); break;
				case sizeof(int32_t):	n = @([self.inputData s32At: mInputIndex littleEndian: false]); break;
				case sizeof(int16_t):	n = @([self.inputData s16At: mInputIndex littleEndian: false]); break;
				case sizeof(int8_t):	n = @([self.inputData s8At: mInputIndex littleEndian: false]); break;
			}
		}
	}
	else
	{
		NSLogDebug(@"Unexpected type '%@'", inType);
		return nil;
	}
	
	Field* f = [Field createInMOC: self.moc];
	f.start = @(mInputIndex);
	f.sequence = @(mPacketNumber++);
	
	return f;
}

#pragma mark -
#pragma mark • Properties

- (llvm::ExecutionEngine*)
engine
{
	if (mEngine == NULL)
	{
		llvm::InitializeNativeTarget();
		
		llvm::EngineBuilder builder(self.packetDecoder);
		builder.setErrorStr(&mEEBuildErrors);
		
		mEngine = builder.create();
		
		if (mEngine == NULL)
		{
			NSLog(@"FAILURE ============================: %s", mEEBuildErrors.c_str());
			return NULL;
		}
		
		//[mExecutionQueue addOperationWithBlock:
		//^{
			mEngine->runStaticConstructorsDestructors(false);
		//}];
		
		//[mExecutionQueue waitUntilAllOperationsAreFinished];
	}
	
	return mEngine;
}

@synthesize engine						=	mEngine;

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

@synthesize inputData					=	mInputData;

@end





Packet*
createPacket(DecoderRuntime* inRuntime)
{
	NSLog(@"createPacket");
	Packet* p = [inRuntime createPacket];
	return p;
}

Field*
createField(DecoderRuntime* inRuntime, const char* inType, const char* inName)
{
	NSLog(@"createField(\"%s\", \"%s\")", inType, inName);
	
	NSString* type = [NSString stringWithCString: inType encoding: NSUTF8StringEncoding];
	NSString* name = [NSString stringWithCString: inName encoding: NSUTF8StringEncoding];
	
	Field* f = [inRuntime createFieldWithType: type name: name];
	return f;
}

void
decodeField(PDField* inField,
			PDPacket* inPacket,
			DecodeFieldCompletionProc inCompletionProc,
			void* inContext)
{
	inField->decode(inPacket, inCompletionProc, inContext);
}


void
PDField::decode(PDPacket* inPacket,
				DecodeFieldCompletionProc inCompletionProc,
				void* inContext)
{
	NSLog(@"decodeField(%p, %p, %p, 0x%llX)", this, inPacket, inCompletionProc, (uint64_t) inContext);
	NSLog(@"Field name: %s", mFieldName);
	NSLog(@"queue: %s", dispatch_queue_get_label(dispatch_get_current_queue()));
	
	dispatch_async(dispatch_get_current_queue(),
	^{
		NSLog(@"comp: %p", inPacket->mCompletionProc);
		inCompletionProc(this, inPacket);
	});
}

#pragma mark -
#pragma mark • PDBlock


void
PDBlock::decode(PDPacket* inPacket,
				DecodeBlockCompletionProc inCompletionProc,
				void* inContext)
{
	NSLog(@"decodeBlock(%p, %p, %p, 0x%llX)", this, inPacket, inCompletionProc, (uint64_t) inContext);
	NSLog(@"Block name: %s", mBlockName);
	
	NSLog(@"comp: %p", inPacket->mCompletionProc);
	inCompletionProc(this, inPacket);
}


void
structPDBlockinit_void_structPDBlockP_u64(PDBlock* inThis, uint64_t inLength)
{
	inThis = new (inThis) PDBlock(inLength);
}

void
decodeBlock(PDBlock* inBlock,
			PDPacket* inPacket,
			DecodeBlockCompletionProc inCompletionProc,
			void* inContext)
{
	inBlock->decode(inPacket, inCompletionProc, inContext);
}



