This directory a port of the DEBUG16 program to the Replica 1.

It requires a Replica 1 with a 65816 processor (as far as I know I
have the only one in existence).

It came from the manual "Programming the 65816 Including the 6502,
65C02 and 65802" available from The Western Design Center, Inc.

It provides some code for disassembling and and tracing execution on the 65816.

Thee code needed to be ported to the CC65 assembler and changes made
for input/output on the Replica 1. The original code was intended for
the Apple //e.

There were also a number of typographical as well as logic errors in
the code. At least one other person tried getting this code to work
and noticed the errors. See:

https://groups.google.com/group/comp.sys.apple2/tree/browse_frm/month/1991-12/49dc75d9ccf7c6ef?rnum=101&_done=%2Fgroup%2Fcomp.sys.apple2%2Fbrowse_frm%2Fmonth%2F1991-12%3Fpli%3D1%26#doc_49dc75d9ccf7c6ef

Current status:

Disassembly (LIST) is working. It has not been tested exhaustively for
all instructions.

The trace function has not yet been tested or debugged.
