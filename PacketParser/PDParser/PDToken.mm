//
//  PDToken.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PDToken.h"




#import "PDLexer.h"







PDToken&
PDToken::operator=(const PDToken& inRHS)
{
	mLexer = inRHS.mLexer;
	mType = inRHS.mType;
	mStartIdx = inRHS.mStartIdx;
	mLength = inRHS.mLength;
	mLine = inRHS.mLine;
	mCol = inRHS.mCol;
	
	return *this;
}

NSString*
PDToken::inputBuffer() const
{
	return mLexer->inputBuffer();
}


PDToken::PDToken(PDLexer* inLexer, NSUInteger inStartIdx, NSUInteger inLine, NSUInteger inCol, NSUInteger inType)
	:
	mLexer(inLexer),
	mType(inType),
	mStartIdx(inStartIdx),
	mLength(0),
	mLine(inLine),
	mCol(inCol)
{
}

void
PDToken::finish(NSUInteger inEndIdx, NSUInteger inTokenType)
{
	mLength = inEndIdx - mStartIdx;
	mType = inTokenType;
}

NSString*
PDToken::string() const
{
	NSRange r = NSMakeRange(startIdx(), length());
	NSString* s = [inputBuffer() substringWithRange: r];
	return s;
}

std::string
PDToken::cstring() const
{
	NSString* s = string();
	std::string cs = [s cStringUsingEncoding: NSUTF8StringEncoding];
	return cs;
}

bool
PDToken::isReserved(NSString* inWord) const
{
	if (type() != kTokenTypeReservedWord)
	{
		return false;
	}
	
	return [string() isEqualToString: inWord];
}

NSString*
PDToken::nameForType(NSUInteger inType)	const
{
	return mLexer->nameForTokenType(inType);
}

NSString*
PDToken::nameForType() const
{
	return nameForType(type());
}

NSString*
PDToken::diagnosticString() const
{
	NSString* typeS = nil;
	if (type() == kTokenTypeReservedWord)
	{
		typeS = [NSString stringWithFormat: @"'%@'", string()];
	}
	else if (type() == kTokenTypeIdentifier)
	{
		typeS = [NSString stringWithFormat: @"%@ '%@'", nameForType(), string()];
	}
	else
	{
		typeS = nameForType();
	}
	
	NSString* s = [NSString stringWithFormat: @"%@ at %4lu:%-3lu", typeS, mLine, mCol];
	return s;
}

