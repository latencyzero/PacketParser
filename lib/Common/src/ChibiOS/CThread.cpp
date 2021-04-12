/**
	CThread.cpp
	TreasureBox
	
	Created by Roderick Mann on 2/3/11.
	Copyright 2011 Latency: Zero. All rights reserved.
*/

#include "CThread.h"

#include "ch.h"

BaseThread::BaseThread(void* inWorkingArea, size_t inWorkingAreaSize)
	:
	mWorkingArea(inWorkingArea),
	mWorkingAreaSize(inWorkingAreaSize),
	mMessageContext(NULL),
	mSysThread(NULL)
{
}

msg_t
BaseThread::entry()
{
	return 0;
}

void
BaseThread::start(tprio_t inPriority)
{
	mSysThread = chThdCreateStatic(mWorkingArea,
									mWorkingAreaSize,
									inPriority,
									ThreadEntry,
									this);
}

msg_t
BaseThread::sendMessage(msg_t inMsg, void* inContext)
{
	mMessageContext = inContext;
	msg_t reply = chMsgSend(getSysThread(), inMsg);
	return reply;
}

msg_t
BaseThread::messageWait(void** outContext)
{
	msg_t msg = chMsgWait();
	if (outContext != NULL)
	{
		*outContext = mMessageContext;
	}
	
	return msg;
}

void
BaseThread::messageRelease(msg_t inReply)
{
	chMsgRelease(inReply);
}