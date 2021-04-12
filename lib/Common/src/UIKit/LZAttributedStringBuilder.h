/**
	YAttributedStringBuilder.h
	MarchMadnessTwitterTest
	
	Created by Roderick Mann on 1/21/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#import <Foundation/Foundation.h>

//
//	Standard Imports
//

#import <CoreText/CTStringAttributes.h>
#import <UIKit/UIKit.h>



/**
	Helper class for creating NSAttributedStrings.
	
	General usage is as follows. Create a builder, and then call the various -setXXX:
	methods to set the attributes of the text to be appended to the string. Each set
	of attributes is added to any previous set of attributes. You can pop the last
	set of attributes in place at the time of the last append operation.
	
	YAttributedStringBuilder* b = [YAttributedStringBuilder builder];
	b.font = [UIFont fontWithName: @"Helvetica" size: 16.0f];
	b.color = [UIColor redColor];
	[b append: @"Now is the time for red Helvetica "];
	
	b.font = [UIFont fontWithName: @"Gotham" size: 24.0f];
	[b append: @"And some Large Gotham Red"];
	[b append: @" with some more text"];
	
	[b pop];
	b.color = [UIColor blueColor];
	[b append: @"Back to Helvetica, but blue"];
	
	NSAttributedString* s = b.string;
	
	LINKS
	-----
	Runs of text can be made clickable by setting three properties (in
	addition to any visual style properties desired):
	
		linkTarget
		linkSelector
		linkContext
		
	The selector takes the form of:
	
		- (void) linkTapped: (YAttributedLabelLinkHit*) inHit;
		
	See YAttributedLabel.h for the declaration of YAttributedLabelLinkHit.
	
	
	TODO: Add support for paragraph styles (which would include left/right
			justification).
*/

@interface
LZAttributedStringBuilder : NSObject
{
	NSMutableAttributedString*				mString;
	NSMutableDictionary*					mCurrentAttrs;
	NSMutableArray*							mAttributeStack;
}

@property (nonatomic, retain)	UIFont*							font;
@property (nonatomic, retain)	UIColor*						color;
@property (nonatomic, assign)	CTUnderlineStyle				underlineStyle;
@property (nonatomic, retain)	id								linkTarget;
@property (nonatomic, assign)	SEL								linkSelector;
@property (nonatomic, retain)	id								linkContext;

@property (nonatomic, readonly)	NSAttributedString*				string;



+ (LZAttributedStringBuilder*)		builder;



- (void)		pop;

- (void)		append: (NSString*) inString;
- (void)		appendFormat: (NSString*) inFormat, ...;

@end

extern NSString*	kYAttributedStringBuilderKeyLinkTarget;
extern NSString*	kYAttributedStringBuilderKeyLinkSelector;
extern NSString*	kYAttributedStringBuilderKeyLinkContext;

