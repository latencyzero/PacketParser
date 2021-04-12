//
//  PDFirstPassWalker.h
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDFirstPassWalker_h__
#define __PDFirstPassWalker_h__

#import "PDTreeVisitor.h"

//
//	Library Imports
//

#import "llvm/IR/IRBuilder.h"


namespace llvm
{
	class Constant;
	class LLVMContext;
	class Module;
};

class PDTreeNode;


class PDScope;


class
PDFirstPassWalker : public PDTreeVisitor
{
public:
	PDFirstPassWalker(PDScope* inGlobalScope);
	
	void				walk(PDTreeNode* inTree);
	
protected:
	virtual void		visitPacket(PDPacketNode* inNode);
	virtual void		visitPacketAfter(PDPacketNode* inNode);
	virtual void		visitField(PDFieldNode* inNode);
	virtual void		visitBlock(PDBlockNode* inNode);
	virtual void		visitDefinition(PDTreeNode* inNode);
	virtual void		visitIdent(PDIdentNode* inNode);
	virtual void		visitType(PDTypeNode* inNode);
	
	
	
	
	void				dumpSubtree(const PDTreeNode* inTree, NSUInteger inDepth);

	llvm::Constant*		createStringConstant(const std::string& inString);

private:
	llvm::Argument*		mDecodeContext;					///< Argument passed in
	
	llvm::Function*		mCreatePacket;
	llvm::Function*		mCreateField;
};




#endif	//	__PDFirstPassWalker_h__
