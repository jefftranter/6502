This is a port of 2KSA, the 2K Symbolic Assembler, by Robert Denison.

The source was taken from the original document (included here as a
PDF file) and modified to assemble with the CC65 assembler
tools. Because the code was modified it is not able to assemble
itself, due to the different assembler syntax.

The code can be conditionally assembled to produce the original KIM-1
and SYM-1 versions as well as a port to the Apple 1/Replica 1.

Start addresses are as follows:

Start    Link     Platform
Address  Address
-------  -------  --------
$05B8    $0200    KIM-1
$23B8    $2000    KIM-1
$05B8    $0200    SYM-1
$0300    $02E2    Replica 1

Sample Session
--------------

See the manual for detailed instructions on how to run the
assembler. Here is the output of a sample run:

?     ?ASSGN  ECHO    FFEF
?ASSGN
?     ?BEGIN  DEMO
- 0D00                LDA#    00
- 0D02        LOOP    TAX
- 0D03                JSR     ECHO
- 0D06                INX
- 0D07                TXA
- 0D08                BVC     LOOP
- 0D0A-PRINT  00TO10
A900   DEMO   LDA#   00        00  
AA     LOOP   TAX              02  
20EFFF        JSR    ECHO      03  
E8            INX              06  
8A            TXA              07  
50F8          BVC    LOOP      08  
- 0D0A-ASSEM
- 0D0A-STORE
?     

Relocation
----------

The document describes what needs to be changed to manually relocate
the code to run at different addresses. This source code will handle
this automatically. You do need to make sure it starts on a page
boundary.

Changes for Replica 1
---------------------

The following changes were made to run on the Replica 1:

- start address changed to $0300 to avoid conflict with the Woz Monitor input buffer
- I/O routines implemented for the Replica 1
- hitting <Escape> jumps to the Woz Monitor rather than BRK (which has no handler on the Replica 1)

Errors
-------

I found a number of errors in the documentation. It is not surprising
given that the document was typed by hand on a typewriter. There is
evidence that some corrections were made to the document later as the
typewriter font changes.

Where there were discrepancies I was able to resolve them by looking
at the assembly listing and binary dump, as they appear to be correct.

I noticed the following errors:

Symbols defined but never used, in table 4.2 on page 43:

USER
RFH
SAVX
MNETBL
MODTBL
SYMRFH
LAST2

Symbols used in the listing but not documented the above table:

IOBUF1
OPCODE1
OPCODE2
OPCODE3
OPCODE4
OFFSET
SYMPTR
OPRDP

Source code errors:

Page 16: The two instances of "JSR BIN2HEX" should read "JSR BIN2HX".

Page 24: The third instruction "LDAZ PRMTAB" should be "LDAZX PRMTAB"
(or in the the more conventional CC65 assembler, "LDA PRMTAB,X").

Page 28: The first instruction "LDA #00" should be "LDY #00".

Page 34: The syntax of some instructions is unusual, e.g. "LDAX
MODTAB 01" means "LDAX MODTAB+01" or in the more conventional CC65
assembler, "LDA MODTAB+1,X".

The binary dump at the end of the document was very useful for
confirming that my assembled version exactly matched the original.
The only discrepancy in this listing is that the addresses for the I/O
routines (GETCH, etc.) do not match the KIM-1 ROM addresses. This is
because the dump was for a SYM system as the listing says "SYM USER'S
GROUP" (see page 55 of the manual for the changes for a SYM computer).

Note that the last column in the memory dump is a checksum, an 8-bit
running total of the bytes in the file up to that point. I found this
useful to help in checking that my program matched the listing.
