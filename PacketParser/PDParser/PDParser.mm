//
//  PDParser.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PDParser.h"




#import "PDLexer.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "XParse.h"




PDParser::PDParser(PDLexer* inLexer)
	:
	mLexer(inLexer),
	mLookahead(inLexer)
{
	//	Prime the parser…
	
	consume();
}

/**
*/

PDToken
PDParser::laToken(NSUInteger inCount)
{
	return mLookahead;
}

PDToken
PDParser::match(NSUInteger inTokenType)
{
	if (mLookahead.type() == inTokenType)
	{
		PDToken matchedToken = mLookahead;
		consume();
		
		return matchedToken;
	}
	else
	{
		throw XUnexpected(laToken(), inTokenType);
	}
}

PDToken
PDParser::match(NSString* inReservedWord)
{
	if (mLookahead.isReserved(inReservedWord))
	{
		PDToken matchedToken = mLookahead;
		consume();
		
		return matchedToken;
	}
	else
	{
		throw XUnexpected(laToken(), inReservedWord);
	}
}

void
PDParser::consume()
{
	mLookahead = mLexer->nextToken();
}


PDTreeNode*
PDParser::definition()
{
	PDTreeNode* definition = new PDTreeNode(mLexer);
	mCurrentNode = definition;
	
	while (true)
	{
		if (laToken().isEOF())
		{
			break;
		}
		else if (laToken().isReserved(@"packet"))
		{
			PDTreeNode* packet = packetDef();
			definition->addChild(packet);
		}
	}
	
	return definition;
}

/**
	packetDef: 'packet' Identifier OpenBrace fields CloseBrace
*/

PDPacketNode*
PDParser::packetDef()
{
	PDToken tok = match(@"packet");						//	'packet'
	
	PDPacketNode* packet = new PDPacketNode(tok);
	
	PDTreeNode* node = identifier();					//	ident
	packet->addChild(node);
	
	match(kTokenTypeOpenBrace);							//	'{'
	
	uint16_t		memberIndex = 0;
	while (true)										//	fields: field*
	{
		if (laToken().isReserved(@"field"))
		{
			PDFieldNode* fieldNode = field();
			packet->add(fieldNode);
		}
		else if (laToken().isReserved(@"block"))
		{
			PDBlockNode* blockNode = block();
			packet->add(blockNode);
		}
		else if (laToken().type() == kTokenTypeIdentifier)
		{
			PDMemberNode* memberNode = member();
			memberNode->setIndex(memberIndex++);
			packet->addChild(memberNode);
		}
		else
		{
			break;
		}
	}
	
	match(kTokenTypeCloseBrace);						//	'}'
	
	return packet;
}

PDIdentNode*
PDParser::identifier()
{
	PDToken tok = match(kTokenTypeIdentifier);
	PDIdentNode* node = new PDIdentNode(tok);
	return node;
}



/**
	member:	ident ident ';'
*/

PDMemberNode*
PDParser::member()
{
	//	Member type…
	
	PDToken tok = match(kTokenTypeIdentifier);					//	ident (typename)
	PDMemberNode* node = new PDMemberNode(tok);
	PDTypeNode* typeNode = new PDTypeNode(tok);
	node->addChild(typeNode);
	
	//	Member name…
	
	tok = match(kTokenTypeIdentifier);					//	ident (member name)
	PDIdentNode* identNode = new PDIdentNode(tok);
	node->addChild(identNode);
	
	//	Semicolon…
	
	tok = match(kTokenTypeSemicolon);					//	';'
	
	return node;
}


/**
	field:	'field' ident ident ';'
*/

PDFieldNode*
PDParser::field()
{
	PDToken tok = match(@"field");						//	'field'
	
	PDFieldNode* field = new PDFieldNode(tok);
	
	tok = match(kTokenTypeIdentifier);					//	ident (typename)
	PDTypeNode* typeNode = new PDTypeNode(tok);
	field->addChild(typeNode);
	
	//	Field name…
	
	tok = match(kTokenTypeIdentifier);					//	ident (field name)
	PDIdentNode* identNode = new PDIdentNode(tok);
	field->addChild(identNode);
	
	//	Semicolon…
	
	tok = match(kTokenTypeSemicolon);					//	';'
	
	return field;
}

/**
	block:	'block' ident '(' ident ')' ';'				//	For now, can only pass the name of a prior field, later, expr
*/

PDBlockNode*
PDParser::block()
{
	PDToken tok = match(@"block");						//	'block'
	
	PDBlockNode* block = new PDBlockNode(tok);
	
	//	Field name…
	
	tok = match(kTokenTypeIdentifier);					//	ident (block name)
	PDIdentNode* identNode = new PDIdentNode(tok);
	block->addChild(identNode);
	
	tok = match(kTokenTypeOpenParen);					//	'('
	
	match(kTokenTypeIdentifier);						//	ident (for now, expr later)
	identNode = new PDIdentNode(tok);
	block->addChild(identNode);
	
	tok = match(kTokenTypeCloseParen);					//	')'
	
	tok = match(kTokenTypeSemicolon);					//	';'
	
	return block;
}
