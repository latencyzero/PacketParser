/**
	NSData+LZ.h
	iAPTest
	
	Created by Roderick Mann on 7/31/10.
	Copyright 2010 Latency: Zero. All rights reserved.
*/



@interface NSData(LZ)

@property (nonatomic, retain, readonly)	NSString*			hexCharString;

- (NSString*)			dumpLine: (uint8_t*) inData
							length: (uint32_t) inLength
							width: (uint32_t) inWidth;

- (uint64_t)			u64At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (uint32_t)			u32At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (uint16_t)			u16At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (uint8_t)				u8At: (NSUInteger) inIdx littleEndian: (bool) inLE;

- (int64_t)				s64At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (int32_t)				s32At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (int16_t)				s16At: (NSUInteger) inIdx littleEndian: (bool) inLE;
- (int8_t)				s8At: (NSUInteger) inIdx littleEndian: (bool) inLE;

@end
