//
//  PDDeclarationPass.h
//  PacketParser
//
//  Created by Roderick Mann on 1/17/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDDeclarationPass_h__
#define __PDDeclarationPass_h__

#import "PDTreeVisitor.h"


//
//	Library Imports
//

#import "llvm/IR/IRBuilder.h"





namespace llvm
{
	class FunctionType;
	class LLVMContext;
	class Module;
	class Type;
}

class PDScope;





class
PDDeclarationPass : public PDTreeVisitor
{
public:
	PDDeclarationPass(PDScope* inGlobalScope);

	void						walk(PDTreeNode* inTree);

protected:
	virtual void				visitPacket(PDPacketNode* inNode);
	virtual void				visitPacketAfter(PDPacketNode* inNode);
	virtual void				visitField(PDFieldNode* inNode);
	virtual void				visitFieldAfter(PDFieldNode* inNode);
	virtual void				visitBlock(PDBlockNode* inNode);
	virtual void				visitBlockAfter(PDBlockNode* inNode);
	virtual void				visitDefinition(PDTreeNode* inNode);
	virtual void				visitIdent(PDIdentNode* inNode);
	virtual void				visitType(PDTypeNode* inNode);

private:
	
};



#endif	//	__PDDeclarationPass_h__
