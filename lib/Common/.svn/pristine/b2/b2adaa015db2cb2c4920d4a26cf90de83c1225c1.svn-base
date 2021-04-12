/**
	YAttributedStringBuilder.m
	MarchMadnessTwitterTest
	
	Created by Roderick Mann on 1/21/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import "LZAttributedStringBuilder.h"

//
//	Standard Imports
//

#import <CoreText/CoreText.h>




//
//	Private Methods
//

@interface LZAttributedStringBuilder()

@property (nonatomic, retain, readonly)	NSMutableDictionary*			currentAttrs;

- (void)				clearCurrentAttrs;

@end




//
//	Implementation
//

@implementation LZAttributedStringBuilder

+ (LZAttributedStringBuilder*)
builder
{
#if !ARC_ENABLED
	return [[[LZAttributedStringBuilder alloc] init] autorelease];
#else
	return [[LZAttributedStringBuilder alloc] init];
#endif
}

- (id)
init
{
	self = [super init];
	if (self != nil)
	{
		mString = [[NSMutableAttributedString alloc] init];
		mAttributeStack = [NSMutableArray array];
#if !ARC_ENABLED
		[mAttributeStack retain];
#endif
	}
	
	return self;
}

#if !ARC_ENABLED
- (void)
dealloc
{
	[mString release];
	[mCurrentAttrs release];
	[mAttributeStack release];
	
	[super dealloc];
}
#endif

- (void)
clearCurrentAttrs
{
#if !ARC_ENABLED
	[mCurrentAttrs release];
#endif
	mCurrentAttrs = nil;
}

- (void)
pop
{
	[mAttributeStack removeLastObject];
}

- (void)
append: (NSString*) inString
{
	if (inString == nil)
	{
		return;
	}
	
	//	If there are any new attributes set, append them to the end of the stack
	//	and clear the property…
	
	if (self.currentAttrs != nil)
	{
		[mAttributeStack addObject: self.currentAttrs];
		[self clearCurrentAttrs];
	}
	
	NSDictionary* attrs = [mAttributeStack lastObject];
	NSAttributedString* s = [[NSAttributedString alloc] initWithString: inString attributes: attrs];
	[mString appendAttributedString: s];
#if !ARC_ENABLED
	[s release];
#endif
}

- (void)
appendFormat: (NSString*) inFormat, ...
{
	va_list		argList;
	va_start(argList, inFormat);
	
	NSString* s = [[NSString alloc] initWithFormat: inFormat arguments: argList];
	
	va_end(argList);
	
	[self append: s];
#if !ARC_ENABLED
	[s release];
#endif
}

#pragma mark -
#pragma mark • Attributes

- (NSAttributedString*)
string
{
	NSAttributedString* s = [mString copy];
#if !ARC_ENABLED
	[s autorelease];
#endif
	return s;
}

- (void)
setFont: (UIFont*) inFont
{
	if (inFont == nil)
	{
		[self.currentAttrs removeObjectForKey: (NSString*) kCTFontAttributeName];
		return;
	}
	
	NSString* name = inFont.fontName;
	CTFontRef f = CTFontCreateWithName((CFStringRef) CFBridgingRetain(name), inFont.pointSize, NULL);
	[self.currentAttrs setValue: (id) CFBridgingRelease(f) forKey: (NSString*) kCTFontAttributeName];
	CFRelease(f);
}

- (UIFont*)
font
{
	CTFontRef f = (CTFontRef) CFBridgingRetain([self.currentAttrs valueForKey: (NSString*) kCTFontAttributeName]);
	if (f == NULL)
	{
		return nil;
	}
	
	NSString* name = (NSString*) CFBridgingRelease(CTFontCopyFullName(f));
	UIFont* font = [UIFont fontWithName: name size: CTFontGetSize(f)];
#if !ARC_ENABLED
	[name release];
#endif

	return font;
}

- (void)
setColor: (UIColor*) inColor
{
	CGColorRef c = inColor.CGColor;
	[self.currentAttrs setValue: (id) CFBridgingRelease(c) forKey: (NSString*) kCTForegroundColorAttributeName];
}

- (UIColor*)
color
{
	return [self.currentAttrs valueForKey: (NSString*) kCTForegroundColorAttributeName];
}

- (void)
setUnderlineStyle: (CTUnderlineStyle) inStyle
{
	NSNumber* v = [NSNumber numberWithInteger: inStyle];
	[self.currentAttrs setValue: (id) v forKey: (NSString*) kCTUnderlineStyleAttributeName];
}

- (CTUnderlineStyle)
underlineStyle
{
	NSNumber* v = [self.currentAttrs valueForKey: (NSString*) kCTUnderlineStyleAttributeName];
	return v.integerValue;
}

- (NSMutableDictionary*)
currentAttrs
{
	if (mCurrentAttrs == nil)
	{
		mCurrentAttrs = [NSMutableDictionary dictionaryWithDictionary: mAttributeStack.lastObject];
#if !ARC_ENABLED
		[mCurrentAttrs retain];
#endif
	}
	
	return mCurrentAttrs;
}

- (void)
setLinkTarget: (id) inTarget
{
	[self.currentAttrs setValue: inTarget forKey: kYAttributedStringBuilderKeyLinkTarget];
}

- (id)
linkTarget
{
	return [self.currentAttrs valueForKey: kYAttributedStringBuilderKeyLinkTarget];
}

- (void)
setLinkSelector: (SEL) inSelector
{
	NSString* s = NSStringFromSelector(inSelector);
	[self.currentAttrs setValue: s forKey: kYAttributedStringBuilderKeyLinkSelector];
}

- (SEL)
linkSelector
{
	NSString* s = [self.currentAttrs valueForKey: kYAttributedStringBuilderKeyLinkSelector];
	SEL sel = NSSelectorFromString(s);
	return sel;
}

- (void)
setLinkContext: (id) inContext
{
	[self.currentAttrs setValue: inContext forKey: kYAttributedStringBuilderKeyLinkContext];
}

- (id)
linkContext
{
	return [self.currentAttrs valueForKey: kYAttributedStringBuilderKeyLinkContext];
}


@end

NSString*	kYAttributedStringBuilderKeyLinkTarget			=	@"com.yahoo.stringattr.LinkTarget";
NSString*	kYAttributedStringBuilderKeyLinkSelector		=	@"com.yahoo.stringattr.LinkSelector";
NSString*	kYAttributedStringBuilderKeyLinkContext			=	@"com.yahoo.stringattr.LinkContext";
