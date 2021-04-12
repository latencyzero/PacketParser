//
//  XParse.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "XParse.h"





#import "PDLexer.h"






XUnexpected::XUnexpected(const PDToken& inFoundToken, NSUInteger inExpectedType)
	:
	mFoundToken(inFoundToken),
	mExpectedType(inExpectedType)
{
	NSString* msg = [NSString stringWithFormat: @"Expected %@, found %@", inFoundToken.nameForType(inExpectedType), inFoundToken.diagnosticString()];
	setMsg(msg);
}

XUnexpected::XUnexpected(const PDToken& inFoundToken, NSString* inReservedWord)
	:
	mFoundToken(inFoundToken),
	mExpectedType(kTokenTypeReservedWord)
{
	NSString* msg = [NSString stringWithFormat: @"Expected '%@', found %@", inReservedWord, inFoundToken.diagnosticString()];
	setMsg(msg);
}



XUnknownType::XUnknownType(const PDToken& inToken)
	:
	mToken(inToken)
{
	NSString* msg = [NSString stringWithFormat: @"Unknown type '%@' at %lu:%lu",
									inToken.string(), inToken.line(), inToken.col()];
	setMsg(msg);
}
