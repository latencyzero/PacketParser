//
//  Interpreter.h
//  PacketParser
//
//  Created by Roderick Mann on 1/2/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//



//
//	Project Imports
//

#import "ParserByteCode.h"



enum
HaltReason
{
	kHaltReasonRunning			=	0,
	kHaltReasonReset			=	1,
	kHaltReasonHalt				=	2,
	kHaltReasonProgramEnd		=	3,
	kHaltReasonInputEnd			=	4,
	kHaltReasonUnknownOpCode	=	5,
};

/**
	Base class for Parser and Disassembler, knows how to decode instructions.
*/

@interface Interpreter : NSObject

@property (nonatomic, copy)		NSArray*			program;
@property (nonatomic, assign)	Register			pc;
@property (nonatomic, assign)	HaltReason			haltReason;


/**
	Resets the interpreter to the start of the program, sets all registers to 0.
*/

- (void)				reset;

/**
	Loops over the program fetching, decoding and executing instructions. Subclasses
	implement the various -execXXX methods to implement behavior. Many instructions
	are fully implemented by this class, if they only affect the state of the interpreter
	(e.g. mov, sub, cmp, jump, halt).
*/

- (HaltReason)			execute;

- (ParserInstruction)	fetch;
- (ParserInstruction)	fetchFrom: (Register) inPC;

- (void)				push: (Register) inVal;
- (Register)			pop;

- (bool)				decodeAndDispatch: (ParserInstruction) inInst;

- (void)				loadRegister: (uint8_t) inRegIdx
							withValue: (Register) inVal;
- (void)				loadSpecialRegister: (uint8_t) inRegIdx
							withValue: (Register) inVal;
- (Register)			registerValue: (uint8_t) inRegIdx;

- (void)				execMarker: (NSData*) inPreamble;
- (void)				execFieldType: (uint8_t) inType
							size: (uint8_t) inSize
							reg: (uint8_t) inTargetRegIdx;
- (void)				execBlock: (Register) inLength;
- (void)				execLoadCurrentFrameIndex: (uint8_t) inTargetRegIdx;

@end




/**
	Register names.
*/

const uint8_t	pc											=	0;
const uint8_t	sp											=	1;
const uint8_t	r2											=	2;
const uint8_t	r3											=	3;
const uint8_t	r4											=	4;
const uint8_t	r5											=	5;
const uint8_t	r6											=	6;
const uint8_t	r7											=	7;
const uint8_t	r8											=	8;

const uint8_t	kFirstGeneralPurposeRegisterIdx				=	r2;

