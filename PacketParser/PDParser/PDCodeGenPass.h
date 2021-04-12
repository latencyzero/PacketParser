//
//  PDCodeGenPass.h
//  PacketParser
//
//  Created by Roderick Mann on 1/18/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDCodeGenPass_h__
#define __PDCodeGenPass_h__

#import "PDTreeVisitor.h"


namespace llvm
{
	class Function;
}


class PDScope;


class
PDCodeGenPass : public PDTreeVisitor
{
public:
	PDCodeGenPass(PDScope* inGlobalScope);

	void						walk(PDTreeNode* inTree);

protected:
	
	llvm::Function*				completionProcForFieldNode(PDDecoderNode* inNode);
	
	virtual void				visitPacket(PDPacketNode* inNode);
	virtual void				visitPacketAfter(PDPacketNode* inNode);
	virtual void				visitField(PDFieldNode* inNode);
	virtual void				visitFieldAfter(PDFieldNode* inNode);
	virtual void				visitBlock(PDBlockNode* inNode);
	virtual void				visitBlockAfter(PDBlockNode* inNode);
	virtual void				visitDefinition(PDTreeNode* inNode);
	virtual void				visitIdent(PDIdentNode* inNode);
	virtual void				visitType(PDTypeNode* inNode);
};

#endif	//	__PDCodeGenPass_h__
