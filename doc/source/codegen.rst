===============
Code Generation
===============

Notes on ho w the Packet Definition language translates to executable code.

::
    
    u32                 index;          //  Current byte from start of input buffer

    frame
    {
        u32             start;          //  Value of index at start of this packet's decode
        u32             length;         //  Total length of packet in bytes (might not be known at start)
        u32             frameIndex;     //  Current byte from start of this frame (computed)
    }

    packet
    Foo                                 //  extends frame
    {
        field   u32     payloadLength;
    }
    
.. code-block:: none

    //  Beginning of packet Foo processing
    //
    //  r2  ->  index

	index = 0
    allocate space for packet Foo
	Foo.start = 0;
	Foo.length = 0;
	
	//	Handle payloadLength field…
	
	allocate space for field payloadLength (sizeof(u32), 4 bytes)
	for (int i = 0; i < sizeof (u32); i++)
	{
		b = get next byte from input
		store b in payloadLength buffer (depending on endianness)
	}

	