//
//  PDSymbol.m
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PDSymbol.h"

//
//	Standard Imports
//

#import <cstdarg>

//
//	Library Imports
//

#import "llvm/IR/IRBuilder.h"
#import "llvm/IR/Module.h"
#import "llvm/Support/raw_ostream.h"

#import "Debug.h"

//
//	Project Imports
//

#import "XParse.h"





NSMutableString*
indent(uint16_t inLevel)
{
	NSMutableString* s = [NSMutableString string];
	for (uint16_t i = 0; i < inLevel; ++i)
	{
		[s appendString: @"    "];
	}
	
	return s;
}

#pragma mark -
#pragma mark • PDType


PDType::~PDType()
{
}

void
PDType::dump(uint16_t inLevel) const
{
	NSMutableString* s = indent(inLevel);
	std::string ls;
	llvm::raw_string_ostream ss(ls);
	llvmType()->print(ss);
	[s appendFormat: @"PDType(%s) '%s', LLVMType '%s'", typeid(*this).name(), name().c_str(), ss.str().c_str()];
	NSLog(@"%@", s);
}



#pragma mark -
#pragma mark • PDSymbol

PDSymbol::~PDSymbol()
{
}

std::string
PDSymbol::signature() const
{
	PDType* typeSym = type();
	assert(typeSym != NULL && "Have no type");
	
	NSMutableString* s = [NSMutableString stringWithFormat: @"%s", typeSym->name().c_str()];
	[s replaceOccurrencesOfString: @"*" withString: @"Ptr" options: 0 range: NSMakeRange(0, s.length)];
	[s replaceOccurrencesOfString: @"." withString: @"" options: 0 range: NSMakeRange(0, s.length)];
	
	std::string ss = [s cStringUsingEncoding: NSUTF8StringEncoding];
	return ss;
}

void
PDSymbol::dump(uint16_t inLevel) const
{
	NSMutableString* s = indent(inLevel);
	[s appendFormat: @"PDSymbol(%s) '%s', type '%s', index %u", typeid(*this).name(), name().c_str(), type() ? type()->name().c_str() : "<null>", index()];
	NSLog(@"%@", s);
}

#pragma mark -
#pragma mark • PDScope

PDType*
PDScope::resolveType(const std::string& inName) const
{
	PDSymbol* sym = resolve(inName);
	PDType* type = dynamic_cast<PDType*> (sym);
	return type;
}

llvm::Type*
PDScope::definePointerToType(const std::string& inBaseType)
{
	PDType* typeSym = resolveType(inBaseType);
	llvm::Type* type = typeSym->llvmType();
	
	llvm::Type* ptrType = llvm::PointerType::get(type, 0);
	
	std::string ptrTypeName = inBaseType + "*";
	PDBuiltInTypeSymbol* ptrTypeSym = new PDBuiltInTypeSymbol(ptrTypeName);
	ptrTypeSym->setLLVMType(ptrType);
	define(ptrTypeSym);
	
	return ptrType;
}

llvm::Type*
PDScope::definePointerToFunction(const std::string& inFunctionName)
{
	PDMethodSymbol* method = dynamic_cast<PDMethodSymbol*> (resolve(inFunctionName));
	llvm::Type* type = method->function()->getType();
	
	std::string ptrTypeName = inFunctionName + "*";
	PDBuiltInTypeSymbol* ptrTypeSym = new PDBuiltInTypeSymbol(ptrTypeName);
	ptrTypeSym->setLLVMType(type);
	define(ptrTypeSym);
	
	return type;
}

PDClassSymbol*
PDScope::defineClass(const std::string& inName, PDClassSymbol* inSuperClass, ...)
{
	va_list		args;
	va_start(args, inSuperClass);
	
	std::vector<PDSymbol*> fieldMembers;
	if (inSuperClass != NULL)
	{
		PDSymbol* member = new PDSymbol("super", inSuperClass);
		fieldMembers.push_back(member);
	}
	
	while (true)
	{
		const char* fieldType = va_arg(args, const char*);
		if (fieldType == NULL)
		{
			break;
		}
		
		const char* fieldName = va_arg(args, const char*);
		if (fieldName == NULL)
		{
			NSLogDebug(@"Uneven number of field type and names for struct '%s'", inName.c_str());
			assert(false && "Uneven number of field type and names. Must be one type name, one field name.");
		}
		
		//NSLogDebug(@"Struct member field: %s %s", fieldType, fieldName);
		
		PDType* typeSym = resolveType(fieldType);
		PDSymbol* member = new PDSymbol(fieldName, typeSym);
		fieldMembers.push_back(member);
	}
	va_end(args);
	
	//	First look up the type to see if it already exists in scope…
	
	llvm::StructType* structType = NULL;
	PDClassSymbol* type = dynamic_cast<PDClassSymbol*> (resolveType(inName));
	if (type != NULL)
	{
		//	If we find it in scope, it should have a struct type. If not,
		//	we throw an exception…
		
		llvm::Type* llvmType = type->llvmType();
		assert(llvmType->isStructTy() && "Must be a struct type!");
		structType = static_cast<llvm::StructType*> (llvmType);
		assert(llvmType != NULL && "class llvm type should not be null");
		
		if (!llvmType->isStructTy())
		{
			NSLogDebug(@"Type '%s' is not a class type.", inName.c_str());
			assert(false && "Type is not a class type");
		}
		else if (!structType->isOpaque())
		{
			NSLogDebug(@"Attempting to redefine class type '%s'.", inName.c_str());
			assert(false && "Attempting to redefine class type");
		}
	}
	
	if (type == NULL)
	{
		type = new PDClassSymbol(inName, this, inSuperClass);
		structType = llvm::StructType::create(module()->getContext(), inName);
		type->setLLVMType(structType);
		define(type);
	}
	
	if (!fieldMembers.empty())
	{
		uint16_t idx = 0;
		std::vector<llvm::Type*> fieldTypes;
		for (auto iter = fieldMembers.begin(); iter != fieldMembers.end(); ++iter)
		{
			PDSymbol* member = *iter;
			assert(member->type() != NULL);
			
			fieldTypes.push_back(member->type()->llvmType());
			type->define(member);
			type->appendDataMember(member);
			member->setIndex(idx);
			idx += 1;
		}
		structType->setBody(fieldTypes);
	}
	
	return type;
}

llvm::FunctionType*
PDScope::defineFunctionType(const std::string& inName, const std::string& inReturnTypeName, ...)
{
	//	First look up the type to see if it already exists in scope…
	
	PDType* typeSym = resolveType(inName);
	if (typeSym != NULL)
	{
		NSLogDebug(@"Function type '%s' already exists", typeSym->name().c_str());
		assert(typeSym == NULL && "Function type already exists");
	}
	
	//	Extract the types and names…
	
	va_list		args;
	va_start(args, inReturnTypeName);
	
	std::vector<llvm::Type*> argTypes;
	while (true)
	{
		const char* argType = va_arg(args, const char*);
		if (argType == NULL)
		{
			break;
		}
		
		//NSLogDebug(@"Arg type: %s", argType);
		PDType* typeSymbol = resolveType(argType);
		if (typeSymbol == NULL)
		{
			NSLogDebug(@"No type '%s' found for parameter of method '%s'", argType, inName.c_str());
			assert(false && "Type not found");
		}
		
		llvm::Type* llvmType = typeSymbol->llvmType();
		argTypes.push_back(llvmType);
	}
	va_end(args);
	
	//	Create the symbol…
	
	PDType* returnTypeSym = resolveType(inReturnTypeName);
	
	llvm::Type* returnType = returnTypeSym->llvmType();
	llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, argTypes, false);
	
	PDBuiltInTypeSymbol* functionTypeSym = new PDBuiltInTypeSymbol(inName);
	functionTypeSym->setLLVMType(funcType);
	define(functionTypeSym);
	
	return funcType;
}

PDMethodSymbol*
PDScope::defineMethod(const std::string& inName, const std::string& inReturnTypeName, ...)
{
	//	First look up the method to see if it already exists in scope…
	
	PDMethodSymbol* method = dynamic_cast<PDMethodSymbol*> (resolve(inName));
	assert(method == NULL && "Method already exists");
	
	//	Extract the types and names…
	
	va_list		args;
	va_start(args, inReturnTypeName);
	
	std::vector<llvm::Type*> argTypes;
	std::vector<PDType*> argTypeSymbols;
	std::vector<std::string> argNames;
	while (true)
	{
		const char* argType = va_arg(args, const char*);
		if (argType == NULL)
		{
			break;
		}
		
		const char* argName = va_arg(args, const char*);
		if (argName == NULL)
		{
			NSLogDebug(@"Uneven number of args for method '%s'", inName.c_str());
			assert(false && "Uneven number of var args. Must be one type name, one arg name");
		}
		
		//NSLogDebug(@"Arg: %s %s", argType, argName);
		PDType* typeSymbol = resolveType(argType);
		if (typeSymbol == NULL)
		{
			NSLogDebug(@"No type '%s' found for parameter '%s' of method '%s'", argType, argName, inName.c_str());
			assert(false && "Type not found");
		}
		
		argTypeSymbols.push_back(typeSymbol);
		
		llvm::Type* llvmType = typeSymbol->llvmType();
		argTypes.push_back(llvmType);
		
		argNames.push_back(argName);
	}
	va_end(args);
	
	//	Create the symbol…
	
	PDType* returnTypeSym = resolveType(inReturnTypeName);
	if (returnTypeSym == NULL)
	{
		NSLogDebug(@"No return type '%s' found for method '%s'", inReturnTypeName.c_str(), inName.c_str());
		assert(false && "Unknown method return type");
	}
	
	llvm::Type* returnType = returnTypeSym->llvmType();
	llvm::FunctionType* funcType = llvm::FunctionType::get(returnType, argTypes, false);
	
	llvm::Function* func = llvm::Function::Create(funcType, llvm::Function::ExternalLinkage, inName, module());
	
	method = new PDMethodSymbol(inName, returnTypeSym);
	method->setFunction(func);
	define(method);
	
	//	Create symbols for params. I think names are ignored for extern functions…
	
	uint16_t idx = 0;
	auto typeSymIter = argTypeSymbols.begin();
	auto nameIter = argNames.begin();
	for (auto argIter = func->arg_begin(); argIter != func->arg_end(); ++argIter, ++nameIter, ++typeSymIter)
	{
		std::string name = *nameIter;
		PDType* typeSym = *typeSymIter;
		
		argIter->setName(name);
		
		PDSymbol* argMember = new PDSymbol(name, typeSym, idx);
		method->define(argMember);
		
		idx += 1;
	}
	
	return method;
}

std::string
PDScope::signature(const std::string& inName,
			const std::string& inReturnTypeName,
			...)
{
	NSMutableString* typeSig = [NSMutableString stringWithFormat: @"%s", inReturnTypeName.c_str()];
	[typeSig replaceOccurrencesOfString: @"*" withString: @"Ptr" options: 0 range: NSMakeRange(0, typeSig.length)];
	[typeSig replaceOccurrencesOfString: @"." withString: @"" options: 0 range: NSMakeRange(0, typeSig.length)];
	
	NSMutableString* s = [NSMutableString string];
	[s appendFormat: @"%s_%@_", inName.c_str(), typeSig];
	
	va_list		args;
	va_start(args, inReturnTypeName);
	
	std::vector<std::string> argTypeNames;
	while (true)
	{
		const char* argTypeName = va_arg(args, const char*);
		if (argTypeName == NULL)
		{
			break;
		}
		
		typeSig = [NSMutableString stringWithFormat: @"%s", argTypeName];
		[typeSig replaceOccurrencesOfString: @"*" withString: @"Ptr" options: 0 range: NSMakeRange(0, typeSig.length)];
		[typeSig replaceOccurrencesOfString: @"." withString: @"" options: 0 range: NSMakeRange(0, typeSig.length)];
		[s appendFormat: @"%@_", typeSig];
	}
	va_end(args);
	
	//	Trim the trailing underscore…
	
	[s deleteCharactersInRange: NSMakeRange(s.length - 1, 1)];
	
	std::string ss = [s cStringUsingEncoding: NSUTF8StringEncoding];
	return ss;
}

std::string
PDScope::signature(const std::string& inName,
					PDType* inReturnType,
					const std::vector<PDSymbol*>& inTypes) const
{
	NSMutableString* typeSig = [NSMutableString stringWithFormat: @"%s", inReturnType->name().c_str()];
	[typeSig replaceOccurrencesOfString: @"*" withString: @"Ptr" options: 0 range: NSMakeRange(0, typeSig.length)];
	[typeSig replaceOccurrencesOfString: @"." withString: @"" options: 0 range: NSMakeRange(0, typeSig.length)];
	
	NSMutableString* s = [NSMutableString string];
	[s appendFormat: @"%s_%@_", inName.c_str(), typeSig];
	
	std::vector<std::string> argTypeNames;
	for (auto iter = inTypes.begin(); iter != inTypes.end(); ++iter)
	{
		PDSymbol* arg = *iter;
		typeSig = [NSMutableString stringWithFormat: @"%s", arg->type()->name().c_str()];
		[typeSig replaceOccurrencesOfString: @"*" withString: @"Ptr" options: 0 range: NSMakeRange(0, typeSig.length)];
		[typeSig replaceOccurrencesOfString: @"." withString: @"" options: 0 range: NSMakeRange(0, typeSig.length)];
		[s appendFormat: @"%@_", typeSig];
	}
	
	//	Trim the trailing underscore…
	
	[s deleteCharactersInRange: NSMakeRange(s.length - 1, 1)];
	
	std::string ss = [s cStringUsingEncoding: NSUTF8StringEncoding];
	return ss;
}

#pragma mark -
#pragma mark • PDBuiltInTypeSymbol

void
PDBuiltInTypeSymbol::dump(uint16_t inLevel) const
{
	PDType::dump(inLevel);
}

#pragma mark -
#pragma mark • PDScopedSymbol

void
PDScopedSymbol::define(PDSymbol* inSymbol)
{
	assert(inSymbol != NULL && "Attempt to define NULL inSymbol");
	
	NSLogDebug(@"PDScopedSymbol: Defining %s %p member to '%s' member '%s' of type '%s'", typeid(*inSymbol).name(), inSymbol, name().c_str(), inSymbol->name().c_str(),
					inSymbol->type() ? inSymbol->type()->name().c_str() : "<null>");
	mMembers.push_back(inSymbol);
	
	membersByName()[inSymbol->name()] = inSymbol;
	inSymbol->setScope(this);
}

PDSymbol*
PDScopedSymbol::resolve(const std::string& inName) const
{
	auto iter = membersByName().find(inName);
	if (iter != membersByName().end())
	{
		PDSymbol* s = iter->second;
		return s;
	}
	
	if (enclosingScope() != NULL)
	{
		return enclosingScope()->resolve(inName);
	}
	
	return NULL;
}

void
PDScopedSymbol::dump(uint16_t inLevel) const
{
	NSMutableString* s = indent(inLevel);
	[s appendFormat: @"PDScopedSymbol(%s) '%s', type '%s'", typeid(*this).name(), name().c_str(), type() ? type()->name().c_str() : "<null>"];
	NSLog(@"%@", s);
	//for (auto iter = members().begin(); iter != members().end(); ++iter)
	uint64_t sz = members().size();
	for (uint64_t i = 0; i < sz; ++i)
	{
		//PDSymbol* sym = *iter;
		PDSymbol* sym = members()[i];
		uint64_t v = reinterpret_cast<uint64_t>(sym);
		if ((v & 0xFF00000000000000) != 0 || v == 0)
		{
			s = indent(inLevel);
			[s appendString: @"WTF"];
			NSLog(@"%@", s);
		}
		sym->dump(inLevel + 1);
	}

#if 0
	s = indent(inLevel+1);
	[s appendFormat: @"--"];
	NSLog(@"%@", s);
#endif

	//	Child scopes…

	for (auto iter = childScopes().begin(); iter != childScopes().end(); ++iter)
	{
		PDScope* scope = *iter;
		scope->dump(inLevel + 1);
	}
	
#if 0
	s = indent(inLevel+1);
	[s appendFormat: @"--"];
	NSLog(@"%@", s);
#endif
}


#pragma mark -
#pragma mark • PDBaseScope




void
PDBaseScope::define(PDSymbol* inSymbol)
{
	assert(inSymbol != NULL && "Attempt to define NULL inSymbol");
	
	NSLogDebug(@"PDBaseScope: Defining %s %p symbol '%s' of type '%s'", typeid(*inSymbol).name(), inSymbol, inSymbol->name().c_str(),
					inSymbol->type() ? inSymbol->type()->name().c_str() : "<null>");
	
	mSymbols[inSymbol->name()] = inSymbol;
	inSymbol->setScope(this);
}

PDSymbol*
PDBaseScope::resolve(const std::string& inName) const
{
	StringToSymbolMapT::const_iterator iter = mSymbols.find(inName);
	if (iter != mSymbols.end())
	{
		PDSymbol* s = iter->second;
		return s;
	}
	
	return NULL;
}

void
PDBaseScope::dump(uint16_t inLevel) const
{
	NSMutableString* s = indent(inLevel);
	[s appendFormat: @"PDBaseScope(%s): Enclosing scope: %p", typeid(*this).name(), mEnclosingScope];
	NSLog(@"%@", s);
	for (auto iter = mSymbols.begin(); iter != mSymbols.end(); ++iter)
	{
		PDSymbol* sym = iter->second;
		sym->dump(inLevel + 1);
	}

#if 0
	s = indent(inLevel+1);
	[s appendFormat: @"--"];
	NSLog(@"%@", s);
#endif

	//	Child scopes…

	for (auto iter = childScopes().begin(); iter != childScopes().end(); ++iter)
	{
		PDScope* scope = *iter;
		scope->dump(inLevel + 1);
	}
	
#if 0
	s = indent(inLevel+1);
	[s appendFormat: @"--"];
	NSLog(@"%@", s);
#endif
}



#pragma mark -
#pragma mark • PDClassSymbol

PDScope*
PDClassSymbol::parentScope() const
{
	if (mSuperclass == NULL)
	{
		return enclosingScope();
	}
	
	return mSuperclass;
}

void
PDClassSymbol::define(PDSymbol* inSymbol)
{
	PDScopedSymbol::define(inSymbol);
	
	//	If it's *not* a method, it's a data member…
	//
	//	TODO: Might be a typedef, but we don't support those yet.
	
	if (dynamic_cast<PDMethodSymbol*> (inSymbol) == NULL)
	{
		appendDataMember(inSymbol);
	}
}

PDSymbol*
PDClassSymbol::resolveMember(const std::string& inName) const
{
	auto iter = membersByName().find(inName);
	if (iter != membersByName().end())
	{
		PDSymbol* s = iter->second;
		return s;
	}
	
	if (mSuperclass != NULL)
	{
		return mSuperclass->resolveMember(inName);
	}
	
	return NULL;
}

void
PDClassSymbol::appendDataMember(PDSymbol* inSymbol)
{
	assert(inSymbol != NULL && "Attempt to append NULL inSymbol");
	
	uint16_t idx = mDataMembers.size();
	inSymbol->setIndex(idx);
	
	NSLogDebug(@"Appending data member %s to '%s' member '%s' of type '%s'", typeid(*inSymbol).name(), name().c_str(), inSymbol->name().c_str(),
		inSymbol->type() ? inSymbol->type()->name().c_str() : "<null>");
	mDataMembers.push_back(inSymbol);
}


llvm::Value*
PDClassSymbol::llvmValueOfSize() const
{
	llvm::DataLayout* dl = new llvm::DataLayout(module());
	uint64_t s = dl->getTypeStoreSize(llvmType());
	llvm::Value* val = llvm::ConstantInt::get(module()->getContext(), llvm::APInt(64, s));
	return val;
}

bool
PDClassSymbol::indexesToMember(std::vector<uint32_t>& ioIndexes, const std::string& inMemberName) const
{
	PDSymbol* memberSym = find(inMemberName);
	if (memberSym != NULL)
	{
		ioIndexes.push_back(memberSym->index());
		return true;
	}
	else if (mSuperclass != NULL)
	{
		memberSym = find("super");
		if (memberSym != NULL)
		{
			ioIndexes.push_back(memberSym->index());
			return mSuperclass->indexesToMember(ioIndexes, inMemberName);
		}
	}
	
	return false;
}

std::vector<llvm::Value*>
PDClassSymbol::llvmIndexesToMember(const std::string& inMemberName)	const
{
	std::vector<llvm::Value*> llvmIndexes;
	
	std::vector<uint32_t> inds;
	if (indexesToMember(inds, inMemberName))
	{
		llvm::IRBuilder<>		builder(module()->getContext());
		for (auto iter = inds.begin(); iter != inds.end(); ++iter)
		{
			llvm::Value* v = builder.getInt32(*iter);
			llvmIndexes.push_back(v);
		}
	}
	
	return llvmIndexes;
}

PDSymbol*
PDClassSymbol::find(const std::string& inMemberName) const
{
	auto iter = membersByName().find(inMemberName);
	if (iter != membersByName().end())
	{
		PDSymbol* memberSym = iter->second;
		return memberSym;
	}
	
	return NULL;
}

#pragma mark -
#pragma mark • PDMethodSymbol

std::string
PDMethodSymbol::mangledName() const
{
	std::string mn = PDScope::signature(name(), type(), members());
}

#pragma mark -
#pragma mark • PDGlobalScope

PDGlobalScope::PDGlobalScope(llvm::Module* inModule)
	:
	PDBaseScope(inModule),
	mModule(inModule)
{
	createBuiltInTypes();
}

const std::string&
PDGlobalScope::scopeName() const
{
	static dispatch_once_t		sInit;
	static std::string			sName;
	dispatch_once(&sInit,
	^{
		sName = "global";
	});
	
	return sName;
}

void
PDGlobalScope::createBuiltInTypes()
{
	PDBuiltInTypeSymbol* u8 = new PDBuiltInTypeSymbol("u8");
	define(u8);
	
	llvm::IRBuilder<>		builder(module()->getContext());
	u8->setLLVMType(builder.getInt8Ty());
	
	PDBuiltInTypeSymbol* u16 = new PDBuiltInTypeSymbol("u16");
	define(u16);
	u16->setLLVMType(builder.getInt16Ty());
	
	PDBuiltInTypeSymbol* u32 = new PDBuiltInTypeSymbol("u32");
	define(u32);
	u32->setLLVMType(builder.getInt32Ty());
	
	PDBuiltInTypeSymbol* u64 = new PDBuiltInTypeSymbol("u64");
	define(u64);
	u64->setLLVMType(builder.getInt64Ty());
	
	PDBuiltInTypeSymbol* s1 = new PDBuiltInTypeSymbol("s1");
	define(s1);
	s1->setLLVMType(builder.getInt1Ty());
	
	PDBuiltInTypeSymbol* s8 = new PDBuiltInTypeSymbol("s8");
	define(s8);
	s8->setLLVMType(builder.getInt8Ty());
	
	PDBuiltInTypeSymbol* s16 = new PDBuiltInTypeSymbol("s16");
	define(s16);
	s16->setLLVMType(builder.getInt16Ty());
	
	PDBuiltInTypeSymbol* s32 = new PDBuiltInTypeSymbol("s32");
	define(s32);
	s32->setLLVMType(builder.getInt32Ty());
	
	PDBuiltInTypeSymbol* s64 = new PDBuiltInTypeSymbol("s64");
	define(s64);
	s64->setLLVMType(builder.getInt64Ty());
	
	definePointerToType("u8");
	
	PDBuiltInTypeSymbol* stringType = new PDBuiltInTypeSymbol("String");
	define(stringType);
	stringType->setLLVMType(builder.getInt8PtrTy());
	
	PDBuiltInTypeSymbol* voidType = new PDBuiltInTypeSymbol("void");
	define(voidType);
	voidType->setLLVMType(builder.getVoidTy());
	
	//	Declare declare i8* @malloc(i64)
	
	defineMethod("malloc", "u8*", "u64", "inNumBytes", NULL);

	//	PDFrame…
	
	PDClassSymbol* frameClass = defineClass("struct.PDFrame", NULL, "u64", "mStart", "u64", "mLength", "u8*", "mName", NULL);
	
	PDMethodSymbol* method = NULL;
#if 0
	PDMethodSymbol* method = new PDMethodSymbol("struct.PDFrame.start", u64);
	frameClass->define(method);
	
	method = new PDMethodSymbol("struct.PDFrame.length", u64);
	frameClass->define(method);
#endif

	//	Forward declare PDPacket…
	
	defineClass("struct.PDPacket", NULL, NULL);
	definePointerToType("struct.PDPacket");
	
	//	Define the Packet.decode() completion proc type…
	//
	//	void MyPacketDecodeCompletionProc(Packet* inPacket, void* inContext);
	
	defineMethod("PacketDecodeCompletionProc", "void", "struct.PDPacket*", "inPacket", "u8*", "inContext", NULL);
	definePointerToFunction("PacketDecodeCompletionProc");
	
	//	Complete the definition of the PDPacket type…
	
	defineClass("struct.PDPacket",
				frameClass,
				"PacketDecodeCompletionProc*", "mCompletionProc",
				"u8*", "mContext",
				NULL);
	
	createFieldClasses();

	//	Define the PDBlock class…
	
	PDClassSymbol* blockClass = defineClass("struct.PDBlock", frameClass, NULL);
	definePointerToType("struct.PDBlock");
	
	//	TODO: This is a partial implementation of PDBlock's init method. This one takes a pointer to
	//			a PDBlock and a length. But it should probably also take a name (as should the other
	//			nameable decoders, which can invoke their superclass init methods).
	//
	//			Need to actually implement the body of this init method to set the appropriate values
	//			and then call it at an appropriate place in the codegen pass.
	
	std::string sig = signature("init", "void", "struct.PDBlock*", "u64", NULL);
	defineMethod(sig, "void",
					"struct.PDBlock*", "inThis",
					"u64", "inLength",
					NULL);
	
	method = new PDMethodSymbol("struct.PDBlock.decode", voidType);
	blockClass->define(method);
	
	
	{
		module()->dump();
		
		PDClassSymbol* classSym = dynamic_cast<PDClassSymbol*> (resolve("struct.PDField.u8"));
		std::string mn = "mName";
		std::vector<uint32_t> inds;
		if (classSym->indexesToMember(inds, mn))
		{
			NSMutableString* s = [NSMutableString string];
			for (auto iter = inds.begin(); iter != inds.end(); ++iter)
			{
				[s appendFormat: @"%u, ", *iter];
			}
			
			[s deleteCharactersInRange: NSMakeRange(s.length - 2, 2)];
			NSLogDebug(@"Indexes to %s: %@", mn.c_str(), s);
		}
		
		NSLog(@"Foo");
	}
	
	//
	//	Runtime Interface
	//
	
	//	Define the decodeBlock() completion proc type…
	//
	//	void MyDecodeBlockCompletionProc(PDBlock* inThis, PDPacket* inPacket);
	
	defineFunctionType("DecodeBlockCompletionProc", "void", "struct.PDBlock*", "struct.PDPacket*", NULL);
	definePointerToType("DecodeBlockCompletionProc");
	
	//	Declare the decodeBlock() function…
	
	defineMethod("decodeBlock", "void",
					"struct.PDBlock*", "inBlock",
					"struct.PDPacket*", "inPacket",
					"DecodeBlockCompletionProc*", "inCompletion",
					"u8*", "inContext",
					NULL);
}

void
PDGlobalScope::createFieldClasses()
{
	//	Define the decodeField() completion proc type…
	//
	//	void MyDecodeFieldCompletionProc(PDField* inThis, PDPacket* inPacket);
	
	PDClassSymbol* superClass = dynamic_cast<PDClassSymbol*> (resolve("struct.PDFrame"));
	defineClass("struct.PDField", superClass, "u8", "mFieldType", NULL);
	definePointerToType("struct.PDField");
	
	defineFunctionType("DecodeFieldCompletionProc", "void", "struct.PDField*", "struct.PDPacket*", NULL);
	definePointerToType("DecodeFieldCompletionProc");
	
	//	Declare the decodeField() function…
	
	defineMethod("decodeField", "void",
					"struct.PDField*", "inField",
					"struct.PDPacket*", "inPacket",
					"DecodeFieldCompletionProc*", "inCompletion",
					"u8*", "inContext",
					NULL);
	
	//	Define individual field types…
	
	createFieldClass("u8");
	createFieldClass("u16");
	createFieldClass("u32");
	
#if 0
	//	Define the PDField class…
	//	TODO: Move the name to the PDFrame base class? All frames seem to have a name.
	
	PDClassSymbol* fieldClass = defineClass("struct.PDField", frameClass, "u8*", "mFieldName", "u8", "mFieldType", NULL);
	definePointerToType("struct.PDField");
	
#if 1
	std::string sig = signature("decode", "void", "struct.PDField*", NULL);
	method = defineMethod(sig, "void",
					"struct.PDField*", "inThis",
					NULL);
#else
	method = new PDMethodSymbol("struct.PDField.decode", voidType);
#endif
	fieldClass->define(method);
#endif
}

void
PDGlobalScope::createFieldClass(const std::string& inFieldType)
{
	PDClassSymbol* superClass = dynamic_cast<PDClassSymbol*> (resolve("struct.PDField"));
	
	std::string fieldTypePtrName = inFieldType + "*";
	std::string className = "struct.PDField." + inFieldType;
	PDClassSymbol* fieldClass = defineClass(className, superClass, inFieldType.c_str(), "mValue", NULL);
	definePointerToType(className);
	
	std::string classPtrName = className + "*";
	
	std::string sig = signature("init", "void", classPtrName.c_str(), NULL);
	PDMethodSymbol* method = defineMethod(sig, inFieldType,
					classPtrName.c_str(), "inThis",
					NULL);
	fieldClass->define(method);
	
	sig = signature("decode", "void", classPtrName.c_str(), NULL);
	method = defineMethod(sig, "void",
					classPtrName.c_str(), "inThis",
					NULL);
	fieldClass->define(method);
	
	//	u8 value() method (u8 is whatever type is passed in)…
	
	sig = signature("value", inFieldType.c_str(), classPtrName.c_str(), NULL);
	method = defineMethod(sig, inFieldType,
					classPtrName.c_str(), "inThis",
					NULL);
	fieldClass->define(method);
	
	llvm::IRBuilder<>		builder(module()->getContext());
	llvm::Function* func = method->function();
	
	//	Add a BasicBlock (of code) to our function definition…
	
	llvm::BasicBlock* bb = llvm::BasicBlock::Create(module()->getContext(), "entry", func);
	builder.SetInsertPoint(bb);
	
	auto argIter = func->arg_begin();
	llvm::Value* argThis = argIter++;
	
	llvm::Value* indexes[] = { builder.getInt32(0), builder.getInt32(1) };
	llvm::Value* ptrToMember = builder.CreateInBoundsGEP(argThis, indexes, "ptrToMember");
	llvm::Value* val = builder.CreateAlignedLoad(ptrToMember, 8);
	builder.CreateRet(val);
}


