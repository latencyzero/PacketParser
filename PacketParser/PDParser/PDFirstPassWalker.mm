//
//  PDFirstPassWalker.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "PDFirstPassWalker.h"

//
//	Library Imports
//

#import "llvm/IR/Constants.h"
#import "llvm/IR/Module.h"
#import "llvm/IR/Verifier.h"

#import "LZUtils.h"

//
//	Project Imports
//

#import "DecoderRuntime.h"
#import "PDSymbol.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "XParse.h"





PDFirstPassWalker::PDFirstPassWalker(PDScope* inGlobalScope)
	:
	PDTreeVisitor(inGlobalScope)
{
	//	Build our runtime support externals…
	
	//	void* createPacket(void* inDecoderContext);
	
	std::vector<llvm::Type*>		argTypes;
	argTypes.push_back(llvm::Type::getInt8PtrTy(llvmContext()));
	llvm::FunctionType* funcType = llvm::FunctionType::get(llvm::Type::getInt8PtrTy(llvmContext()), argTypes, false);
	
	mCreatePacket = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "createPacket", module());
	
	//	void* createField(i8* inDecoderContext, i8* inType, i8* inName);
	
	argTypes.clear();
	argTypes.push_back(llvm::Type::getInt8PtrTy(llvmContext()));
	argTypes.push_back(llvm::Type::getInt8PtrTy(llvmContext()));
	argTypes.push_back(llvm::Type::getInt8PtrTy(llvmContext()));
	funcType = llvm::FunctionType::get(llvm::Type::getInt8PtrTy(llvmContext()), argTypes, false);
	mCreateField = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "createField", module());
}


void
PDFirstPassWalker::walk(PDTreeNode* inTree)
{
	inTree->visit(this);
	
	for (auto iter = inTree->children().begin(); iter != inTree->children().end(); ++iter)
	{
		PDTreeNode* node = const_cast<PDTreeNode*> (*iter);
		node->visit(this);
	}
	
	inTree->visitAfter(this);
}

#pragma mark -
#pragma mark • Individual Visitors

void
PDFirstPassWalker::visitPacket(PDPacketNode* inPacketNode)
{
	NSLog(@"visitPacket");
	
	//	Define a function for the app to call…
	//
	//	void decodePacket(void* inDecoderContext);
	
	std::vector<llvm::Type*>		argTypes;
	argTypes.push_back(llvm::Type::getInt8PtrTy(llvmContext()));
	llvm::FunctionType* funcType = llvm::FunctionType::get(llvm::Type::getVoidTy(llvmContext()), argTypes, false);
	
	llvm::Function* decodePacketFunc = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, "decodePacket", module());
	
	//	Name the argument…
	
	llvm::Function::arg_iterator argIter = decodePacketFunc->arg_begin();
	mDecodeContext = argIter;
	mDecodeContext->setName("inContext");
	
	//	Now add a BasicBlock (of code) to our function definition…
	
	llvm::BasicBlock* bb = llvm::BasicBlock::Create(llvmContext(), "entry", decodePacketFunc);
	builder().SetInsertPoint(bb);
	
	//	Emit a call to createPacket…
	
	std::vector<llvm::Value*>			args;
	args.push_back(mDecodeContext);
	llvm::Value* packet = builder().CreateCall(mCreatePacket, args, "packet");
	
	//	Get the packet name…
	
	PDTreeNode* name = inPacketNode->name();
	NSString* s = name->token().string();
	NSLog(@"%@", s);
	
	auto members = inPacketNode->members();
	for (auto iter = members.begin(); iter != members.end(); ++iter)
	{
		PDMemberNode* node = *iter;
		node->visit(this);
	}
	
	visitPacketAfter(inPacketNode);
}

void
PDFirstPassWalker::visitPacketAfter(PDPacketNode* inNode)
{
	NSLog(@"visitPacketAfter");
	
	//	Emit a return instruction…
	
	builder().CreateRetVoid();
	
	//	Verify it…
	//	TODO: Debug code only!
	
	llvm::Function* decodePacketFunc = module()->getFunction("decodePacket");
	bool failure = llvm::verifyFunction(*decodePacketFunc);
	if (failure)
	{
		NSLog(@"Something wrong with the function");
	}
}

void
PDFirstPassWalker::visitField(PDFieldNode* inNode)
{
	NSLog(@"visitField");
	
	const PDToken& typeTok = inNode->type()->token();
	std::string typeName = typeTok.cstring();
	PDBuiltInTypeSymbol* type = dynamic_cast<PDBuiltInTypeSymbol*> (currentScope()->resolve(typeName));
	if (type == NULL)
	{
		throw XUnknownType(typeTok);
	}
	
	//	TODO: Throw exception if type not found
	
	std::string fieldName = inNode->name()->token().cstring();
	
	std::string irName = stringWithFormat("field.%s.%s", typeName.c_str(), fieldName.c_str());
	
	//	Emit a call to createField…
	
	std::vector<llvm::Value*>			args;
	args.push_back(mDecodeContext);
	llvm::Value* llvmTypeName = createStringConstant(typeName);
	args.push_back(llvmTypeName);
	llvm::Value* llvmFieldName = createStringConstant(fieldName);
	args.push_back(llvmFieldName);
	llvm::Value* field = builder().CreateCall(mCreateField, args, irName);
}

void
PDFirstPassWalker::visitBlock(PDBlockNode* inNode)
{
}

llvm::Constant*
PDFirstPassWalker::createStringConstant(const std::string& inString)
{
	llvm::Constant* stringConstant = llvm::ConstantDataArray::getString(llvmContext(), inString);
	llvm::GlobalVariable* globalString = new llvm::GlobalVariable(*module(),
																	stringConstant->getType(),
																	true,
																	llvm::GlobalValue::PrivateLinkage,
																	stringConstant);
	
	llvm::Constant* zero = llvm::ConstantInt::get(llvm::Type::getInt32Ty(llvmContext()), 0);
	llvm::Constant* indices[] = { zero, zero };
	
	llvm::Constant* llvmStringPtr = llvm::ConstantExpr::getGetElementPtr(globalString, indices, true);
	return llvmStringPtr;
}

void
PDFirstPassWalker::visitDefinition(PDTreeNode* inNode)
{
	NSLog(@"visitDefinition");
}

void
PDFirstPassWalker::visitIdent(PDIdentNode* inNode)
{
	NSLog(@"visitIdent");
}

void
PDFirstPassWalker::visitType(PDTypeNode* inNode)
{
	NSLog(@"visitType");
}


void
PDFirstPassWalker::dumpSubtree(const PDTreeNode* inTree, NSUInteger inDepth)
{
	NSMutableString* s = [NSMutableString string];
	for (NSUInteger i = 0; i < inDepth; ++i)
	{
		[s appendString: @"  "];
	}
	
	const PDToken tok = inTree->token();
	if (!tok.isEOF())
	{
		[s appendFormat: @"%@", tok.string()];
	}
	else
	{
		[s appendString: @"<EOF>"];
	}
	
	NSLog(@"TreeNode: %s '%@'", typeid(inTree).name(), s);
	for (auto iter = inTree->children().begin(); iter != inTree->children().end(); ++iter)
	{
		dumpSubtree(*iter, inDepth + 1);
	}
}
