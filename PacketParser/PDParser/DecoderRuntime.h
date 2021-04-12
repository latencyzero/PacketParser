//
//  DecoderRuntime.h
//  PacketParser
//
//  Created by Roderick Mann on 1/15/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __DecoderRuntime_h__
#define __DecoderRuntime_h__



namespace llvm
{
	class Module;
};

@class Field;

@class Packet;


@interface DecoderRuntime : NSObject

@property (nonatomic, strong)	NSManagedObjectContext*				moc;
@property (nonatomic, assign)	llvm::Module*						packetDecoder;


- (void)		parseData: (NSData*) inData
					completion: (void (^)()) inCompletion;

@end



struct PDBlock;
struct PDField;
struct PDPacket;

#pragma mark -
#pragma mark • C API


#ifdef __cplusplus
extern "C" {
#endif

Packet*				createPacket(DecoderRuntime* inRuntime);
Field*				createField(DecoderRuntime* inRuntime, const char* inType, const char* inName);

void				initField(PDField* inThis);

struct PDPacket;

typedef				void (*DecodePacketCompletionProc)(PDPacket* inPacket, void* inContext);
typedef				void (*DecodeFieldCompletionProc)(PDField* inField, PDPacket* inPacket);
typedef				void (*DecodeBlockCompletionProc)(PDBlock* inBlock, PDPacket* inPacket);

void				decodeField(PDField* inField,
								PDPacket* inPacket,
								DecodeFieldCompletionProc inCompletionProc,
								void* inContext);

void				decodeBlock(PDBlock* inBlock,
								PDPacket* inPacket,
								DecodeBlockCompletionProc inCompletionProc,
								void* inContext);

void				structPDBlockinit_void_structPDBlockP_u64(PDBlock* inThis, uint64_t inLength);

#ifdef __cplusplus
}
#endif

/**
	These structures have to match the layout of the stuff defined inside the
	generated packet decoding code (LLVM).
*/

struct
PDFrame
{
	uint64_t						mStart;
	uint64_t						mLength;
};

struct
PDPacket : PDFrame
{
									//	super
	DecodePacketCompletionProc		mCompletionProc;
	void*							mContext;
};

struct
PDField : PDFrame
{
									//	super
	const char*						mFieldName;
	uint8_t							mFieldType;
	
	void				decode(PDPacket* inPacket,
								DecodeFieldCompletionProc inCompletionProc,
								void* inContext);
};

struct
PDBlock : PDFrame
{
									//	super
	const char*						mBlockName;
	
	PDBlock(uint64_t inLength)
	{
		mLength = inLength;
	}
	
	void				decode(PDPacket* inPacket,
								DecodeBlockCompletionProc inCompletionProc,
								void* inContext);
};




#endif	//	__DecoderRuntime_h__
