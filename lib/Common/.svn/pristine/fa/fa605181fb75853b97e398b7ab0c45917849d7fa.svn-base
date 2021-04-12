/**
	NSString+LZ.m
	
	Created by Roderick Mann on 5/19/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "NSString+LZ.h"

//
//	Standard Imports
//

#import <stdlib.h>






@implementation NSString(LZ)

- (bool)
containsString: (NSString*) inS
{
	NSRange r = [self rangeOfString: inS];
	return r.location != NSNotFound;
}

- (NSString*)
stringByDecodingURLEncoded
{
	NSString* s = [self stringByReplacingOccurrencesOfString: @"+" withString: @" "];
	s = [s stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	return s;
}

- (NSString*)
stringByURLEncoding
{
	return [self stringByURLEncodingUsingEncoding: NSUTF8StringEncoding];
}

- (NSString*)
stringByURLEncodingUsingEncoding: (NSStringEncoding) inEncoding
{
	CFStringRef s = CFURLCreateStringByAddingPercentEscapes(NULL,
						   (__bridge CFStringRef) self,
						   NULL,
						   (CFStringRef) @"!*'\"();:@&=+$,/?%#[]% ",
						   CFStringConvertNSStringEncodingToEncoding(inEncoding));
	return CFBridgingRelease(s);
}


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_2_0

- (void)
drawCenteredOnPoint: (CGPoint) inPt
	withFont: (UIFont*) inFont
{
	CGSize s = [self sizeWithFont: inFont];
	CGRect tb;
	tb.size = s;
	tb.origin.x = inPt.x - tb.size.width / 2.0f;
	tb.origin.y = inPt.y - tb.size.height / 2.0f;
	
	[self drawInRect: tb
			withFont: inFont
			lineBreakMode: NSLineBreakByClipping
			alignment: NSTextAlignmentCenter];
}

- (void)
drawRightJustifiedOnPoint: (CGPoint) inPt
	withFont: (UIFont*) inFont
{
	CGSize s = [self sizeWithFont: inFont];
	CGRect tb;
	tb.size = s;
	tb.origin.x = inPt.x - tb.size.width;
	tb.origin.y = inPt.y - tb.size.height / 2.0f;
	
	[self drawInRect: tb
			withFont: inFont
			lineBreakMode: NSLineBreakByClipping
			alignment: NSTextAlignmentRight];
}

#endif

- (NSString*)
baseResourceName
{
	NSString* name = self.lastPathComponent;
	NSString* ext = self.pathExtension;
	ext = [@"." stringByAppendingString: ext];
	if ([name hasSuffix: ext])
	{
		NSRange r = [name rangeOfString: ext options: NSBackwardsSearch];
		name = [name substringToIndex: r.location];
	}
	
	return name;
}

+ (NSString*)
randomStringOfLength: (NSUInteger) inLength
{
	static NSString*			sTokenChars = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$^*(){}[]|";
	static dispatch_once_t		sInit;
	dispatch_once(&sInit,
	^{
		arc4random_stir();
	});
	
	
	NSMutableString* s = [NSMutableString string];
	for (int i = 0; i < inLength; i++)
	{
		uint32_t idx = arc4random_uniform((uint32_t) sTokenChars.length);
		unichar c = [sTokenChars characterAtIndex: idx];
		[s appendString: [NSString stringWithCharacters: &c length: 1]];
	}
	
	return [s copy];
}

@end



@implementation NSMutableString(LZ)


- (void)
padToNextTab: (NSUInteger) inTabWidth
{
	NSUInteger numSpaces = inTabWidth - (self.length % inTabWidth);
	for (NSUInteger i = 0; i < numSpaces; ++i)
	{
		[self appendString: @" "];
	}
}

- (void)
padToColumn: (NSUInteger) inColumn
{
	if (self.length > inColumn)
	{
		//	TODO: Throw range exception?
		return;
	}
	
	NSUInteger numSpaces = inColumn - self.length;
	for (NSUInteger i = 0; i < numSpaces; ++i)
	{
		[self appendString: @" "];
	}
}


@end