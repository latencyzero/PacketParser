.. highlight:: python

Decoder
=======

The Decoder is the heart of PacketParser. It takes a Packet Definition program, compiled to bytecode
from the Packet Definition language, and a block of bytes, and creates a data structure of packets
and fields representing the decoded data. The UI can then display this data structure in a friendly
way.

Example 1: A Simple Example
---------------------------

Here's an example of pseudo-assembly language for the decoder bytecode::

   packet:
        marker      0x7E                //  Packet preamble is a byte, 0x7E
        field       u16,r2              //  16-bit unsigned integer length, value loaded into r2
        block       r2                  //  Payload is a block of bytes
        cksum       u8,r3               //  One-byte checksum, value loaded into r3

Which translates to bytecode::

    0000:   05017e00    marker      0x7e
    0001:   01010202    field       u16,r2,3
    0002:   04020000    block       r2
    0003:   01010100    field       u8          //  Don't support checksums yet, use a field

.. _example2:

Example 2: Something More Interesting
-------------------------------------

A more interesting example involves labels and some arithmetic::

    packet:
        marker      0x7E
    .length:
        field       u16,r2
        fname       .length,"length"    //  Field identifier is "length"
        lfidx       r3                  //  Load the current parse index into r3
        field       u8                  //  Define another field (that we ignore)
        lfidx       r4                  //  Load the current parse index into r4
        sub         r5,r4,r3            //  How many bytes was that?
        sub         r2,r2,r5            //  Subtract that from the length
        block       r2                  //  The remaining bytes in the block
        field       u8

..
        fsummary    "0x%02x",r2         //  Field summary is a format string

Which translates to bytecode::

    0000:   05017e00    marker      0x7e 
    0001:   01020102    field       u16,r2
    0002:   0c000006    string      6,"length"
    0003:   676e656c
    0004:   00006874
    0005:   0bffcffd    fname       -4,-3               //  0001,0002
    0006:   09030000    lfidx       r3
    0007:   01000101    field       u8
    0008:   09040000    lfidx       r4
    0009:   0a050403    sub         r5,r4,r3
    000A:   0a020205    sub         r2,r2,r5
    000B:   04020000    block       r2
    000C:   01000101    field       u8

Example 3: Subframes
--------------------

Frame definitions can work like function calls. In this example, the result
is the same as :ref:`example2`, but done with a frame call::

    
    packet:
        marker      0x7E
    .length:
        field       u16,r2              //  Defines u16 field, sets r2 to that value
        fname       .length,"length"    //  Field identifier is "length"
        call        .subframe
        cksum
        halt                            //  End of the packet definition

    subframe:                           //  Expects block length in r2
        field       u8                  //  Payload type
        ldi         r3,1                //  Subtract one from block length
        sub         r2,r2,r3
        block       r2                  //  Skip r2 bytes
        ret                             //  Return back to calling packet

Bytecode::

    0000:   05017e00    marker      0x7e 
    0001:   01020102    field       u16,r2
    0002:   0c000006    string      6,"length"
    0003:   676e656c
    0004:   00006874
    0005:   0bffcffd    fname       -4,-3               //  0001,0002
    0006:   0d000003    call        3                   //  0009
    0007:   01000101    field       u8
    0008:   00000000    halt
           
    0009:   01000101    field       u8
    000A:   11030001    ldi         r3,1
    000B:   0a020203    sub         r2,r2,r3
    000C:   04020000    block       r2
    000D:   0e000000    ret         
