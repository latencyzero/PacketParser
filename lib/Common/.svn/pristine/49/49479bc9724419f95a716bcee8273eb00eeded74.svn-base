/**
	CThread.h
	
	Created by Roderick Mann on 2/3/11.
	Copyright 2011 Latency: Zero. All rights reserved.

*/

#ifndef __CThread_h__
#define __CThread_h__


//
//	Third-party Includes
//

#include "ch.h"

#include "led.h"

#include "Debug.h"



/**
*/

class
BaseThread
{
public:
							BaseThread(void* inWorkingArea, size_t inWorkingAreaSize);
							
	void					start(tprio_t inPriority = NORMALPRIO);
	
	msg_t					sendMessage(msg_t inMsg, void* inContext);
	Thread*					getSysThread()								{ return mSysThread; }
	
protected:
	virtual	msg_t			entry();
	
	msg_t					messageWait(void** outContext);
	void					messageRelease(msg_t inMsg);
	
	void
	sleep(uint32_t inMilliseconds)
	{
		chThdSleepMilliseconds(inMilliseconds);
	}
	
private:
	static	msg_t			ThreadEntry(void* inArg);
	
	void*					mWorkingArea;
	uint32_t				mWorkingAreaSize;
	void*					mMessageContext;
	Thread*					mSysThread;
};

inline
msg_t
BaseThread::ThreadEntry(void* inArg)
{
	BaseThread* self = reinterpret_cast<BaseThread*> (inArg);
	return self->entry();
}

/**
*/

template<size_t inStackSize>
class
CThread : public BaseThread
{
public:
	CThread()
		:
		BaseThread(mWorkingArea, sizeof(mWorkingArea))
	{
	}
							
protected:
	virtual	stkalign_t*		getWorkingArea()				{ return mWorkingArea; }
	
private:
	WORKING_AREA(mWorkingArea, inStackSize);
};



#endif	//	__CThread_h__
