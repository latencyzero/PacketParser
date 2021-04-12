//
//  PDSymbol.h
//  PacketParser
//
//  Created by Roderick Mann on 1/13/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//


#import <map>
#import <string>
#import <vector>


namespace llvm
{
	class Function;
	class FunctionType;
	class Module;
	class Type;
	class Value;
}

class PDMethodSymbol;
class PDScope;
class PDTreeNode;





class
PDType
{
public:
	PDType()
		:
		mLLVMType(NULL)
	{
	}
	
	virtual								~PDType();
	
	virtual const std::string&			name()									const			=	0;
	
	llvm::Type*							llvmType()								const			{ return mLLVMType; }
	void								setLLVMType(llvm::Type* inVal)							{ mLLVMType = inVal; }
	
	virtual void						dump(uint16_t inLevel = 0)				const;
	
private:
	llvm::Type*							mLLVMType;
};




class
PDSymbol
{
public:
	PDSymbol(const std::string& inName, uint16_t inIndex = USHRT_MAX)
		:
		mName(inName),
		mType(NULL),
		mScope(NULL),
		mASTNode(NULL),
		mIndex(inIndex)
	{
	}

	PDSymbol(const std::string& inName, PDType* inType, uint16_t inIndex = USHRT_MAX)
		:
		mName(inName),
		mType(inType),
		mScope(NULL),
		mASTNode(NULL),
		mIndex(inIndex)
	{
	}
	
	virtual								~PDSymbol();
	
	const std::string&					name()									const			{ return mName; }
	void								setName(const std::string& inVal)						{ mName = inVal; }
	
	PDScope*							scope()									const			{ return mScope; }
	void								setScope(PDScope* inVal)								{ mScope = inVal; }

	PDTreeNode*							astNode()								const			{ return mASTNode; }
	void								setASTNode(PDTreeNode* inVal)							{ mASTNode = inVal; }
	
	PDType*								type()									const			{ return mType; }
//	void								setType(PDType* inVal)									{ mType = inVal; }
	
	uint16_t							index()									const			{ return mIndex; }
	void								setIndex(uint16_t inVal)								{ mIndex = inVal; }
	
	std::string							signature()								const;
	
	virtual void						dump(uint16_t inLevel = 0)				const;
	
private:
	std::string							mName;
	PDType*								mType;
	PDScope*							mScope;
	PDTreeNode*							mASTNode;
	uint16_t							mIndex;
};


class PDClassSymbol;

class
PDScope
{
public:
	typedef	std::map<std::string, PDSymbol*>				StringToSymbolMapT;
	typedef	const std::map<std::string, PDSymbol*>			ConstStringToSymbolMapT;
	
	PDScope()
	{
	}
	
	virtual	const std::string&	scopeName()										const		=	0;
	
	virtual	PDScope*			parentScope()									const		=	0;
	virtual	PDScope*			enclosingScope()								const		=	0;
	virtual	void				add(PDScope* inScope)										=	0;
	virtual	const std::vector<PDScope*>&
								childScopes()									const		=	0;
	virtual	void				define(PDSymbol* inSymbol)									=	0;
	virtual	PDSymbol*			resolve(const std::string& inName)				const		=	0;
	virtual	PDType*				resolveType(const std::string& inName)			const;
	
	virtual	llvm::Module*		module()										const		{ return enclosingScope()->module(); }
	
	virtual void				dump(uint16_t inLevel = 0)						const		=	0;
	
	PDClassSymbol*				defineClass(const std::string& inName, PDClassSymbol* inSuperClass, ...) __attribute__ ((sentinel));
	llvm::Type*					definePointerToType(const std::string& inBaseType);
	llvm::Type*					definePointerToFunction(const std::string& inFunctionName);
	
	llvm::FunctionType*			defineFunctionType(const std::string& inName, const std::string& inReturnTypeName, ...) __attribute__ ((sentinel));
	
	/**
		Declares a method with the given name, return type name (must already be defined
		in a reachable scope), and zero or more type name (also in reachable scope)/parameter
		name pairs. Terminate the list with NULL.
	*/
	
	PDMethodSymbol*				defineMethod(const std::string& inName,
												const std::string& inReturnTypeName,
												...)											__attribute__ ((sentinel));

	std::string					signature(const std::string& inName,
											const std::string& inReturnTypeName,
											...)												__attribute__ ((sentinel));
	
	std::string					signature(const std::string& inName,
											PDType* inReturnType,
											const std::vector<PDSymbol*>& inTypes)	const;
};





class
PDBaseScope : public PDScope
{
public:
	PDBaseScope(PDScope* inEnclosingScope = NULL)
		:
		mEnclosingScope(inEnclosingScope)
	{
		if (inEnclosingScope != NULL) inEnclosingScope->add(this);
	}
	
	PDBaseScope(llvm::Module* inModule, PDScope* inEnclosingScope = NULL)
		:
		mEnclosingScope(inEnclosingScope)
	{
		if (inEnclosingScope != NULL) inEnclosingScope->add(this);
	}

	virtual	void				define(PDSymbol* inSymbol);
	virtual	PDSymbol*			resolve(const std::string& inName)				const;
	
	virtual	PDScope*			parentScope()									const		{ return enclosingScope(); }
	virtual	PDScope*			enclosingScope()								const		{ return mEnclosingScope; }
	virtual	void				add(PDScope* inScope)										{ mChildScopes.push_back(inScope); }
	
	virtual	const std::vector<PDScope*>&
								childScopes()									const		{ return mChildScopes; }
				

	virtual void				dump(uint16_t inLevel = 0)						const;
	
private:
	PDScope*					mEnclosingScope;
	StringToSymbolMapT			mSymbols;
	std::vector<PDScope*>		mChildScopes;
};





class
PDGlobalScope : public PDBaseScope
{
public:
	PDGlobalScope(llvm::Module* inModule);
	
	const std::string&			scopeName()										const;
	
	virtual	llvm::Module*		module()										const		{ return mModule; }
	
protected:
	void						createBuiltInTypes();
	void						createClasses();
	void						createFieldClasses();
	void						createFieldClass(const std::string& inFieldType);
	
private:
	llvm::Module*				mModule;
};







class
PDBuiltInTypeSymbol : public PDSymbol,
						public PDType
{
public:
	PDBuiltInTypeSymbol(const std::string& inName)
		:
		PDSymbol(inName)
	{
	}
	
	virtual const std::string&	name()											const		{ return PDSymbol::name(); }
	virtual void				dump(uint16_t inLevel = 0)						const;
};





class
PDScopedSymbol : public PDSymbol,
					public PDScope
{
public:
	PDScopedSymbol(const std::string& inName, PDScope* inEnclosingScope)
		:
		PDSymbol(inName),
		mEnclosingScope(inEnclosingScope)
	{
		if (inEnclosingScope != NULL) inEnclosingScope->add(this);
	}
	
	PDScopedSymbol(const std::string& inName, PDType* inType, PDScope* inEnclosingScope)
		:
		PDSymbol(inName, inType),
		mEnclosingScope(inEnclosingScope)
	{
		if (inEnclosingScope != NULL) inEnclosingScope->add(this);
	}
	
	virtual const std::string&			name()									const		{ return PDSymbol::name(); }
	virtual	const std::string&			scopeName()								const		{ return name(); }
	
	virtual	void						define(PDSymbol* inSymbol);
	virtual	PDSymbol*					resolve(const std::string& inName)		const;
	
	virtual	StringToSymbolMapT&			membersByName()										{ return mMembersByName; }
	virtual	ConstStringToSymbolMapT&	membersByName()							const		{ return mMembersByName; }
	virtual	std::vector<PDSymbol*>		members()											{ return mMembers; }
	virtual	const std::vector<PDSymbol*>
										members()								const		{ return mMembers; }
	
	virtual	PDScope*					parentScope()							const		{ return enclosingScope(); }
	virtual	PDScope*					enclosingScope()						const		{ return mEnclosingScope; }
	virtual	const std::vector<PDScope*>&
										childScopes()							const		{ return mChildScopes; }
	virtual	void						add(PDScope* inScope)								{ mChildScopes.push_back(inScope); }
	
	virtual void						dump(uint16_t inLevel = 0)				const;
	
private:
	PDScope*							mEnclosingScope;
	std::vector<PDSymbol*>				mMembers;
	StringToSymbolMapT					mMembersByName;
	std::vector<PDScope*>				mChildScopes;
};




class
PDMethodSymbol : public PDScopedSymbol
{
public:
	PDMethodSymbol(const std::string& inName, PDType* inReturnType, PDScope* inParent = NULL)
		:
		PDScopedSymbol(inName, inReturnType, inParent),
		mFunction(NULL)
	{
	}

	llvm::Function*						function()								const		{ return mFunction; }
	void								setFunction(llvm::Function* inVal)					{ mFunction = inVal; }
	
	//virtual void						dump(uint16_t inLevel = 0)				const;
	
	std::string							mangledName()							const;
	
private:
	llvm::Function*						mFunction;
};





class
PDClassSymbol : public PDScopedSymbol,
				public PDType
{
public:
	PDClassSymbol(const std::string& inName,
					PDScope* inEnclosingScope,
					PDClassSymbol* inSuperclass)
		:
		PDScopedSymbol(inName, inEnclosingScope),
		mSuperclass(inSuperclass)
	{
	}
	
	virtual const std::string&			name()									const		{ return PDSymbol::name(); }
	
			PDClassSymbol*				superclass()							const		{ return mSuperclass; }
			
	virtual	PDScope*					parentScope()							const;
	
	/**
		Calls super, then adds non-method members to mDataMembers.
	*/
	
	virtual	void						define(PDSymbol* inSymbol);
	virtual	PDSymbol*					resolveMember(const std::string& inName) const;
	
	const std::vector<PDSymbol*>&		dataMembers()							const		{ return mDataMembers; }
	void								appendDataMember(PDSymbol* inVal);
	
	llvm::Value*						llvmValueOfSize()						const;
	
	//virtual void						dump(uint16_t inLevel = 0)				const;
	
	bool								indexesToMember(std::vector<uint32_t>& ioIndexes,
														const std::string& inMemberName)	const;
	std::vector<llvm::Value*>			llvmIndexesToMember(const std::string& inMemberName)	const;
	
protected:
	PDSymbol*							find(const std::string& inMemberName)	const;
	
private:
	PDClassSymbol*						mSuperclass;
	std::vector<PDSymbol*>				mDataMembers;
};



class
StPushScope
{
public:
	StPushScope(PDScope*& outCurrentScope, PDScope* inScope)
	{
		mSavedScope = outCurrentScope;
		outCurrentScope = inScope;
	}
	
private:
	PDScope*				mSavedScope;
};

