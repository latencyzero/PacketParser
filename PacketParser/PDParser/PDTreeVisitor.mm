//
//  PDTreeVisitor.mm
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "PDTreeVisitor.h"



//
//	Library Imports
//

#import "llvm/IR/IRBuilder.h"
#import "llvm/IR/Module.h"

#import "Debug.h"

//
//	Project Imports
//

#import "PDSymbol.h"



PDTreeVisitor::PDTreeVisitor(PDScope* inGlobalScope)
	:
	mGlobalScope(inGlobalScope),
	mCurrentScope(inGlobalScope),
	mBuilder(llvmContext())
{
	mNULL = llvm::Constant::getNullValue(builder().getInt8PtrTy());
}

llvm::LLVMContext&
PDTreeVisitor::llvmContext() const
{
	llvm::LLVMContext& ctx = mGlobalScope->module()->getContext();
	return ctx;
}

llvm::Module*
PDTreeVisitor::module() const
{
	return globalScope()->module();
}

llvm::Function*
PDTreeVisitor::resolveMethod(const std::string& inName) const
{
	PDSymbol* sym = currentScope()->resolve(inName);								//	TODO: Prevent this from being redefined
	PDMethodSymbol* methodSym = dynamic_cast<PDMethodSymbol*> (sym);
	if (methodSym == NULL)
	{
		return NULL;
	}
	
	llvm::Function* method = methodSym->function();
	return method;
}

llvm::Type*
PDTreeVisitor::resolvePointerToType(const std::string& inName) const
{
	PDType* typeSym = currentScope()->resolveType(inName);
	if (typeSym == NULL)
	{
		return NULL;
	}
	
	llvm::Type* type = typeSym->llvmType();
	llvm::Type* ptrType = llvm::PointerType::get(type, 0);
	return ptrType;
}

llvm::Type*
PDTreeVisitor::resolvePointerToMethod(const std::string& inName) const
{
	llvm::Function* func = resolveMethod(inName);
	llvm::Type* type = func->getType();
	llvm::Type* ptrType = llvm::PointerType::get(type, 0);
	return ptrType;
}

void
PDTreeVisitor::pushScope(PDScope* inVal)
{
	NSLogDebug(@"Pushing scope %s", inVal->scopeName().c_str());
	setCurrentScope(inVal);
}

void
PDTreeVisitor::popScope()
{
	PDScope* scope = currentScope()->enclosingScope();
	NSLogDebug(@"Popping scope %s to %s", currentScope()->scopeName().c_str(), scope->scopeName().c_str());
	setCurrentScope(scope);
}

llvm::Function*
PDTreeVisitor::buildFunction(const std::string& inName, const std::string& inReturnTypeName, const std::string& inArg1TypeName)
{
	llvm::Type* returnType = currentScope()->resolveType(inReturnTypeName)->llvmType();
	llvm::Type* arg1Type = currentScope()->resolveType(inArg1TypeName)->llvmType();
	
	llvm::Type* argTypes[] = { arg1Type };
	llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, argTypes, false);
	
	llvm::Function* func = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, inName, globalScope()->module());
	return func;
}

llvm::Function*
PDTreeVisitor::buildFunction(const std::string& inName, const std::string& inReturnTypeName, const std::string& inArg1TypeName, const std::string& inArg2TypeName)
{
	llvm::Type* returnType = currentScope()->resolveType(inReturnTypeName)->llvmType();
	llvm::Type* arg1Type = currentScope()->resolveType(inArg1TypeName)->llvmType();
	llvm::Type* arg2Type = currentScope()->resolveType(inArg2TypeName)->llvmType();
	
	llvm::Type* argTypes[] = { arg1Type, arg2Type };
	llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, argTypes, false);
	
	llvm::Function* func = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, inName, globalScope()->module());
	return func;
}

/*
llvm::AllocaInst*			buildDeclareLocal(llvm::Type* inType);
llvm::AllocaInst*			buildDeclareLocalPtr(llvm::Type* inType);
*/

llvm::CallInst*
PDTreeVisitor::buildCall(const std::string& inName, llvm::ArrayRef<llvm::Value*> inArgs)
{
	llvm::Function* func = resolveMethod(inName);
	return builder().CreateCall(func, inArgs);
}

llvm::CallInst*
PDTreeVisitor::buildCall(const std::string& inName, llvm::Value* inArg1)
{
	llvm::Value* args[] = { inArg1 };
	return buildCall(inName, args);
}

llvm::CallInst*
PDTreeVisitor::buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2)
{
	llvm::Value* args[] = { inArg1, inArg2 };
	return buildCall(inName, args);
}

llvm::CallInst*
PDTreeVisitor::buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2, llvm::Value* inArg3)
{
	llvm::Value* args[] = { inArg1, inArg2, inArg3 };
	return buildCall(inName, args);
}

llvm::CallInst*
PDTreeVisitor::buildCall(const std::string& inName, llvm::Value* inArg1, llvm::Value* inArg2, llvm::Value* inArg3, llvm::Value* inArg4)
{
	llvm::Value* args[] = { inArg1, inArg2, inArg3, inArg4 };
	return buildCall(inName, args);
}

llvm::Value*
PDTreeVisitor::buildMallocStructCall(const std::string& inStructTypeName)
{
	assert(false && "Not yet implemented");
	//	get the size of the named struct from a method on PDClassSymbol (TBD)
	//	build a call to malloc
	//	build a cast to the struct pointer type
	//
//	llvm::Value* mallocResult = buildCall("malloc",
	return NULL;
}

llvm::Value*
PDTreeVisitor::buildCastToType(llvm::Value* inVal, const std::string& inDestTypeName)
{
	PDType* type = currentScope()->resolveType(inDestTypeName);
	llvm::Type* llvmType = type->llvmType();
	llvm::Value* cast = builder().CreateBitCast(inVal, llvmType);
	return cast;
}

uint64_t
PDTreeVisitor::llvmSizeOf(llvm::Type* inType) const
{
	llvm::DataLayout* dl = new llvm::DataLayout(module());
	uint64_t s = dl->getTypeStoreSize(inType);
	return s;
}

llvm::Value*
PDTreeVisitor::llvmValueOfSizeOf(llvm::Type* inType) const
{
	llvm::DataLayout* dl = new llvm::DataLayout(module());
	uint64_t s = dl->getTypeStoreSize(inType);
	llvm::Value* val = llvm::ConstantInt::get(llvmContext(), llvm::APInt(64, s));
	return val;
}

llvm::Value*
PDTreeVisitor::buildStringConstant(const std::string& inString, const std::string& inName)
{
	llvm::Constant* stringConstant = llvm::ConstantDataArray::getString(llvmContext(), inString);
	llvm::GlobalVariable* globalString = new llvm::GlobalVariable(*module(),
																	stringConstant->getType(),
																	true,
																	llvm::GlobalValue::PrivateLinkage,
																	stringConstant,
																	inName + ".str");
	
	llvm::Value* zero = llvm::ConstantInt::get(llvm::Type::getInt32Ty(llvmContext()), 0);
	llvm::Value* indices[] = { zero, zero };
	
	llvm::Value* llvmStringPtr = builder().CreateInBoundsGEP(globalString, indices, inName + ".gVar");
	//llvm::ConstantExpr::getGetElementPtr(globalString, indices, true);
	return llvmStringPtr;
}


void
PDTreeVisitor::visitPacketAfter(PDPacketNode* inNode)
{
}

void
PDTreeVisitor::visitMember(PDMemberNode* inNode)
{
}

void
PDTreeVisitor::visitMemberAfter(PDMemberNode* inNode)
{
}

void
PDTreeVisitor::visitFieldAfter(PDFieldNode* inNode)
{
}

void
PDTreeVisitor::visitBlockAfter(PDBlockNode* inNode)
{
}

void
PDTreeVisitor::visitDefinitionAfter(PDTreeNode* inNode)
{
}

void
PDTreeVisitor::visitIdentAfter(PDIdentNode* inNode)
{
}

void
PDTreeVisitor::visitTypeAfter(PDTypeNode* inNode)
{
}

std::vector<llvm::Value*>
PDTreeVisitor::llvmIndexes(const std::vector<uint32_t>& inIndexes) const
{
	std::vector<llvm::Value*> indexes;
	
	for (auto iter = inIndexes.begin(); iter != inIndexes.end(); ++iter)
	{
		llvm::Value* v = const_cast<PDTreeVisitor*>(this)->builder().getInt32(*iter);
		indexes.push_back(v);
	}
	
	return indexes;
}

