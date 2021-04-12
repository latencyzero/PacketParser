//
//  Disassembler.m
//  PacketParser
//
//  Created by Roderick Mann on 1/2/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "Disassembler.h"



//
//	Library Imports
//

#import "Debug.h"
#import "NSString+LZ.h"

//
//	Project Imports
//

#import "ParserByteCodeDecodeUtils.h"


const NSUInteger	kColumnByteCode				=	8;
const NSUInteger	kColumnMnemonic				=	20;
const NSUInteger	kColumnOperands				=	32;
const NSUInteger	kColumnComment				=	52;



@interface Disassembler()
{
	NSMutableString*			mDisassembly;
	NSMutableString*			mLine;
}

@end



@implementation Disassembler






- (void)
dumpProgram
{
	mDisassembly = [NSMutableString string];
	
	self.pc = 0;
	while (true)
	{
		NSNumber* n = [self.program objectAtIndex: self.pc];
		ParserInstruction inst = n.unsignedIntValue;
		
		mLine = [NSMutableString string];
	
		[mLine appendFormat: @"%04X:", self.pc];
		[mLine padToColumn: kColumnByteCode];
		[mLine appendFormat: @"%08x", inst];
		[mLine padToColumn: kColumnMnemonic];
		
		[self decodeAndDispatch: inst];
		
		[mDisassembly appendString: mLine];
		[mDisassembly appendString: @"\n"];
		
		self.pc += 1;
		
		if (self.pc >= self.program.count)
		{
			break;
		}
	}
	
	NSLogDebug(@"Program:\n%@", mDisassembly);
}



- (void)
execHalt
{
	[mLine appendString: @"halt"];
	[mLine padToColumn: kColumnOperands];
}



- (void)
execMarker: (NSData*) inPreamble
{
	[mLine appendString: @"marker"];
	[mLine padToColumn: kColumnOperands];
	
	uint8_t b;
	[inPreamble getBytes: &b range: NSMakeRange(0, 1)];
	[mLine appendFormat: @"0x%02x ", b];
	
	for (NSUInteger i = 1; i < inPreamble.length; ++i)
	{
		[inPreamble getBytes: &b range: NSMakeRange(i, 1)];
		[mLine appendFormat: @", 0x%02x ", b];
	}
}

- (void)
execFieldType: (uint8_t) inType
	size: (uint8_t) inSize
	reg: (uint8_t) inTargetRegIdx
{
	[mLine appendString: @"field"];
	[mLine padToColumn: kColumnOperands];
	
	switch (inType)
	{
		case kFieldTypeIntegerUnsigned:		[mLine appendFormat: @"u"];		break;
		case kFieldTypeIntegerSigned:		[mLine appendFormat: @"s"];		break;
		case kFieldTypeFloat:				[mLine appendFormat: @"f"];		break;
	}
	
	[mLine appendFormat: @"%u", inSize * 8];
	
	if (inTargetRegIdx >= kFirstGeneralPurposeRegisterIdx)
	{
		[mLine appendFormat: @",%@", [self nameForRegister: inTargetRegIdx]];
	}
}

/**
	The block exec doesn't give us the register, so we need to
	override the decode method instead.
*/

- (void)
decodeBlock: (ParserInstruction) inInst
{
	[mLine appendString: @"block"];
	[mLine padToColumn: kColumnOperands];
	
	uint8_t regIdx = getTargetReg(inInst);
	[mLine appendFormat: @"%@", [self nameForRegister: regIdx]];
}

- (void)
execLoadCurrentFrameIndex: (uint8_t) inTargetRegIdx
{
	[mLine appendString: @"lfidx"];
	[mLine padToColumn: kColumnOperands];
	
	[mLine appendFormat: @"%@", [self nameForRegister: inTargetRegIdx]];
	
	if (inTargetRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		[mLine padToColumn: kColumnComment];
		[mLine appendString: @"//  Invalid target register"];
	}
}

- (void)
execMoveReg: (uint8_t) inSourceRegIdx
	toReg: (uint8_t) inTargetRegIdx
{
	[mLine appendString: @"mov"];
	[mLine padToColumn: kColumnOperands];
	
	NSString* tr = [self nameForRegister: inTargetRegIdx];
	NSString* sr = [self nameForRegister: inSourceRegIdx];
	[mLine appendFormat: @"%@,%@", tr, sr];
	
	if (inTargetRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		[mLine padToColumn: kColumnComment];
		[mLine appendString: @"//  Invalid target register"];
	}
}

- (void)
execSubUnsignedTarget: (uint8_t) inTargetRegIdx
	operand1: (uint8_t) inOperand1RegIdx
	operand2: (uint8_t) inOperand2RegIdx
{
	[mLine appendString: @"sub"];
	[mLine padToColumn: kColumnOperands];
	
	NSString* tr = [self nameForRegister: inTargetRegIdx];
	NSString* op1 = [self nameForRegister: inOperand1RegIdx];
	NSString* op2 = [self nameForRegister: inOperand2RegIdx];
	[mLine appendFormat: @"%@,%@,%@", tr, op1, op2];
	
	if (inTargetRegIdx < kFirstGeneralPurposeRegisterIdx)
	{
		[mLine padToColumn: kColumnComment];
		[mLine appendString: @"//  Invalid target register"];
	}
}

- (void)
execFrame: (int16_t) inFrameOffset
	name: (int16_t) inStringOffset
{
	[mLine appendString: @"fname"];
	[mLine padToColumn: kColumnOperands];
	
	[mLine appendFormat: @"%d,%d", inFrameOffset, inStringOffset];
	
	[mLine padToColumn: kColumnComment];
	[mLine appendFormat: @"//  %04X,%04X", self.pc + inFrameOffset, self.pc + inStringOffset];
}

- (void)
decodeString: (ParserInstruction) inInst
{
	[mLine appendString: @"string"];
	[mLine padToColumn: kColumnOperands];
	
	//	Fetch and decode the next words…
	
	uint16_t len = getStringLength(inInst);
	[mLine appendFormat: @"%d", len];

	NSUInteger words = len / sizeof (ParserInstruction);
	NSUInteger instSize = sizeof (ParserInstruction);
	if (len % instSize > 0)
	{
		words += 1;
	}
	
	NSMutableString* dataLines = [NSMutableString string];
	
	Register tempPC = self.pc;
	NSMutableData* d = [NSMutableData dataWithCapacity: len];
	for (NSUInteger i = 0; i < words; ++i)
	{
		tempPC += 1;
		ParserInstruction inst = [self fetchFrom: tempPC];
		[d appendBytes: &inst length: sizeof (inst)];
		
		NSMutableString* line = [NSMutableString string];
		[line appendFormat: @"%04X:", tempPC];
		[line padToColumn: kColumnByteCode];
		[line appendFormat: @"%08x", inst];
		[dataLines appendFormat: @"\n%@", line];
	}
	d.length = len;
	
	NSString* s = [[NSString alloc] initWithData: d encoding: NSUTF8StringEncoding];
	[mLine appendFormat: @",\"%@\"", s];
	[mLine appendString: dataLines];
	
	self.pc += words;
}

- (void)
execCall: (int32_t) inOffset
{
	[mLine appendString: @"call"];
	[mLine padToColumn: kColumnOperands];
	
	[mLine appendFormat: @"%d", inOffset];
	
	[mLine padToColumn: kColumnComment];
	[mLine appendFormat: @"//  %04X", self.pc + inOffset];
}

- (void)
execReturn
{
	[mLine appendString: @"ret"];
	[mLine padToColumn: kColumnOperands];
	
}

- (void)
execPush: (uint8_t) inRegIdx
{
	[mLine appendString: @"push"];
	[mLine padToColumn: kColumnOperands];
	
	NSString* tr = [self nameForRegister: inRegIdx];
	[mLine appendFormat: @"%@", tr];
}

- (void)
execPop: (uint8_t) inRegIdx
{
	[mLine appendString: @"pop"];
	[mLine padToColumn: kColumnOperands];
	
	NSString* tr = [self nameForRegister: inRegIdx];
	[mLine appendFormat: @"%@", tr];
}

- (void)
execLoadImmediate: (uint8_t) inRegIdx
	value: (uint16_t) inVal
{
	[mLine appendString: @"ldi"];
	[mLine padToColumn: kColumnOperands];
	
	NSString* tr = [self nameForRegister: inRegIdx];
	[mLine appendFormat: @"%@,%u", tr, inVal];
}


#pragma mark -

- (NSString*)
nameForRegister: (uint8_t) inRegIdx
{
	if (inRegIdx == 0)
	{
		return @"pc";
	}
	else if (inRegIdx == 1)
	{
		return @"sp";
	}
	else
	{
		return [NSString stringWithFormat: @"r%u", inRegIdx];
	}
}


@end
