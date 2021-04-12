
========
Language
========

Packet types are defined in an expressive high-level language.

.. warning::
    Not all of the language features you see are implemented. This
    document serves more as a scratchpad for what the language
    *might* look like, and as such, doesn't necessarily represent
    what's actually available.

Example
=======
::

    packet
    FictionalDataPacket
    {
        marker                  0x7e;
        field u8                numTemps;
        field float             temps[numTemps];
        field u8                numVoltages;
        field u16               voltages[numVoltages];
        checksum u8
        {
        }
    }

    packet
    XBeeAPI
    {
    bigendian:

        marker                  0x7e;
        field u16               payloadLen;
        block(payloadLen)       payload
        {
            field u8            frameID;
            u16 frameLength = length;           //  "this.length"
            
            switch (frameID)
            {
                case 0x88: { ATCommandResponse      atcr(frameLength); }
                case 0x8A: { ModemStatus            ms(frameLength); }
            }
        }
        
        checksum u8
        {
            u8 computed = 0xFF - sum8(payload);
            return computed == value;
        }
    }
    
    frame
    ATCommandResponse
    {
        ATCommandResponse(u16 inLength)
        {
            length = inLength;
        }

        field u16               command;
        field u8                status
        {
            status[0] = "OK";
            status[1] = "ERROR";
            status[2] = "Invalid Command";
            status[3] = "Invalid Parameter";
            status[4] = "Transmit Failure";
        }
        
        u16 commandDataLen = length - frameIndex;       //  frameIndex is number of byte into this frame
        block                   commandData(commandDataLen);
    }
    
    frame
    ModemStatus
    {
        ModemStatus(u16 inLength)
        {
            length = inLength;
        }

        field u8                status
        {
            if (value == 0)             summary = "Hardware reset";
            else if (value == 1)        summary = "Watchdog timer reset";
            else if (value == 2)        summary = "Joined network";
            else if (value == 3)        summary = "Disassociated";
            else if (value == 6)        summary = "Coordinator started";
            else if (value == 7)        summary = "Network security key updated";
            else if (value == 0x0D)     summary = "Voltage supply limit exceeded";
            else if (value == 0x11)     summary = "Modem configuration changed while join in progress";
            else if (value >= 0x80 && value <= 0xFF)
            {
                summary = "Coordinator started";
            }
            else
            {
                summary = "Unknown";
            }
        }
        
        u16 commandDataLen = length - frameIndex;       //  frameIndex is number of byte into this frame
        block                   commandData(commandDataLen);
    }

A **packet** definition is made up of **frames** and **fields** (a packet is a special type of frame, and there
can be only one). Frames and fields can be thought of as classes in C++. The fields they contain are members, and they
have a number of pre-defined members with special meaning. They differ from classes in that fields
declared within them also represent code that executes to decode incoming bytes. A field, for
example, amounts to a sequence of instructions to consume a number of input bytes appropriate for
the field's declared type, and compute the value those bytes represent, again appropriate for the
field's type.

For example, all frames and fields define **start**, **end**, and **length** members. Fields also define
a **value** member, which represents the value of the decoded data for that field. Frames and fields
also have a **summary** which is used by the UI when displaying decoded packets in the browser.

You can also write C-like code in your packet definitions. The code can make decsions about how to
decode a packet, or compute checksums, or do length calculations.

There are a number of global variables defined, too. **index** is the current byte being decoded,
since the start of capture or the start of the file. **frameIndex** is the current byte since the
start of the current frame.


Built-in Types
==============

The decoder has a number of primitve and built-in types::

    u8
    u16
    u32
    u64
    
    s8
    s16
    s32
    s64
    
    frame
    packet
    field
    
Thoughts on CodeGen
===================

This simple definition::

    packet
    XBeePacket
    {
        marker                  0x7e;
        u16                     payloadLength;
        block                   payload(payloadLength);
        u8                      checksum;
    }

Expands to::

    init marker;
    marker.decode(inInput, ??);
    
    init payloadLength
    payloadLength.decode(inInput, ??);
    
    initPayload
    payload.decode(inInput)
    
    initChecksum
    decode(checksum, inputStream, ??);
    
Expands to IR that defines these functions:

.. code-block:: c++


    XBeePacket.markerComp(void* inCTX);
    XBeePacket.payloadLengthComp(void* inCTX);
    XBeePacket.payloadComp(void* inCTX);
    XBeePacket.checksumComp(void* inCTX);

    XBeePacket.decode(inInput, inCompletion)
    {
        setupPacket();
        setupInputStream(inInput);

        marker.init(0x7e);
        marker.decode(inputStream, markerComp, this);
    }
    
    XBeePacket.markerComp(void* inCTX)
    {
        payloadLength.init();
        payload.decode(inputStream, XBeePacket.payloadComp, this);
    }

    XBeePacket.payloadLengthComp(void* inCTX)
    {
        payLen = payloadLength.value();
        payload.init(payLen);
        payload.decode(inputStream, XBeePacket.payloadComp, this);
    }

    XBeePacket.payloadComp(void* inCTX)
    {
        checksum.init();
        checksum.process(inputStream, XBeePacket.checksumComp, this);
    }

    XBeePacket.checksumComp(void* inCTX)
    {
        validPacket(true);
        decodeCompletionProc();
    }


