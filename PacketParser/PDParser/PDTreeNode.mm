//
//  PDTreeNode.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/12/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#import "PDTreeNode.h"





#import "PDSymbol.h"
#import "PDToken.h"
#import "PDTreeVisitor.h"





void
PDTreeNode::visit(PDTreeVisitor* inVisitor)
{
//	inVisitor->visit(this);
}

void
PDTreeNode::visitAfter(PDTreeVisitor* inVisitor)
{
//	inVisitor->visitAfter(this);
}

void
PDPacketNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitPacket(this);
}

void
PDPacketNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitPacketAfter(this);
}

void
PDMemberNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitMember(this);
}

void
PDMemberNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitMemberAfter(this);
}

void
PDFieldNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitField(this);
}

void
PDFieldNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitFieldAfter(this);
}

void
PDBlockNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitBlock(this);
}

void
PDBlockNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitBlockAfter(this);
}

void
PDTypeNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitType(this);
}

void
PDTypeNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitTypeAfter(this);
}

void
PDIdentNode::visit(PDTreeVisitor* inVisitor)
{
	inVisitor->visitIdent(this);
}

void
PDIdentNode::visitAfter(PDTreeVisitor* inVisitor)
{
	inVisitor->visitIdentAfter(this);
}

void
PDClassNode::setClassSymbol(PDClassSymbol* inVal)
{
	mClassSymbol = inVal;
	inVal->setASTNode(this);
}
