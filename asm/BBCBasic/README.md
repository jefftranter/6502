This is a port of BBC Basic 2 to my 6502 Single Board Computer (SBC).

I started with a binary, disassembled it, and got it to assemble to
the same binary code with the CC65 cross-assembler. Then, comments
were added from the original source that was written as in-line
assembler in BBC Basic.

The system calls (MOS) from the Acorn/BBC platform were emulated
or stubbed out for the SBC platform.

Support for these keywords was removed to get the code to fit in a 16K
ROM (they would not work anyway due to hardware limitations):

ENVELOPE SOUND ADVAL POINT CHAIN LOAD SAVE CLG COLOUR DRAW GCOL MODE
MOVE PLOT

Acorn-specific screen output (VDU) functions are not implemented. Any
commands for file i/o will not work, as well as sound or graphics.

For more information on the Basic interpreter, you can find many
references on the Internet to the Acorn computer and BBC Basic.

References:

1. http://bbc.nvg.org/doc/
2. http://bbc.nvg.org/doc/BBCUserGuide-1.00.pdf
3. http://beebwiki.mdfs.net/OSWORD
4. http://forum.6502.org/viewtopic.php?f=2&t=3654
5. http://mdfs.net/Docs/Comp/Acorn/Atom/MOSEntries
6. http://mdfs.net/Software/BBCBasic/6502/#:~:text=Basic2.,Basic4.
7. https://central.kaserver5.org/Kasoft/Typeset/BBC/Ch43.html
8. https://danceswithferrets.org/geekblog/?p=872
9. https://danceswithferrets.org/geekblog/?p=961
10. https://en.wikipedia.org/wiki/Acorn_MOS
11. https://en.wikipedia.org/wiki/BBC_BASIC
