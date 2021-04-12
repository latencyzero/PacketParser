//
//  PDLexer.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PDLexer.h"





#import "Debug.h"
#import "PDToken.h"
#import "XParse.h"



const unichar	kCharEOF				=	-1;





PDLexer::PDLexer(NSString* inInputBuffer)
	:
	mCurrentToken(this),
	mInputBuffer(inInputBuffer),
	mCurrentIdx(0),
	mCurrentLine(1),
	mCurrentCol(1)
{
	NSSet* reservedWords = [NSSet setWithArray: @[@"block", @"field", @"marker", @"packet"]];
	setReservedWords(reservedWords);
}

NSString*
PDLexer::nameForTokenType(NSUInteger inType) const
{
	static	NSArray* sTokenTypeNames = @[
		@"«none»",					//	0
		@"«whitespace»",			//	1
		@"«»",						//	2
		@"«»",						//	3
		@"Identifier",				//	4
		@"Keyword",					//	5
		@"Hex Literal",				//	6
		@"Decimal Literal",			//	7
		@"';'",						//	8
		@"'='",						//	9
		@"':'",						//	10
		@"'+'",						//	11
		@"'-'",						//	12
		@"'{'",						//	13
		@"'}'",						//	14
		@"'('",						//	15
		@"')'",						//	16
		@"'['",						//	17
		@"']'",						//	18
	];
	
	if (inType < sTokenTypeNames.count)
	{
		NSString* s = [sTokenTypeNames objectAtIndex: inType];
		return s;
	}
	else
	{
		return [NSString stringWithFormat: @"«%02lu»", inType];
	}
}

/**
	Grab the character at the current index + inLookAheadDepth - 1.
*/

unichar
PDLexer::lookAhead(NSUInteger inLookAheadDepth)
{
	NSUInteger idx = mCurrentIdx + inLookAheadDepth - 1;
	if (idx >= mInputBuffer.length)
	{
		return kCharEOF;
	}
	
	unichar c = [mInputBuffer characterAtIndex: idx];
	return c;
}

void
PDLexer::consume(NSUInteger inNumChars)
{
	mCurrentIdx += inNumChars;
	mCurrentCol += inNumChars;
}

void
PDLexer::match(unichar inC)
{
	unichar c = lookAhead();
	if (c == inC)
	{
		consume();
	}
	else
	{
		NSString* s = [NSString stringWithFormat: @"Expected '%C', found '%C'", inC, c];
		throw XParse(__FILE__, __LINE__, s);
	}
}


PDToken
PDLexer::nextToken()
{
	unichar c;
	while ((c = lookAhead()) != kCharEOF)
	{
		mCurrentToken = PDToken(this, mCurrentIdx, mCurrentLine, mCurrentCol);
		
		switch (c)
		{
			case ' ':
			case '\t':
			case '\n':
			case '\r':
			{
				whitespace();
				continue;
			}
			
			case '{': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeOpenBrace);		return mCurrentToken;
			case '}': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeCloseBrace);		return mCurrentToken;
			case '(': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeOpenParen);		return mCurrentToken;
			case ')': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeCloseParen);		return mCurrentToken;
			case '[': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeOpenBracket);		return mCurrentToken;
			case ']': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeCloseBracket);		return mCurrentToken;
			case ';': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeSemicolon);		return mCurrentToken;
			case '=': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeEqual);			return mCurrentToken;
			case ':': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeColon);			return mCurrentToken;
			case '+': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypePlus);				return mCurrentToken;
			case '-': consume(); mCurrentToken.finish(mCurrentIdx, kTokenTypeMinus);			return mCurrentToken;
			
			case '0':
			{
				unichar c2 = lookAhead(2);
				if (c2 == 'x')
				{
					hexLiteral();
					return mCurrentToken;
				}
				else if ('0' <= c2 && c2 <= '9')
				{
					decimalLiteral();
					return mCurrentToken;
				}
				
				break;
			}
			
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
			{
				decimalLiteral();
				break;
			}
			
			default:
			{
				identifier();
				return mCurrentToken;
			}
		}
	}
	
	return PDToken(this, mCurrentIdx, mCurrentLine, mCurrentCol, kTokenTypeEOF);
}

/**
	Consumes whitespace without creating a token for it. Keeps track of line
	and column number.
*/

void
PDLexer::whitespace()
{
	while (true)
	{
		unichar c = lookAhead();
		switch (c)
		{
			case ' ':
			case '\t':
			{
				consume();
				continue;
			}
			
			case '\n':
			case '\r':
			{
				consume();
				unichar c2 = lookAhead();
				if (c == '\r' && c2 == '\n')
				{
					consume();
				}
				
				mCurrentLine += 1;
				mCurrentCol = 1;
				continue;
			}
			
			default:
			{
				return;
			}
		}
	}
}


void
PDLexer::hexLiteral()
{
	consume(2);
	while (true)
	{
		unichar c = lookAhead();
		if (!(('0' <= c && c <= '9') || ('a' <= c && c <= 'f') || ('A' <= c && c <= 'F')))
		{
			//	End of literal…
			
			mCurrentToken.finish(mCurrentIdx, kTokenTypeHexLiteral);
			return;
		}
		
		consume();
	}
	
}

void
PDLexer::decimalLiteral()
{
	consume(1);
	while (true)
	{
		unichar c = lookAhead();
		if (!('0' <= c && c <= '9'))
		{
			//	End of literal…
			
			mCurrentToken.finish(mCurrentIdx, kTokenTypeDecimalLiteral);
			return;
		}
		
		consume();
	}
	
}

void
PDLexer::identifier()
{
	unichar c = lookAhead();
	if (!isFirstIdentifierChar(c))
	{
		NSString* msg = [NSString stringWithFormat: @"Unexpected identifier character [%C] line: %lu col: %lu", c, mCurrentLine, mCurrentCol];
		throw XParse(__FILE__, __LINE__, msg);
	}
	
	consume();
	
	while (true)
	{
		c = lookAhead();
		if (!isIdentifierChar(c))
		{
			//	Hit a non-identifier character, finish…
			
			//	Is the identifier is a keyword?
			
			mCurrentToken.finish(mCurrentIdx, kTokenTypeIdentifier);
			NSString* ident = mCurrentToken.string();
			if ([mReservedWords containsObject: ident])
			{
				mCurrentToken.setType(kTokenTypeReservedWord);
			}
			return;
		}
		
		consume();
	}
}

bool
PDLexer::isFirstIdentifierChar(unichar inC)
{
	//	Simple test for now…
	
	return ('a' <= inC && inC <= 'z') || ('A' <= inC && inC <= 'Z');
}

bool
PDLexer::isIdentifierChar(unichar inC)
{
	//	Simple test for now…
	
	bool t1 = 'a' <= inC && inC <= 'z';
	bool t2 = 'A' <= inC && inC <= 'Z';
	bool t3 = '0' <= inC && inC <= '9';
	bool t4 = inC == '.';
	return  t1 || t2 || t3 || t4;
}

