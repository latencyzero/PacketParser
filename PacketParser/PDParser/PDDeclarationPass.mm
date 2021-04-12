//
//  PDDeclarationPass.mm
//  PacketParser
//
//  Created by Roderick Mann on 1/17/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "PDDeclarationPass.h"




//
//	Library Imports
//

#import "llvm/IRBuilder.h"
#import "llvm/Module.h"

#import "Debug.h"

//
//	Project Imports
//

#import "PDSymbol.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "XParse.h"









PDDeclarationPass::PDDeclarationPass(PDScope* inGlobalScope)
	:
	PDTreeVisitor(inGlobalScope)
{
}


void
PDDeclarationPass::walk(PDTreeNode* inTree)
{
	inTree->visit(this);
	
	for (auto iter = inTree->children().begin(); iter != inTree->children().end(); ++iter)
	{
		PDTreeNode* node = const_cast<PDTreeNode*> (*iter);
		node->visit(this);
	}
	
	inTree->visitAfter(this);
}





void
PDDeclarationPass::visitPacket(PDPacketNode* inPacketNode)
{
	//	Get the packet name…
	
	PDTreeNode* name = inPacketNode->name();
	std::string packetName = name->token().cstring();
	NSLogDebug(@"declaring packet: %s", packetName.c_str());
	
	//	Define a class for this PDPacket subclass…
	
	std::string className = "struct." + packetName;
	PDClassSymbol* superclassSym = dynamic_cast<PDClassSymbol*> (currentScope()->resolveType("struct.PDPacket"));
	PDClassSymbol* packetClassSym = new PDClassSymbol(className, currentScope(), superclassSym);
	llvm::StructType* structType = llvm::StructType::create(module()->getContext(), className);
	packetClassSym->setLLVMType(structType);
	inPacketNode->setClassSymbol(packetClassSym);
	
	pushScope(packetClassSym);
	
	//	Add a field for the super class structure…
	
	PDSymbol* superSym = new PDSymbol("super", superclassSym);
	currentScope()->define(superSym);
	//packetClassSym->appendDataMember(superSym);
	
	//	Add a data field to the packet class for the completion proc pointer…
	
	//	llvm::Type* packetDecodeCompletionProcPtrType = resolvePointerToMethod("PacketDecodeCompletionProc");
	
	std::string methodName = packetName + ".decode";
	currentScope()->defineMethod(methodName, "void",
									"u8*", "inInputStream",
									"PacketDecodeCompletionProc*", "inCompletion",
									"u8*", "inContext",
									NULL);
	//	Visit the children…
	
	auto members = inPacketNode->members();
	for (auto iter = members.begin(); iter != members.end(); ++iter)
	{
		PDMemberNode* node = *iter;
		node->visit(this);
	}
	
	visitPacketAfter(inPacketNode);
}

void
PDDeclarationPass::visitPacketAfter(PDPacketNode* inPacketNode)
{
	//	Create the aggregate type for the packet class…
	
	PDClassSymbol* packetClassSym = inPacketNode->classSymbol();
	//PDClassSymbol* superclassSym = packetClassSym->superclass();
	//llvm::Type* superClassType = superclassSym->llvmType();
	
	llvm::StructType* classStructType = static_cast<llvm::StructType*> (packetClassSym->llvmType());
	std::vector<llvm::Type*> structMemberTypes;
	//uint16_t idx = 0;
	for (auto iter = packetClassSym->dataMembers().begin(); iter != packetClassSym->dataMembers().end(); ++iter)
	{
		PDSymbol* sym = *iter;
		std::string n = sym->name();
		NSLogDebug(@"LLVMing class %s, adding struct field: %s %s", packetClassSym->name().c_str(), sym->type()->name().c_str(), sym->name().c_str());
		//sym->setIndex(idx++);
		structMemberTypes.push_back(sym->type()->llvmType());
	}
	classStructType->setBody(structMemberTypes);
	
	packetClassSym->setLLVMType(classStructType);
	
	popScope();
}

void
PDDeclarationPass::visitField(PDFieldNode* inFieldNode)
{
	//	Get the field name…
	
	PDIdentNode* name = inFieldNode->name();
	std::string memberName = name->token().cstring();
	NSLogDebug(@"declaring field: %s", memberName.c_str());
	
	PDTypeNode* fieldTypeNode = inFieldNode->type();
	NSString* fieldTypeName = fieldTypeNode->token().string();
	
	//	Create a symbol for the field (whose type is PDField)…
	
	std::string fieldClassName = "struct.PDField.";
	fieldClassName += [fieldTypeName cStringUsingEncoding: NSUTF8StringEncoding];
	
	PDType* fieldClass = currentScope()->resolveType(fieldClassName);
	PDSymbol* memberField = new PDSymbol(memberName, fieldClass);
	memberField->setASTNode(inFieldNode);
	inFieldNode->setMemberSymbol(memberField);
	currentScope()->define(memberField);
	
	PDClassSymbol* packetClassSym = dynamic_cast<PDClassSymbol*> (currentScope());
	if (packetClassSym == NULL)
	{
		assert(false && "visiting a field when a packet is not the current scope");
	}
	
	//	Declare a completion proc…
	
	std::string methodName = memberName + ".completionProc";
	currentScope()->defineMethod(methodName, "void",
									"struct.PDField*", "inField",
									"struct.PDPacket*", "inPacket",
									NULL);

	visitFieldAfter(inFieldNode);
}

void
PDDeclarationPass::visitFieldAfter(PDFieldNode* inNode)
{
}

void
PDDeclarationPass::visitBlock(PDBlockNode* inNode)
{
	PDIdentNode* name = inNode->name();
	std::string memberName = name->token().cstring();
	NSLogDebug(@"declaring block: %s", memberName.c_str());
	
	//	Create a symbol for the block (whose type is PDBlock)…
	
	PDType* blockClass = currentScope()->resolveType("struct.PDBlock");
	PDSymbol* memberBlock = new PDSymbol(memberName, blockClass);
	memberBlock->setASTNode(inNode);
	inNode->setMemberSymbol(memberBlock);
	currentScope()->define(memberBlock);
	
	PDClassSymbol* packetClassSym = dynamic_cast<PDClassSymbol*> (currentScope());
	if (packetClassSym == NULL)
	{
		assert(false && "visiting a block when a packet is not the current scope");
	}
	
	//	Declare a completion proc…
	
	std::string methodName = memberName + ".completionProc";
	currentScope()->defineMethod(methodName, "void",
									"struct.PDBlock*", "inBlock",
									"struct.PDPacket*", "inPacket",
									NULL);

	visitBlockAfter(inNode);
}

void
PDDeclarationPass::visitBlockAfter(PDBlockNode* inNode)
{
}

void
PDDeclarationPass::visitDefinition(PDTreeNode* inNode)
{
}


void
PDDeclarationPass::visitIdent(PDIdentNode* inNode)
{
}


void
PDDeclarationPass::visitType(PDTypeNode* inNode)
{
}
