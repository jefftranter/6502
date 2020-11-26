TODO:
- Enter all of source and comments
- Convert absolute references to symbols
- Try relocating
- Research and create stubs for OS calls
- Implement OS calls
- Test and debug (initially use my simulator)

This is a port of BBC Basic 2 to the Ohio Scientific C1P/Superboard 2
(and hopefully later, more machines).

I started with a binary, disassembled it, and got it to assemble to
the same binary code with the CC65 cross-assembler. Then, comments
were added from the original source that was written as in-line
assembler in BBC Basic.

The system calls (MOS) from the Acorn/BBC platform need to be emulated
or stubbed out for the other platforms.

It is still a work in progress.

References:

1. http://mdfs.net/Software/BBCBasic/6502/#:~:text=Basic2.,Basic4.
2. http://forum.6502.org/viewtopic.php?f=2&t=3654
3. http://mdfs.net/Docs/Comp/Acorn/Atom/MOSEntries
4. https://en.wikipedia.org/wiki/BBC_BASIC
5. http://bbc.nvg.org/doc/
6. http://bbc.nvg.org/doc/BBCUserGuide-1.00.pdf
