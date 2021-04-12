//
//  PDLexer.h
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDLexer_h__
#define __PDLexer_h__




#import "PDToken.h"





class
PDLexer
{
public:
	PDLexer(NSString* inInputBuffer);
	
	void					setReservedWords(NSSet* inSet)							{ mReservedWords = inSet; }
	
	PDToken					nextToken();
	NSString*				nameForTokenType(NSUInteger inType) const;
	
protected:
	NSString*				inputBuffer() const										{ return mInputBuffer; }
	
	unichar					lookAhead(NSUInteger inLookAheadDepth = 1);
	void					consume(NSUInteger inNumChars = 1);
	void					match(unichar inC);
	
	void					whitespace();
	void					identifier();
	bool					isFirstIdentifierChar(unichar inC);
	bool					isIdentifierChar(unichar inC);
	void					hexLiteral();
	void					decimalLiteral();
	
private:
	NSString*				mInputBuffer;
	NSUInteger				mCurrentIdx;
	NSUInteger				mCurrentLine;
	NSUInteger				mCurrentCol;
	PDToken					mCurrentToken;
	NSSet*					mReservedWords;
	
	friend class PDToken;
};

const NSUInteger	kTokenTypeWhitespace			=	1;
const NSUInteger	kTokenTypeIdentifier			=	4;
const NSUInteger	kTokenTypeReservedWord			=	5;
const NSUInteger	kTokenTypeHexLiteral			=	6;
const NSUInteger	kTokenTypeDecimalLiteral		=	7;

const NSUInteger	kTokenTypeSemicolon				=	8;
const NSUInteger	kTokenTypeEqual					=	9;
const NSUInteger	kTokenTypeColon					=	10;
const NSUInteger	kTokenTypePlus					=	11;
const NSUInteger	kTokenTypeMinus					=	12;
const NSUInteger	kTokenTypeOpenBrace				=	13;
const NSUInteger	kTokenTypeCloseBrace			=	14;
const NSUInteger	kTokenTypeOpenParen				=	15;
const NSUInteger	kTokenTypeCloseParen			=	16;
const NSUInteger	kTokenTypeOpenBracket			=	17;
const NSUInteger	kTokenTypeCloseBracket			=	18;

#endif	//	__PDLexer_h__
