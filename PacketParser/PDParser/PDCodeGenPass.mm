//
//  PDCodeGenPass.mm
//  PacketParser
//
//  Created by Roderick Mann on 1/18/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "PDCodeGenPass.h"

//
//	Library Imports
//

#import "llvm/Constants.h"
#import "llvm/DataLayout.h"
#import "llvm/IRBuilder.h"
#import "llvm/Module.h"
#import "llvm/Analysis/Verifier.h"
#import "llvm/Support/raw_ostream.h"

#import "Debug.h"


//
//	Project Imports
//

#import "PDSymbol.h"
#import "PDToken.h"
#import "PDTreeNode.h"
#import "XParse.h"









PDCodeGenPass::PDCodeGenPass(PDScope* inGlobalScope)
	:
	PDTreeVisitor(inGlobalScope)
{
	
	
}


void
PDCodeGenPass::walk(PDTreeNode* inTree)
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
dumpType(llvm::Type* inT, int inDepth)
{
	std::string s;
	llvm::raw_string_ostream ss(s);
	
	inT->print(ss);
	NSMutableString* ms = [NSMutableString string];
	for (int i = 0; i < inDepth; i++)
	{
		[ms appendString: @"  "];
	}
	
	NSString* o = @" (not opaque)";
	if (inT->isStructTy() && static_cast<llvm::StructType*>(inT)->isOpaque())
	{
		o = @" (opaque)";
	}
	
	NSString* sz = @" (not sized)";
	if (inT->isSized())
	{
		sz = @" (sized)";
	}
	
	NSLog(@"%@%s%@%@", ms, ss.str().c_str(), o, sz);
	if (inT->isStructTy())
	{
		llvm::StructType* st = static_cast<llvm::StructType*> (inT);
		llvm::StructType::element_iterator iter = st->element_begin();
		for (; iter != st->element_end(); ++iter)
		{
			llvm::Type* et = *iter;
			dumpType(et, inDepth + 1);
		}
	}
}



void
PDCodeGenPass::visitPacket(PDPacketNode* inPacketNode)
{
	PDClassSymbol* packetClassSym = inPacketNode->classSymbol();
	pushScope(packetClassSym);
	
	//	Define the packet’s decode() method…
	
	PDIdentNode* name = inPacketNode->name();
	std::string packetName = name->token().cstring();
	std::string methodName = packetName + ".decode";
	
	PDMethodSymbol* method = dynamic_cast<PDMethodSymbol*> (packetClassSym->resolve(methodName));
	llvm::Function* decodeFunc = method->function();
	
	//	Add a BasicBlock (of code) to our function definition…
	
	llvm::BasicBlock* bb = llvm::BasicBlock::Create(llvmContext(), "entry", decodeFunc);
	builder().SetInsertPoint(bb);
	
	//	Allocate a pointer to the class type…
	
	llvm::StructType* classStructType = static_cast<llvm::StructType*>(packetClassSym->llvmType());
	llvm::PointerType* classStructPtrType = llvm::PointerType::get(classStructType, 0);
	llvm::AllocaInst* classStructPtr = builder().CreateAlloca(classStructPtrType, 0, "packet");
	classStructPtr->setAlignment(8);
	
	//	Allocate space for the class and set the pointer to it…
	//dumpType(classStructType, 0);
	
	//classStructType->getStructElementType(0)->dump();
	//classStructType->getStructElementType(0)->getStructElementType(1)->dump();
	
	llvm::Value* structSize = llvmValueOfSizeOf(classStructType);
	llvm::Value* packetPtr = buildCall("malloc", structSize);
	//	TODO: check for successful alloc?
	
	llvm::Value* mallocedStructPtr = builder().CreateBitCast(packetPtr, classStructPtrType);
	llvm::StoreInst* storeInst = builder().CreateAlignedStore(mallocedStructPtr, classStructPtr, 8);
	
	//
	//	Implement a kind of constructor for our defined packet…
	//
	
	//	Store the passed-in completion proc pointer in the class…
	
	llvm::LoadInst* loadedPacketPtr = builder().CreateAlignedLoad(classStructPtr, 8);
	
	llvm::Value* ptrTomCompletionProcPtr = NULL;
	{
		llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(0), builder().getInt32(1) };
		ptrTomCompletionProcPtr = builder().CreateInBoundsGEP(loadedPacketPtr, indexes, "ptrTomCompletionProcPtr");
	}
	
	llvm::Value* ptrTomContext = NULL;
	{
		llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(0), builder().getInt32(2) };
		ptrTomContext = builder().CreateInBoundsGEP(loadedPacketPtr, indexes, "ptrTomContext");
	}
	
	auto argIter = decodeFunc->arg_begin();
	llvm::Value* argInContext = argIter++;
	storeInst = builder().CreateAlignedStore(argInContext, ptrTomContext, 8);
	llvm::Value* argInCompletionProc = argIter;
	storeInst = builder().CreateAlignedStore(argInCompletionProc, ptrTomCompletionProcPtr, 8);
	
	//	Set the name on each of our fields…
	
	for (auto iter = inPacketNode->members().begin(); iter != inPacketNode->members().end(); ++iter)
	{
		PDMemberNode* memberNode = *iter;
		PDSymbol* memberSym = memberNode->memberSymbol();
		const std::string& memberName = memberSym->name();
		
		//	Make a constant for the string bytes…
		
		llvm::Value* string = buildStringConstant(memberName, memberName + ".name");
		
		//	Get a pointer to the PDField…
		
		uint16_t memberIndex = memberSym->index();
		llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(memberIndex) };
		llvm::Value* ptrToMember = builder().CreateInBoundsGEP(loadedPacketPtr, indexes, "ptrToMember");
		
		//	Get a pointer to PDField.mFieldName…
		
		PDClassSymbol* decoderClassSym = dynamic_cast<PDClassSymbol*> (memberSym->type());
		std::vector<llvm::Value*> inds = decoderClassSym->llvmIndexesToMember("mName");
		inds.insert(inds.begin(), builder().getInt32(0));
		llvm::Value* ptrToMemberName = builder().CreateInBoundsGEP(ptrToMember, inds, "ptrToMemberName");
		
		//	Load the string into the field name…
		
		storeInst = builder().CreateAlignedStore(string, ptrToMemberName, 8);
	}
	module()->dump();
	
	//	Insert a call to the runtime decodeField() for the first field…
	
	//	Use polymorphism (on Node, perhaps?) to emit calls to the decoder funcs for the various
	//	types (PDField and subclasses, PDBlock, etc).
	//
	//	Because the completion procs vary by order (others, last), we have to switch based on the loop.

	auto decoders = inPacketNode->decoders();
	auto iter = decoders.begin();
	if (iter != decoders.end())
	{
		//	Find the completion proc (defined on the Packet)…
		
		PDDecoderNode* decoder = *iter;
		llvm::Function* completionProc = completionProcForFieldNode(decoder);
		
		//	Call decodeField()…
		
		//	void decodeField(void* inField, void* inPacket, FieldDecodeCompletionProc inCompletionProc, void* inContext)
		
		PDSymbol* decoderMember = decoder->memberSymbol();
		uint16_t memberIndex = decoderMember->index();
		llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(memberIndex) };
		llvm::Value* ptrToMember = builder().CreateInBoundsGEP(loadedPacketPtr, indexes, "ptrToMember");
		
		PDClassSymbol* decoderClassSym = dynamic_cast<PDClassSymbol*> (decoderMember->type());
		std::vector<llvm::Value*> inds = decoderClassSym->llvmIndexesToMember("super");
		inds.insert(inds.begin(), builder().getInt32(0));
		llvm::Value* ptrToSuper = builder().CreateInBoundsGEP(ptrToMember, inds, "ptrToSuper");
		
		llvm::Type* superType = llvm::PointerType::get(classStructType->getStructElementType(0), 0);
		llvm::Value* castToSuper = builder().CreateBitCast(loadedPacketPtr, superType);
		
		//std::string decodeSig =
		buildCall("decodeField", ptrToSuper, castToSuper, completionProc, mNULL);
	}
	
	//	Emit a return instruction in the Packet decode function…
	
	builder().CreateRetVoid();
	
	//	For all the decoders but the last, create completion procs…
	
	for (iter = decoders.begin(); iter != decoders.end() - 1; ++iter)
	{
		//	Find the completion proc (defined on the Packet)…
		
		PDDecoderNode* decoder = *iter;
		llvm::Function* completionProc = completionProcForFieldNode(decoder);
		
		llvm::BasicBlock* bb = llvm::BasicBlock::Create(llvmContext(), "entry", completionProc);
		builder().SetInsertPoint(bb);
		
		argIter = completionProc->arg_begin();
		/*llvm::Value* argInField =*/ argIter++;
		llvm::Value* argInPacket = argIter;
		
		//	TODO: Generate pre-next-decoder decode code here
		
		//	Call next decoder's decodeField()…
		
		auto nextIter = iter + 1;													//	Next decoder’s completion proc
		PDDecoderNode* nextField = *nextIter;
		llvm::Function* nextCompletionProc = completionProcForFieldNode(nextField);
	
		llvm::Value* packet = builder().CreateBitCast(argInPacket, classStructPtrType);
		PDSymbol* decoderMember = nextField->memberSymbol();
		uint16_t memberIndex = decoderMember->index();
		
		//	TODO: This builds a call to the runtime decodeField() function, but it needs to
		//			either call different runtime functions for different types (i.e. PDBlock),
		//			or we need to find a way to make the PDStruct hierarchy polymorphic. The problem
		//			with that is it changes the member layout in memory, so the stuff in PD code
		//			won't match the C++ code.
		//
		//			For now, just test the node type and call based on that. Really gross.
		
		if (typeid(*nextField) == typeid(PDFieldNode))
		{
			llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(memberIndex), builder().getInt32(0) };	//	Last 0 gets super (PDField)
			llvm::Value* ptrToMember = builder().CreateInBoundsGEP(packet, indexes, "ptrToMember");
			buildCall("decodeField", ptrToMember, argInPacket, nextCompletionProc, mNULL);
		}
		else if (typeid(*nextField) == typeid(PDBlockNode))
		{
			llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(memberIndex) };
			llvm::Value* ptrToMember = builder().CreateInBoundsGEP(packet, indexes, "ptrToMember");
			buildCall("decodeBlock", ptrToMember, argInPacket, nextCompletionProc, mNULL);
		}
		else
		{
			assert(false && "Unknown decoder type");
		}
		
		//	Return from the completion proc…
		
		builder().CreateRetVoid();
	}
	
	//	For the last decoder’s completion proc, call the completion proc that was
	//	passed to us in the packet’s decode…
	
	{
		iter = decoders.end() - 1;
		PDDecoderNode* decoder = *iter;
		llvm::Function* completionProc = completionProcForFieldNode(decoder);
		llvm::BasicBlock* bb = llvm::BasicBlock::Create(llvmContext(), "entry", completionProc);
		builder().SetInsertPoint(bb);
		
		//	Get the arguments passed in to our completion proc…
		
		argIter = completionProc->arg_begin();
		/*llvm::Value* argInField =*/ argIter++;
		llvm::Value* argInPacketVoidPtr = argIter;
		
		llvm::Value* argInPacketPtr = builder().CreateBitCast(argInPacketVoidPtr, classStructPtrType);		//	TODO: I think this is redundant; parameter already right type
		
		llvm::Value* mCompletionProcPtr = NULL;
		{
			llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(0), builder().getInt32(1) };
			llvm::Value* element = builder().CreateInBoundsGEP(argInPacketPtr, indexes, "element");
			mCompletionProcPtr = builder().CreateAlignedLoad(element, 8, "mCompletionProcPtr");
		}
		
		llvm::Value* mContextPtr = NULL;
		{
			llvm::Value* indexes[] = { builder().getInt32(0), builder().getInt32(0), builder().getInt32(2) };
			llvm::Value* element = builder().CreateInBoundsGEP(argInPacketPtr, indexes, "element");
			mContextPtr = builder().CreateAlignedLoad(element, 8, "mContextPtr");
		}
		
		//	Packet decode completion…
		
		llvm::Value* argPDPacketPtr = builder().CreateConstInBoundsGEP2_32(argInPacketPtr, 0, 0);	//	TODO: Make "super" value getter
		llvm::Value* args[] = { argPDPacketPtr, mContextPtr };
		builder().CreateCall(mCompletionProcPtr, args);
		
		//	Return from the completion proc…
		
		builder().CreateRetVoid();
	}
	
	visitPacketAfter(inPacketNode);
}

llvm::Function*
PDCodeGenPass::completionProcForFieldNode(PDDecoderNode* inNode)
{
	std::string decoderName = inNode->name()->token().cstring();
	std::string methodName = decoderName + ".completionProc";
	PDMethodSymbol* methodSym = dynamic_cast<PDMethodSymbol*> (currentScope()->resolve(methodName));
	if (methodSym == NULL)
	{
		NSString* msg = [NSString stringWithFormat: @"Unknown method '%s' at %lu:%lu",
							methodName.c_str(), inNode->token().line(), inNode->token().col()];
		throw XParse(__FILE__, __LINE__, msg);
	}
	
	llvm::Function* completionProc = methodSym->function();
	return completionProc;
}

void
PDCodeGenPass::visitPacketAfter(PDPacketNode* inPacketNode)
{
	popScope();
}


void
PDCodeGenPass::visitField(PDFieldNode* inFieldNode)
{
}

void
PDCodeGenPass::visitFieldAfter(PDFieldNode* inFieldNode)
{
	popScope();
}

void
PDCodeGenPass::visitBlock(PDBlockNode* inNode)
{
}

void
PDCodeGenPass::visitBlockAfter(PDBlockNode* inNode)
{
	popScope();
}

void
PDCodeGenPass::visitDefinition(PDTreeNode* inNode)
{
}


void
PDCodeGenPass::visitIdent(PDIdentNode* inNode)
{
}


void
PDCodeGenPass::visitType(PDTypeNode* inNode)
{
}
