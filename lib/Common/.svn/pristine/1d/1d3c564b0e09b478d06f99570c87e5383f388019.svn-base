/*
 *  ExceptionMacros.h
 *  SatTrackX
 *
 *  Created by Roderick Mann on 11/28/07.
 *  Copyright 2007 Latency: Zero. All rights reserved.
 *
 */


#ifndef	__ExceptionMacros_h__
#define __ExceptionMacros_h__


#include "XResourceAllocationFailed.h"
#include "XOSStatus.h"



#define	ThrowIfCFNull_(inVal)													\
	do {																		\
		if ((inVal) == NULL) {													\
			XResourceAllocationFailed* ex = new XResourceAllocationFailed();	\
			ex->setLocation(__FILE__, __LINE__);								\
			throw ex;															\
		}																		\
	} while (false)


#define	ThrowIfOSStatus_(inVal)													\
	do {																		\
		if ((inVal) != noErr) {													\
			XOSStatus* ex = new XOSStatus(inVal);								\
			ex->setLocation(__FILE__, __LINE__);								\
			throw ex;															\
		}																		\
	} while (false)





#endif	//	__ExceptionMacros_h__
