/**
	NSString+LZ.h
	
	Created by Roderick Mann on 5/19/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

@interface NSString(LZ)

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_2_0
- (void)		drawCenteredOnPoint: (CGPoint) inPt
					withFont: (UIFont*) inFont;

- (void)		drawRightJustifiedOnPoint: (CGPoint) inPt
					withFont: (UIFont*) inFont;
#endif

- (bool)			containsString: (NSString*) inS;
- (NSString*)		stringByDecodingURLEncoded;

- (NSString*)		stringByURLEncoding;
- (NSString*)		stringByURLEncodingUsingEncoding: (NSStringEncoding) inEncoding;

+ (NSString*)		randomStringOfLength: (NSUInteger) inLength;

@property (nonatomic, copy, readonly)	NSString*					baseResourceName;

@end




@interface NSMutableString(LZ)

/**
	Append spaces to the receiver such that any subsequently appended
	string will begin at the next tab stop.
*/

- (void)			padToNextTab: (NSUInteger) inTabWidth;

/**
	Append spaces to the receiver such that any subsequently appended
	string will begin at the specified column.
*/

- (void)			padToColumn: (NSUInteger) inColumn;


@end
