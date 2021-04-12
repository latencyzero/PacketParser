//
//  Thoughts.h
//  PacketParser
//
//  Created by Roderick Mann on 1/17/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#ifndef __PacketParser__Thoughts__
#define __PacketParser__Thoughts__

#include <string>




typedef void (^InputStreamReadCompletion)(void* inBytes, uint64_t inLength, bool inEOF);

class
PDInputStream
{
public:
	void		getBytes(uint64_t inNumBytes, InputStreamReadCompletion inCompletion);
	
};

typedef void (^ProcessCompletion)();

class
PDFrame
{
public:
	PDFrame()
	{
		mStart = 0;		//	undefined?
		mLength = 0;	//	undefined?
	}
	
	uint64_t				start()						{ return mStart; }
	virtual uint64_t		length()					{ return mLength; }
	virtual void			setLength(uint64_t inVal)	{ mLength = inVal; }
	const std::string&		name()		const			{ return mName; }
	
	virtual	void			process(PDInputStream& inInput, ProcessCompletion inCompletion = NULL) = 0;
	
private:
	uint64_t				mStart;
	uint64_t				mLength;
	std::string				mName;
};


template<typename T>
class
PDField : public PDFrame
{
public:
	PDField()
	{
		setLength(sizeof(T));
	}
	
	const std::string&		type()		const		{ return mType; }
	
	T						value()		const		{ return mValue; }
							operator T() const		{ return mValue; }
				
	virtual	void			process(PDInputStream& inInput, ProcessCompletion inCompletion = NULL);

private:
	std::string				mType;
	T						mValue;
};


class
PDBlock : public PDFrame
{
public:
	virtual	void			process(PDInputStream& inInput, ProcessCompletion inCompletion = NULL);
};

class
PDPacket : public PDFrame
{
public:

};




class
XBeePacket : public PDPacket
{
public:
	PDField<uint8_t>			marker;
	PDField<uint16_t>			payloadLength;
	PDBlock						payload;
	PDField<uint8_t>			checksum;
	
	XBeePacket();
	
	virtual	void			process(PDInputStream& inInput, ProcessCompletion inCompletion = NULL);
};



#endif
