//
//  Interpreter.m
//  PacketParser
//
//  Created by Roderick Mann on 1/2/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "Interpreter.h"

//
//	Standard Imports
//

#import <cstring>


//
//	Library Imports
//

#import "Debug.h"


//
//	Project Imports
//

#import "ParserByteCode.h"
#import "ParserByteCodeDecodeUtils.h"







@interface Interpreter()
{
	Register			mRegister[256];
	NSMutableArray*		mStack;
}


@end


@implementation Interpreter




- (void)
reset
{
	self.haltReason = kHaltReasonReset;
	self.pc = 0;
	std::memset(mRegister, 256, sizeof (*mRegister));
	mStack = [NSMutableArray array];
}

- (HaltReason)
execute
{
	self.haltReason = kHaltReasonRunning;
	
	while (true)
	{
		ParserInstruction inst = [self fetch];
		NSLogDebug(@"Executing: %04x:     0x%08x", self.pc, inst);
		bool more = [self decodeAndDispatch: inst];
		
		if (self.haltReason != kHaltReasonRunning)
		{
			//	TODO: should we snapshot the interpreter state before the
			//			current instruction, and restore it for certain kinds
			//			of halt (e.g. end of input)? Or just require implementors
			//			to ensure they don't change state before issuing a halt?
			break;
		}
		
		self.pc += 1;
		
		if (!more)
		{
			break;
		}
	}
	
	return self.haltReason;
}

- (ParserInstruction)
fetch
{
	return [self fetchFrom: self.pc];
}

- (ParserInstruction)
fetchFrom: (Register) inPC
{
	if (inPC >= self.program.count)
	{
		return makeHaltInstruction();
	}
	
	NSNumber* n = [self.program objectAtIndex: inPC];
	return n.unsignedIntValue;
}

- (void)
push: (Register) inVal
{
	[mStack addObject: @(inVal)];
}

- (Register)
pop
{
	NSNumber* n = mStack.lastObject;
	[mStack removeLastObject];
	return n.unsignedIntValue;
}


- (bool)
decodeAndDispatch: (ParserInstruction) inInst
{
	uint8_t opCode = getOpcode(inInst);
	switch (opCode)
	{
		case kOpCodeHalt:						[self decodeHalt: inInst];			break;
		case kOpCodeMarker:						[self decodeMarker: inInst];		break;
		case kOpCodeField:						[self decodeField: inInst];			break;
		case kOpCodeBlock:						[self decodeBlock: inInst];			break;
		case kOpCodeLoadCurrentFrameIndex:		[self decodeLFIDX: inInst];			break;
		case kOpCodeMoveRegToReg:				[self decodeMovRegToReg: inInst];	break;
		case kOpCodeSubUnsigned:				[self decodeSubUnsigned: inInst];	break;
		case kOpCodeSetFrameName:				[self decodeFrameName: inInst];		break;
		case kOpCodeString:						[self decodeString: inInst];		break;
		case kOpCodeCall:						[self decodeCall: inInst];			break;
		case kOpCodeReturn:						[self decodeReturn: inInst];		break;
		case kOpCodePush:						[self decodePush: inInst];			break;
		case kOpCodePop:						[self decodePop: inInst];			break;
		case kOpCodeLoadImmediate:				[self decodeLoadImmediate: inInst];	break;
		
		default:
		{
			NSLogDebug(@"Unknown op code 0x%02X. Halting.", opCode);
			self.haltReason = kHaltReasonUnknownOpCode;
			return false;
		}
	}
	
	if (self.haltReason == kHaltReasonHalt)
	{
		return false;
	}
	
	return true;
}

- (void)
decodeHalt: (ParserInstruction) inInst
{
	[self execHalt];
}

- (void)
execHalt
{
	self.haltReason = kHaltReasonHalt;
}

- (void)
decodeMarker: (ParserInstruction) inInst
{
	NSUInteger size = getMarkerSize(inInst);
	NSMutableData* preamble = [NSMutableData dataWithCapacity: size];
	if (size <= 2)
	{
		uint8_t b = (inInst >> 8) & 0xFF;
		[preamble appendBytes: &b length: sizeof (b)];
		if (size > 1)
		{
			b = (inInst >> 0) & 0xFF;
			[preamble appendBytes: &b length: sizeof (b)];
		}
	}
	else
	{
		NSLogDebug(@"Implement marker sizes greater than 2");
	}
	[self execMarker: preamble];
}

- (void)
execMarker: (NSData*) inPreamble
{
}

- (void)
decodeField: (ParserInstruction) inInst
{
	uint8_t fieldType = getFieldType(inInst);
	uint8_t fieldSize = getFieldSize(inInst);
	uint8_t regIdx = getTargetReg(inInst);
	
	[self execFieldType: fieldType size: fieldSize reg: regIdx];
}

- (void)
execFieldType: (uint8_t) inType
	size: (uint8_t) inSize
	reg: (uint8_t) inTargetRegIdx
{
}

- (void)
decodeBlock: (ParserInstruction) inInst
{
	uint8_t regIdx = getTargetReg(inInst);
	Register len = [self registerValue: regIdx];
	[self execBlock: len];
}

- (void)
execBlock: (Register) inLength
{
}

- (void)
decodeLFIDX: (ParserInstruction) inInst
{
	uint8_t regIdx = getTargetReg(inInst);
	[self execLoadCurrentFrameIndex: regIdx];
}

- (void)
execLoadCurrentFrameIndex: (uint8_t) inTargetRegIdx
{
}

- (void)
decodeMovRegToReg: (ParserInstruction) inInst
{
	uint8_t source = getOperand1Reg(inInst);
	uint8_t target = getTargetReg(inInst);
	[self execMoveReg: source toReg: target];
}

- (void)
execMoveReg: (uint8_t) inSourceRegIdx
	toReg: (uint8_t) inTargetRegIdx
{
	if (inTargetRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		NSLogDebug(@"Can't move to special register");
		return;
	}
	
	Register val = [self registerValue: inSourceRegIdx];
	[self loadRegister: inTargetRegIdx withValue: val];
}

- (void)
decodeSubUnsigned: (ParserInstruction) inInst
{
	uint8_t target = getTargetReg(inInst);
	uint8_t op1 = getOperand1Reg(inInst);
	uint8_t op2 = getOperand2Reg(inInst);
	[self execSubUnsignedTarget: target operand1: op1 operand2: op2];
}

- (void)
execSubUnsignedTarget: (uint8_t) inTargetRegIdx
	operand1: (uint8_t) inOperand1RegIdx
	operand2: (uint8_t) inOperand2RegIdx
{
	if (inTargetRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		NSLogDebug(@"Can't sub to special register");
		return;
	}
	
	Register v1 = [self registerValue: inOperand1RegIdx];
	Register v2 = [self registerValue: inOperand2RegIdx];
	Register vt = v1 - v2;
	[self loadRegister: inTargetRegIdx withValue: vt];
}

- (void)
decodeFrameName: (ParserInstruction) inInst
{
	int16_t frameOffset = getFrameNameFrameOffset(inInst);
	int16_t stringOffset = getFrameNameStringOffset(inInst);
	[self execFrame: frameOffset name: stringOffset];
}

- (void)
execFrame: (int16_t) inFrameOffset
	name: (int16_t) inStringOffset
{
}

- (void)
decodeString: (ParserInstruction) inInst
{
	uint16_t len = getStringLength(inInst);

	NSUInteger words = len / sizeof (ParserInstruction);
	NSUInteger instSize = sizeof (ParserInstruction);
	if (len % instSize > 0)
	{
		words += 1;
	}
	
	Register tempPC = self.pc;
	NSMutableData* d = [NSMutableData dataWithCapacity: len];
	for (NSUInteger i = 0; i < words; ++i)
	{
		tempPC += 1;
		ParserInstruction inst = [self fetchFrom: tempPC];
		[d appendBytes: &inst length: sizeof (inst)];
	}
	d.length = len;
	
	NSString* s = [[NSString alloc] initWithData: d encoding: NSUTF8StringEncoding];
	[self execString: s words: (Register) words];
}

- (void)
execString: (NSString*) inString
	words: (Register) inNumWords
{
}

- (void)
decodeCall: (ParserInstruction) inInst
{
	int32_t offset = getCallOffset(inInst);
	[self execCall: offset];
}

- (void)
execCall: (int32_t) inOffset
{
}

- (void)
decodeReturn: (ParserInstruction) inInst
{
	[self execReturn];
}

- (void)
execReturn
{
}

- (void)
decodePush: (ParserInstruction) inInst
{
	uint8_t target = getTargetReg(inInst);
	[self execPush: target];
}

- (void)
execPush: (uint8_t) inRegIdx
{
}

- (void)
decodePop: (ParserInstruction) inInst
{
	uint8_t target = getTargetReg(inInst);
	[self execPop: target];
}

- (void)
execPop: (uint8_t) inRegIdx
{
}

- (void)
decodeLoadImmediate: (ParserInstruction) inInst
{
	uint8_t target = getTargetReg(inInst);
	uint16_t val = getLoadImmediateVal(inInst);
	[self execLoadImmediate: target value: val];
}

- (void)
execLoadImmediate: (uint8_t) inRegIdx
	value: (uint16_t) inVal
{
}






- (void)
loadRegister: (uint8_t) inRegIdx
	withValue: (Register) inVal
{
	if (inRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		NSLogDebug(@"Can't load special registers!");
		return;
	}
	
	mRegister[inRegIdx] = inVal;
}

- (void)
loadSpecialRegister: (uint8_t) inRegIdx
	withValue: (Register) inVal
{
	mRegister[inRegIdx] = inVal;
}

- (Register)
registerValue: (uint8_t) inRegIdx
{
	return mRegister[inRegIdx];
}


#pragma mark -
#pragma mark • Properties

- (Register)
pc
{
	return mRegister[pc];
}

- (void)
setPc: (Register) inVal
{
	mRegister[pc] = inVal;
}

@end
