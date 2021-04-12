//
//  Thoughts.cpp
//  PacketParser
//
//  Created by Roderick Mann on 1/17/13.
//  Copyright (c) 2013 Latency: Zero. All rights reserved.
//

#include "Thoughts.h"

#include <cstdio>





void
PDInputStream::getBytes(uint64_t inNumBytes, InputStreamReadCompletion inCompletion)
{
	inCompletion(NULL, inNumBytes, false);
}

template<typename T>
void
PDField<T>::process(PDInputStream& inInput, void (^inCompletion)())
{
	T	data;
	inInput.getBytes(sizeof (data),
	^(void* inBytes, uint64_t inLength, bool inEOF)
	{
	});
}

void
PDBlock::process(PDInputStream& inInput, void (^inCompletion)())
{

}


XBeePacket::XBeePacket()
	:
	payloadLength()
{
}


#if 0

void
XBeePacket::decode(PDInputStream& inInput, void (^inCompletion)(XBeePacket& inPacket))
{
	marker.process(inInput,
	^{
		payloadLength.process(inInput,
		^{
			payload.setLength(payloadLength);
			payload.process(inInput,
			^{
				checksum.process(inInput,
				^{
					inCompletion(*this);
				});
			});
		});
	});
}

#else


void
XBeePacket::process(PDInputStream& inInput, ProcessCompletion inCompletion)
{
	ProcessCompletion checksumComp =
	^{
		inCompletion();
	};
	
	ProcessCompletion payloadComp =
	^{
		checksum.process(inInput, checksumComp);
	};
	
	ProcessCompletion payloadLengthComp =
	^{
		payload.setLength(payloadLength);
		payload.process(inInput, payloadComp);
	};
	
	ProcessCompletion markerComp =
	^{
		payloadLength.process(inInput, payloadLengthComp);
	};
	
	marker.process(inInput, markerComp);
}

#endif

#if !DEBUG

int
main(int inArgC, const char** inArgV)
{
	PDInputStream	input;
	
	XBeePacket		packet;
	packet.process(input,
	^()
	{
		std::printf("PacketDecoded\n");
	});
	
	return 0;
}

#endif