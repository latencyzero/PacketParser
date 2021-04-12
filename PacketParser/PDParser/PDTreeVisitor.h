//
//  PDTreeVisitor.h
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDTreeVisitor_h__
#define __PDTreeVisitor_h__


//
//	Library Imports
//

#import "llvm/IRBuilder.h"





namespace llvm
{
	class AllocaInst;
	class CallInst;
	class Function;
	class FunctionType;
	class LLVMContext;
	class Module;
	class Type;
	class Value;
}


class PDBlockNode;
class PDDecoderNode;
class PDFieldNode;
class PDIdentNode;
class PDMemberNode;
class PDPacketNode;
class PDScope;
class PDTreeNode;
class PDTypeNode;

class
PDTreeVisitor
{
public:
	PDTreeVisitor(PDScope* inGlobalScope);
	
protected:
	PDScope*					globalScope()										const	{ return mGlobalScope; }
	PDScope*					currentScope()										const	{ return mCurrentScope; }
	void						setCurrentScope(PDScope* inVal)								{ mCurrentScope = inVal; }
	
	void						pushScope(PDScope* inVal);
	void						popScope();
	
	llvm::LLVMContext&			llvmContext()										const;
	llvm::Module*				module()											const;
	llvm::Function*				resolveMethod(const std::string& inName)			const;
	llvm::Type*					resolvePointerToType(const std::string& inName)		const;
	llvm::Type*					resolvePointerToMethod(const std::string& inName)	const;
	llvm::IRBuilder<>&			builder()													{ return mBuilder; }
	
	llvm::Function*				buildFunction(const std::string& inName, const std::string& inReturnTypeName, const std::string& inArg1TypeName);
	llvm::Function*				buildFunction(const std::string& inName, const std::string& inReturnTypeName, const std::string& inArg1TypeName, const std::string& inArg2TypeName);
	
	llvm::AllocaInst*			buildDeclareLocal(llvm::Type* inType);
	llvm::AllocaInst*			buildDeclareLocalPtr(llvm::Type* inType);
	
	llvm::CallInst*				buildCall(const std::string& inName, llvm::ArrayRef<llvm::Value*> inArgs);
	llvm::CallInst*				buildCall(const std::string& inName, llvm::Value* inArg1);
	llvm::CallInst*				buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2);
	llvm::CallInst*				buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2, llvm::Value* inArg3);
	llvm::CallInst*				buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2, llvm::Value* inArg3, llvm::Value* inArg4);
	
	llvm::Value*				buildCastToType(llvm::Value* inVal, const std::string& inDestTypeName);

	/**
		Builds a call to malloc for the given struct type, allocating space for the structure
		and casting the result to the structure pointer type.
	*/
	
	llvm::Value*				buildMallocStructCall(const std::string& inStructTypeName);
	
	uint64_t					llvmSizeOf(llvm::Type* inType) const;
	llvm::Value*				llvmValueOfSizeOf(llvm::Type* inType) const;
	
	llvm::Value*				buildStringConstant(const std::string& inString, const std::string& inName = "");
	
	virtual void				visitPacket(PDPacketNode* inNode)				=	0;
	virtual void				visitPacketAfter(PDPacketNode* inNode);
	virtual void				visitMember(PDMemberNode* inNode);
	virtual void				visitMemberAfter(PDMemberNode* inNode);
	virtual void				visitField(PDFieldNode* inNode)					=	0;
	virtual void				visitFieldAfter(PDFieldNode* inNode);
	virtual void				visitBlock(PDBlockNode* inNode)					=	0;
	virtual void				visitBlockAfter(PDBlockNode* inNode);
	virtual void				visitDefinition(PDTreeNode* inNode)				=	0;
	virtual void				visitDefinitionAfter(PDTreeNode* inNode);
	virtual void				visitIdent(PDIdentNode* inNode)					=	0;
	virtual void				visitIdentAfter(PDIdentNode* inNode);
	virtual void				visitType(PDTypeNode* inNode)					=	0;
	virtual void				visitTypeAfter(PDTypeNode* inNode);

	llvm::Value*				mNULL;
	
	std::vector<llvm::Value*>	llvmIndexes(const std::vector<uint32_t>& inIndexes)			const;
	
private:
	PDScope*					mGlobalScope;
	PDScope*					mCurrentScope;
	llvm::IRBuilder<>			mBuilder;


	friend class PDBlockNode;
	friend class PDFieldNode;
	friend class PDIdentNode;
	friend class PDMemberNode;
	friend class PDPacketNode;
	friend class PDTreeNode;
	friend class PDTypeNode;
};

#endif	//	__PDTreeVisitor_h__
