//
//  PDParser.h
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDParser_h__
#define __PDParser_h__





#import "PDToken.h"


class PDBlockNode;
class PDFieldNode;
class PDIdentNode;
class PDLexer;
class PDMemberNode;
class PDPacketNode;
class PDTreeNode;


/**

	definition: packetDef* EOF
	
	packetDef: 'packet' Identifier '{' members '}'
	
	members: (field | block | member)*
	
	field:	'field' ident ident ';'
	
	block:	'block' ident '(' ident ')' ';'				//	For now, can only pass the name of a prior field, later, expr
		
	member:	ident ident ';'
*/

class
PDParser
{
public:
	PDParser(PDLexer* inLexer);
	
	PDTreeNode*			definition();		//	Entry rule
	
protected:
	PDToken				laToken(NSUInteger inCount = 0);
	PDToken				match(NSUInteger inTokenType);
	PDToken				match(NSString* inReservedWord);
	void				consume();
	
	PDPacketNode*		packetDef();
	PDIdentNode*		identifier();
	PDFieldNode*		field();
	PDBlockNode*		block();
	PDMemberNode*		member();
	
private:
	PDLexer*			mLexer;
	PDTreeNode*			mCurrentNode;
	PDToken				mLookahead;
};

#endif	//	__PDParser_h__
