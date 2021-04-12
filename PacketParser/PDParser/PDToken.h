//
//  PDToken.h
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDToken_h__
#define __PDToken_h__

#import <string>



class PDLexer;

const NSUInteger	kTokenTypeNone					=	0;
const NSUInteger	kTokenTypeEOF					=	-1;





class
PDToken
{
public:
	PDToken(PDLexer* inLexer)
		:
		mLexer(inLexer),
		mType(kTokenTypeNone),
		mStartIdx(0),
		mLength(0),
		mLine(0),
		mCol(0)
	{
	}
	
	PDToken(const PDToken& inRHS)
	{
		*this = inRHS;
	}
	
	PDToken(PDLexer* inLexer, NSUInteger inStartIdx, NSUInteger inLine, NSUInteger inCol, NSUInteger inType = kTokenTypeNone);
	
	PDToken&		operator=(const PDToken& inRHS);
	
	void			finish(NSUInteger inEndIdx, NSUInteger inTokenType);
	bool			isFinished() const										{ return mLength > 0; }
	
	NSUInteger		type()							const					{ return mType; }
	void			setType(NSUInteger inVal)								{ mType = inVal; }
	
	NSUInteger		startIdx()						const					{ return mStartIdx; }
	NSUInteger		length()						const					{ return mLength; }
	NSUInteger		line()							const					{ return mLine; }
	NSUInteger		col()							const					{ return mCol; }

	NSString*		string()						const;
	std::string		cstring()						const;
	bool			isReserved(NSString* inWord)	const;
	bool			isEOF()							const					{ return type() == kTokenTypeEOF; }
	
	NSString*		nameForType()					const;
	NSString*		nameForType(NSUInteger inType)	const;
	NSString*		diagnosticString()				const;
	
protected:
	NSString*		inputBuffer()					const;
	
private:
	PDLexer*				mLexer;
	NSUInteger				mType;
	NSUInteger				mStartIdx;
	NSUInteger				mLength;
	NSUInteger				mLine;
	NSUInteger				mCol;
};



#endif	//	__PDToken_h__
