/**
	NSData+LZ.m
	iAPTest
	
	Created by Roderick Mann on 7/31/10.
	Copyright 2010 Latency: Zero. All rights reserved.
*/

#import "NSData+LZ.h"




inline	uint64_t	LZSwapLittleToHost(uint64_t inVal)			{ return CFSwapInt64LittleToHost(inVal); }
inline	uint32_t	LZSwapLittleToHost(uint32_t inVal)			{ return CFSwapInt32LittleToHost(inVal); }
inline	uint16_t	LZSwapLittleToHost(uint16_t inVal)			{ return CFSwapInt16LittleToHost(inVal); }

inline	uint64_t	LZSwapBigToHost(uint64_t inVal)				{ return CFSwapInt64BigToHost(inVal); }
inline	uint32_t	LZSwapBigToHost(uint32_t inVal)				{ return CFSwapInt32BigToHost(inVal); }
inline	uint16_t	LZSwapBigToHost(uint16_t inVal)				{ return CFSwapInt16BigToHost(inVal); }

inline	int64_t		Signed(uint64_t inVal)						{ return *reinterpret_cast<int64_t*>(&inVal); }
inline	int32_t		Signed(uint32_t inVal)						{ return *reinterpret_cast<int32_t*>(&inVal); }
inline	int16_t		Signed(uint16_t inVal)						{ return *reinterpret_cast<int16_t*>(&inVal); }

inline	uint64_t	Unsigned(int64_t inVal)						{ return *reinterpret_cast<uint64_t*>(&inVal); }
inline	uint32_t	Unsigned(int32_t inVal)						{ return *reinterpret_cast<uint32_t*>(&inVal); }
inline	uint16_t	Unsigned(int16_t inVal)						{ return *reinterpret_cast<uint16_t*>(&inVal); }

inline	uint64_t	LZSwapToHost(uint64_t inVal, bool inLE)		{ return inLE ? CFSwapInt64LittleToHost(inVal) : CFSwapInt64BigToHost(inVal); }
inline	uint32_t	LZSwapToHost(uint32_t inVal, bool inLE)		{ return inLE ? CFSwapInt32LittleToHost(inVal) : CFSwapInt32BigToHost(inVal); }
inline	uint16_t	LZSwapToHost(uint16_t inVal, bool inLE)		{ return inLE ? CFSwapInt16LittleToHost(inVal) : CFSwapInt16BigToHost(inVal); }

inline	int64_t		LZSwapToHost(int64_t inVal, bool inLE)		{ uint64_t v = Unsigned(inVal); return Signed(inLE ? CFSwapInt64LittleToHost(v) : CFSwapInt64BigToHost(v)); }
inline	int32_t		LZSwapToHost(int32_t inVal, bool inLE)		{ uint32_t v = Unsigned(inVal); return Signed(inLE ? CFSwapInt32LittleToHost(v) : CFSwapInt32BigToHost(v)); }
inline	int16_t		LZSwapToHost(int16_t inVal, bool inLE)		{ uint16_t v = Unsigned(inVal); return Signed(inLE ? CFSwapInt16LittleToHost(v) : CFSwapInt16BigToHost(v)); }


@interface NSData()


@end



@implementation NSData(LZ)

- (NSString*)
hexCharString
{
	NSMutableString* result = [NSMutableString string];
	
	uint32_t	bytesPerLine = 32;
	NSUInteger	lines = self.length / bytesPerLine;
	uint8_t*	addr = (uint8_t*) self.bytes;
	
	for (uint32_t l = 0; l < lines; l++)
	{
		NSString* ls = [self dumpLine: addr length: bytesPerLine width: bytesPerLine];
		[result appendFormat: @"%@\n", ls];
		
		addr += bytesPerLine;
	}
	
	uint32_t	leftOver = self.length % bytesPerLine;
	NSString* ls = [self dumpLine: addr length: leftOver width: bytesPerLine];
	[result appendFormat: @"%@\n", ls];
	
	return result;
}

- (NSString*)
dumpLine: (uint8_t*) inData
	length: (uint32_t) inLength
	width: (uint32_t) inWidth 
{
	NSMutableString* line = [NSMutableString string];
	
	//	Show the memory address (not really appropriate for streaming data)…
	//[line appendFormat: @"\n0x%08lx: ", inData];
	
	//	Dump a line of hex values…
	
	const uint8_t*	p = inData;
	const char*		cp = (const char*) inData;
	
	for (uint32_t j = 0; j < inWidth; j++)
	{
		if (j < inLength)
		{
			[line appendFormat: @"%02x ", *p];
			p += 1;
		}
		else
		{
			[line appendFormat: @"   "];	//	Margin before chars
		}
		
		if (j % 4 == 3)
		{
			[line appendFormat: @" "];		//	Extra space every 4 bytes
		}
		
		if (j % 8 == 7)
		{
			[line appendFormat: @" "];		//	Wider space every 8 bytes
		}
	}
	
	//	Dump a line of characters…
	
	for (uint32_t j = 0; j < inLength; j++)
	{
		char c = *cp;
#if 0
		if (c < ' ')			//	Substitute a nice explanatory glyph
		{
			unichar wc = 0x2400;
			wc |= c;
			[line appendFormat: @"%C", wc];
		}
		else if (c == 0x7F)		//	DEL has a glyph, too
		{
			[line appendFormat: @"␡"];
		}
#else
		if (c < ' ')			//	Put a dot in for unprintable chars
		{
			[line appendFormat: @"•"];
		}
#endif
		else if (c > '~')		//	0x80 or higher gets a dot
		{
			[line appendFormat: @"•"];
		}
		else					//	Everything else is ASCII
		{
			[line appendFormat: @"%c", c];
		}
		
		cp += 1;
		
#if 0
		if (j % 4 == 3)
		{
			[line appendFormat: @" "];
		}
#endif

		if (j % 8 == 7)
		{
			[line appendFormat: @" "];
		}
	}
	
	return line;
}

- (uint64_t)
u64At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	uint64_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (uint32_t)
u32At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	uint32_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (uint16_t)
u16At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	uint16_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (uint8_t)
u8At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	uint8_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	return val;
}

- (int64_t)
s64At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	int64_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (int32_t)
s32At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	int32_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (int16_t)
s16At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	int16_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	val = LZSwapToHost(val, inLE);
	return val;
}

- (int8_t)
s8At: (NSUInteger) inIdx
	littleEndian: (bool) inLE
{
	int8_t val = 0;
	NSRange r = NSMakeRange(inIdx, sizeof (val));
	[self getBytes: &val range: r];
	return val;
}


@end
