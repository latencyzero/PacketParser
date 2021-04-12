//
//  PDTreeNode.h
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PDTreeNode_h__
#define __PDTreeNode_h__

#import <vector>



#import "PDToken.h"

class PDLexer;
class PDTreeVisitor;

class PDBlockNode;
class PDFieldNode;
class PDIdentNode;
class PDPacketNode;
class PDTreeNode;
class PDTypeNode;

class PDClassSymbol;
class PDSymbol;


class
PDTreeNode
{
public:
	PDTreeNode(PDLexer* inLexer)
		:
		mToken(inLexer)
	{
	}
	
	PDTreeNode(const PDToken& inToken)
		:
		mToken(inToken)
	{
	}
	
	const PDToken&							token()							const			{ return mToken; }
	const std::vector<PDTreeNode*>&			children()						const			{ return mChildren; }
	
	void
	addChild(PDTreeNode* inChild)
	{
		mChildren.push_back(inChild);
	}

	virtual	void							visit(PDTreeVisitor* inVisitor);
	virtual	void							visitAfter(PDTreeVisitor* inVisitor);
	
private:
	PDToken									mToken;
	std::vector<PDTreeNode*>				mChildren;
};

class
PDIdentNode : public PDTreeNode
{
public:
	PDIdentNode(const PDToken& inToken)
		:
		PDTreeNode(inToken)
	{
	}

	virtual	void							visit(PDTreeVisitor* inVisitor);
	virtual	void							visitAfter(PDTreeVisitor* inVisitor);
};

class
PDTypeNode : public PDTreeNode
{
public:
	PDTypeNode(const PDToken& inToken)
		:
		PDTreeNode(inToken)
	{
	}

	virtual	void							visit(PDTreeVisitor* inVisitor);
	virtual	void							visitAfter(PDTreeVisitor* inVisitor);
};


class
PDClassNode : public PDTreeNode
{
public:
	PDClassNode(const PDToken& inToken)
		:
		PDTreeNode(inToken)
	{
	}
	
	virtual	PDIdentNode*		name()														=	0;
	
	virtual	void				visit(PDTreeVisitor* inVisitor)								=	0;
	virtual	void				visitAfter(PDTreeVisitor* inVisitor)						=	0;
	
	PDClassSymbol*				classSymbol()								const			{ return mClassSymbol; }
	void						setClassSymbol(PDClassSymbol* inVal);
	
private:
	PDClassSymbol*				mClassSymbol;
};

class
PDMemberNode : public PDTreeNode
{
public:
	PDMemberNode(const PDToken& inToken)
		:
		PDTreeNode(inToken)
	{
	}
	
	uint16_t					index()										const			{ return mIndex; }
	void						setIndex(uint16_t inVal)									{ mIndex = inVal; }
	
	PDTypeNode*					type();
	virtual	PDIdentNode*		name();
	
	virtual	void				visit(PDTreeVisitor* inVisitor);
	virtual	void				visitAfter(PDTreeVisitor* inVisitor);
	
	PDSymbol*					memberSymbol()								const			{ return mSymbol; }
	void						setMemberSymbol(PDSymbol* inVal)							{ mSymbol = inVal; }

private:
	uint16_t					mIndex;
	PDSymbol*					mSymbol;
};

class
PDDecoderNode : public PDMemberNode
{
public:
	PDDecoderNode(const PDToken& inToken)
		:
		PDMemberNode(inToken)
	{
	}
};

class
PDFieldNode : public PDDecoderNode
{
public:
	PDFieldNode(const PDToken& inToken)
		:
		PDDecoderNode(inToken)
	{
	}
	
	PDTypeNode*					type();
	virtual	PDIdentNode*		name();
	
	virtual	void				visit(PDTreeVisitor* inVisitor);
	virtual	void				visitAfter(PDTreeVisitor* inVisitor);

};

class
PDBlockNode : public PDDecoderNode
{
public:
	PDBlockNode(const PDToken& inToken)
		:
		PDDecoderNode(inToken)
	{
	}
	
	virtual	PDIdentNode*		name();
	
	virtual	void				visit(PDTreeVisitor* inVisitor);
	virtual	void				visitAfter(PDTreeVisitor* inVisitor);
};


class
PDPacketNode : public PDClassNode
{
public:
	PDPacketNode(const PDToken& inToken)
		:
		PDClassNode(inToken)
	{
	}
	
	virtual	PDIdentNode*			name();
	std::vector<PDMemberNode*>&		members()													{ return mMembers; }
	std::vector<PDDecoderNode*>&	decoders()													{ return mDecoders; }
	void							add(PDDecoderNode* inNode)									{ decoders().push_back(inNode); members().push_back(inNode); }
	
	virtual	void					visit(PDTreeVisitor* inVisitor);
	virtual	void					visitAfter(PDTreeVisitor* inVisitor);
	
private:
	std::vector<PDMemberNode*>		mMembers;
	std::vector<PDDecoderNode*>		mDecoders;
};




inline
PDIdentNode*
PDPacketNode::name()
{
	return dynamic_cast<PDIdentNode*> (children()[0]);
}

inline
PDTypeNode*
PDMemberNode::type()
{
	return dynamic_cast<PDTypeNode*> (children()[0]);
}

inline
PDIdentNode*
PDMemberNode::name()
{
	return dynamic_cast<PDIdentNode*> (children()[1]);
}

inline
PDTypeNode*
PDFieldNode::type()
{
	return dynamic_cast<PDTypeNode*> (children()[0]);
}

inline
PDIdentNode*
PDFieldNode::name()
{
	return dynamic_cast<PDIdentNode*> (children()[1]);
}

inline
PDIdentNode*
PDBlockNode::name()
{
	return dynamic_cast<PDIdentNode*> (children()[0]);
}

#endif	//	__PDTreeNode_h__
