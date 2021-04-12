
//
//	Private Instruction Word Utilities
//

inline
uint8_t
getOpcode(ParserInstruction inInstruction)
{
	return (inInstruction >> 24) & 0x000000FF;
}

inline
bool
isHalt(ParserInstruction inInstruction)
{
	return inInstruction == 0;
}

inline
uint8_t
getFieldType(ParserInstruction inInstruction)
{
	return (inInstruction >> 8) & 0xFF;
}

inline
uint8_t
getFieldSize(ParserInstruction inInstruction)
{
	return (inInstruction >> 0) & 0xFF;
}

inline
uint8_t
getTargetReg(ParserInstruction inInstruction)
{
	return (inInstruction >> 16) & 0xFF;
}

inline
uint8_t
getOperand1Reg(ParserInstruction inInstruction)
{
	return (inInstruction >> 8) & 0xFF;
}

inline
uint8_t
getOperand2Reg(ParserInstruction inInstruction)
{
	return (inInstruction >> 0) & 0xFF;
}

inline
uint8_t
getMarkerSize(ParserInstruction inInstruction)
{
	return (inInstruction >> 16) & 0xFF;
}

inline
uint8_t
getMarkerU8(ParserInstruction inInstruction)
{
	return (inInstruction >> 8) & 0xFF;
}

inline
uint16_t
getMarkerU16(ParserInstruction inInstruction)
{
	return (inInstruction >> 0) & 0xFFFF;
}

inline
int16_t
getFrameNameFrameOffset(ParserInstruction inInstruction)
{
	int16_t inst = (inInstruction & 0xFFF000) >> 8;
	inst >>= 4;
	return inst;
}

inline
int16_t
getFrameNameStringOffset(ParserInstruction inInstruction)
{
	int16_t inst = (inInstruction & 0x0FFF) << 4;
	inst >>= 4;
	return inst;
}

inline
uint16_t
getStringLength(ParserInstruction inInstruction)
{
	return (inInstruction >> 0) & 0xFFFF;
}

inline
int16_t
getCallOffset(ParserInstruction inInstruction)
{
	int32_t offset = (inInstruction & 0x00FFffFF) << 8;
	offset >>= 8;
	return offset;
}

inline
uint16_t
getLoadImmediateVal(ParserInstruction inInstruction)
{
	return inInstruction & 0xFFFF;
}

