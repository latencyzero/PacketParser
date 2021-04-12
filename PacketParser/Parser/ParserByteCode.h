
#import <climits>


typedef uint32_t		ParserInstruction;
typedef	uint32_t		Register;


/**
	Parse byte code is a set of 32-bit instruction words. The top nybble
	(bits 31 - 24) is the op code.
	
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
	|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
	+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	|               |                                               |
	|    Op Code    |                                               |
	|               |                                               |
	+---------------+-----------------------------------------------+
*/

enum
ParserOpCode
{
	kOpCodeHalt					=	0x00,
	
	/**
		A field op code defines a field in the packet. It is an integral
		number of bytes wide.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |               |               |
		|    Op Code    |   Load Reg    |  Field Type   |  Field Size   |
		|               |               |               |               |
		+---------------+-----------------------------------------------+
	
	*/
	
	kOpCodeField				=	0x01,
	
	/**
		A bitfield belongs to a bitfield-type Field. A Field instruction of
		bitfield type is followed by one or more Bitfield instructions.
	*/
	
	kOpCodeBitfield				=	0x02,
	
	/**
		An immediate block holds a constant number of bytes. The size can
		be up to 2^24-1 bytes long. The size is specified in the lower 3
		bytes of the instruction word.
		
	*/
	
	kOpCodeBlockImmediate		=	0x03,
	
	/**
		A block holds a variable number of bytes, defined by an integer
		field seen earlier in the packet. The lower 3 bytes holds the
		offset to the field instruction.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		| kOpCodeBlock  |  Length Reg   |           reserved            |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeBlock				=	0x04,
	
	/**
		A marker denotes literal values that should be found in
		the stream at this point in the parse. If not found, the entire
		packet is discarded.
		
		Pp code, size. Size <= 2, last two bytes of instruction are
		the marker bytes (big endian). Size > 2, bytes are in subsequent
		instruction words.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		| kOpCodeMarker |    Length     |  Marker Bytes if Length <= 2  |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeMarker					=	0x05,
	
	/**
		Subframe relative. The subframe is up to 2^24 instructions
		away. The relative offset is found in the lower 3 bytes.
	*/
	
	kOpCodeSubframe					=	0x06,
	
	/**
		Load a register from the value of a field. The second byte
		contains the register number, the last two bytes for an
		unsigned offset back to the instruction that defines the
		field.
	*/
	
	kOpCodeLoadRegisterFromField	=	0x07,
	
	/**
		Copy the value from the source register to the target register. The 
		PC can not be modified using this instruction.
		
		mov		r2,r3		//	Copies r3 to r2
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |               |               |
		|   op code     |  Target Reg   |  Source Reg   |   reserved    |
		|               |               |               |               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeMoveRegToReg				=	0x08,
	
	/**
		Load the value of the current frame index into the specified
		register. The index is measured from the start of the current frame.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		|   op code     |  Target Reg   |           reserved            |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeLoadCurrentFrameIndex	=	0x09,
	
	/**
		Subtract, unsigned: target = operand 1 - operand 2.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |               |               |
		|  kOpCodeSubU  |  Target Reg   |   Operand 1   |   Operand 2   |
		|               |               |               |               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeSubUnsigned				=	0x0A,
	
	/**
		Set frame/field name. Frame Rel is the signed relative offset
		to the associated frame/field instruction, and String Rel is
		the signed relative offset to the String instruction for the name.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |                       |                       |
		|   op code     |      frame rel        |      string rel       |
		|               |                       |                       |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeSetFrameName				=	0x0B,
	
	/**
		String. A string starts with this opcode, which defines the
		string's length, and is followed by the bytes of the string
		broken up into instruction word-sized chunks. Executing the
		String opcode causes the PC to jump to the instruction word
		after the last word of the string.
		
		The String is UTF-8 encoded, and padded with zeros at the end
		if necessary to fill out the last instruction word.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		|   op code     |   reserved    |             Length            |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeString					=	0x0C,
	
	/**
		Call a subframe.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |                                               |
		|   op code     |                    offset                     |
		|               |                                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeCall						=	0x0D,
	
	/**
		Return from a subframe call.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |                                               |
		|   op code     |                                               |
		|               |                                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeReturn					=	0x0E,
	
	/**
		Push register onto stack.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		|   op code     |  Target Reg   |           reserved            |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodePush						=	0x0F,
	
	/**
		Pop register off stack.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		|   op code     |  Target Reg   |           reserved            |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodePop						=	0x10,
	
	/**
		Load immediate.
		
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|3|3|2|2|2|2|2|2|2|2|2|2|1|1|1|1|1|1|1|1|1|1| | | | | | | | | | |
		|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|9|8|7|6|5|4|3|2|1|0|
		+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
		|               |               |                               |
		|   op code     |  Target Reg   |            value              |
		|               |               |                               |
		+---------------+-----------------------------------------------+
	*/
	
	kOpCodeLoadImmediate			=	0x11,
	
};

/**
	Fields come in a variety of types. Integer and floating-point types
	in sizes from 1 to 8 bytes, bit fields over ovrall size 1 to 8 bytes.
	The value parsed is loaded into the specified register. A register
	number of 0 causes no register to be loaded (the PC, register 0,
	cannot be updated with this instruction).
	
	TODO: left/right alignment?
*/

enum
ParserFieldType
{
	kFieldTypeUnknonwn			=	0x00,
	kFieldTypeIntegerUnsigned	=	0x01,
	kFieldTypeIntegerSigned		=	0x02,
	kFieldTypeFloat				=	0x03,
	kFieldTypeBitfield			=	0x04,
};

//
//	Instruction Word Utilities
//

inline
ParserInstruction
makeHaltInstruction()
{
	return 0;
}

inline
ParserInstruction
makeInstruction(uint8_t inOpCode)
{
	ParserInstruction inst = inOpCode << 24;
	return inst;
}

inline
ParserInstruction
makeByteMarkerInstruction(uint8_t inMarker)
{
	ParserInstruction inst = makeInstruction(kOpCodeMarker);
	inst |= sizeof(inMarker) << 16;
	inst |= inMarker << 8;
	return inst;
}

inline
ParserInstruction
makeShortMarkerInstruction(uint16_t inMarker)
{
	ParserInstruction inst = makeInstruction(kOpCodeMarker);
	inst |= sizeof(inMarker) << 16;
	inst |= inMarker;
	return inst;
}

inline
ParserInstruction
makeFieldInstruction(uint8_t inFieldType, uint8_t inFieldSize, uint8_t inRegisterIdx)
{
	ParserInstruction inst = makeInstruction(kOpCodeField);
	inst |= inRegisterIdx << 16;
	inst |= inFieldType << 8;
	inst |= inFieldSize << 0;
	return inst;
}

inline
ParserInstruction
makeU16FieldInstruction(uint8_t inRegisterIdx = 0)
{
	return makeFieldInstruction(kFieldTypeIntegerUnsigned, sizeof (uint16_t), inRegisterIdx);
}

inline
ParserInstruction
makeU8FieldInstruction(uint8_t inRegisterIdx = 0)
{
	return makeFieldInstruction(kFieldTypeIntegerUnsigned, sizeof (uint8_t), inRegisterIdx);
}

inline
ParserInstruction
makeUnsignedIntegerField(uint8_t inSize)
{
	ParserInstruction inst = makeFieldInstruction(kFieldTypeIntegerUnsigned, inSize, 0);
	return inst;
}

inline
ParserInstruction
makeSignedIntegerField(uint8_t inSize)
{
	ParserInstruction inst = makeFieldInstruction(kFieldTypeIntegerSigned, inSize, 0);
	return inst;
}

inline
ParserInstruction
makeFloatField(uint8_t inSize)
{
	ParserInstruction inst = makeFieldInstruction(kFieldTypeFloat, inSize, 0);
	return inst;
}

inline
ParserInstruction
makeBitfieldField(uint8_t inSize)
{
	ParserInstruction inst = makeFieldInstruction(kFieldTypeBitfield, inSize, 0);
	return inst;
}

inline
ParserInstruction
makeBlockInstruction(uint8_t inLengthRegister)
{
	ParserInstruction inst = makeInstruction(kOpCodeBlock);
	inst |= inLengthRegister << 16;
	return inst;
}

inline
ParserInstruction
makeMoveInstruction(uint8_t inTargetReg, uint8_t inSourceReg)
{
	ParserInstruction inst = makeInstruction(kOpCodeMoveRegToReg);
	inst |= inTargetReg << 16;
	inst |= inSourceReg << 8;
	return inst;
}

inline
ParserInstruction
makeLoadCurrentFrameIndexInstruction(uint8_t inTargetReg)
{
	ParserInstruction inst = makeInstruction(kOpCodeLoadCurrentFrameIndex);
	inst |= inTargetReg << 16;
	return inst;
}

inline
ParserInstruction
makeSubUnsignedInstruction(uint8_t inTargetReg, uint8_t inOperand1, uint8_t inOperand2)
{
	ParserInstruction inst = makeInstruction(kOpCodeSubUnsigned);
	inst |= inTargetReg << 16;
	inst |= inOperand1 << 8;
	inst |= inOperand2 << 0;
	return inst;
}

inline
ParserInstruction
makeFrameNameInstruction(int16_t inFrameOffset, int16_t inStringOffset)
{
	ParserInstruction inst = makeInstruction(kOpCodeSetFrameName);
	inst |= (inFrameOffset & 0x0FFF) << 12;
	inst |= (inStringOffset & 0xFFF);
	return inst;
}

inline
void
appendStringInstruction(NSMutableArray* ioProgram, NSString* inString)
{
	NSMutableData* d = [[inString dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
	if (d.length > USHRT_MAX)
	{
		return;
	}
	uint16_t len = d.length;
	
	ParserInstruction inst = makeInstruction(kOpCodeString);
	inst |= len;
	
	[ioProgram addObject: @(inst)];
	
	//	Pad out the data to a multiple of sizeof (ParserInstruction) bytes…
	
	ParserInstruction	chunk = 0;
	NSUInteger instSize = sizeof (chunk);
	NSUInteger rem = len % instSize;
	if (rem > 0)
	{
		NSUInteger pad = instSize - rem;
		[d appendBytes: &chunk length: pad];
	}
	
	for (NSUInteger i = 0; i < len; i += instSize)
	{
		[d getBytes: &chunk range: NSMakeRange(i, instSize)];
		[ioProgram addObject: @(chunk)];
	}
}

inline
ParserInstruction
makeCallInstruction(int32_t inOffset)
{
	ParserInstruction inst = makeInstruction(kOpCodeCall);
	inOffset &= 0x00FFFFFF;
	inst |= inOffset;
	return inst;
}

inline
ParserInstruction
makeReturnInstruction()
{
	ParserInstruction inst = makeInstruction(kOpCodeReturn);
	return inst;
}

inline
ParserInstruction
makePushInstruction(int8_t inRegIdx)
{
	ParserInstruction inst = makeInstruction(kOpCodePush);
	inst |= inRegIdx << 16;
	return inst;
}

inline
ParserInstruction
makePopInstruction(int8_t inRegIdx)
{
	ParserInstruction inst = makeInstruction(kOpCodePop);
	inst |= inRegIdx << 16;
	return inst;
}

inline
ParserInstruction
makeLoadImmediateInstruction(uint8_t inTargetReg, uint16_t inVal)
{
	ParserInstruction inst = makeInstruction(kOpCodeLoadImmediate);
	inst |= inTargetReg << 16;
	inst |= inVal;
	return inst;
}


