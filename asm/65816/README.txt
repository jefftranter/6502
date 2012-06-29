This directory has some example programs which run on the 65816 processor.

DEBU16:

https://groups.google.com/group/comp.sys.apple2/browse_frm/month/1991-12?pli=1

DEBUG16 from "Programming the 65816" by David Eyes/Ron Lichty    
        
1.  David E A Wilson    

Has anyone else typed this program in from the book "Programming the
65816" (ISBN 0-89303-789-3)? I have found 20 bugs/misprints in the
assembler listing so far and wonder if there is an errata sheet for
the book. The listing looks like it was produced from a computer but
with lines like:

1695 007E 1E0D DC I1'30,13'
LDA ABSL,X BF 1696 0080
1401 DC I1'30,13' CPY C0

it is obvious that this has been transcribed
by a human who has repeated the operand field of two adjacent lines.

Other problems include code that could never work (decoding the
destination byte of MVP/MVN instructions relies on the B register -
unfortunately it is used to print the source byte and thus is rubbish
when it comes to print the destination), missing code (required to
print jmp [addr] - this is mistakenly printed as jmp (addr) in both
the absolute and long indirect forms), missing labels (which appear in
the symbol table but not in the listing), a missing opcode:

0683 004F A780 [PCREG] LOAD 16 BITS --16 BIT MODE

and misspelled labels (OPRNDL is spelled ORPNDL once). Now listing works I just have to get it to
trace properly...

-- David Wilson (042) 21 3802 voice, (042) 21 3262 fax
Dept Comp Sci, Uni of Wollongong da...@cs.uow.edu.au
Dec 23 1991, 3:49 pm
