MINI DIS
By Dan Lewart

One day I was single-stepping through a program and not
being too alert, I kept going after the program ended.
Then I noticed I was going through instructions not in any
OP-code table. What was being executed? With a little
luck I found that many nonexistent codes would duplicate
others with only one bit changed. I haven't looked into
it very deeply, but here are two examples: 17 is the same
as 16 (ASL-Z, PAGE) and FF is the same as FE (INC ABS,X).

By single-stepping I could determine the number of bytes
in all instructions. This worked for all instructions except
for 02,12,22,32,42,52,62,72,92,B2,D2 and F2, which
blank the display. After filling in the Bytes per Instruction
table many patterns became obvious. For example, the
op-code ending with digits 8 and A could be summarized as
having a bit pattern of xxxxl0x0, where "x" means don't
care. This covers all possibilities and when a number of
this form is ANDed with 00001101 (mask all the x bits) the
result will be 00001000. By doing this for all 0 (illegal),
1 and 3 byte instructions and having the 2 byte instructions
"whatever's left over" I had the basis of my semi-disassembler.
The only odd byte length is that of 20 (JSR) which "should"
be only 1 byte long.

Though this is not a full disassembler, it has helped me to
write several programs, including itself. To relocate the
program change locations 374-6, 379-B and 38E-390 to jump
to the appropriate locations. If you have a program in page
1 or don't want to write on the stack, change 397 and 39A
to EA (NOP).

To run the program, store 00 in 17FA and 03 in 17FB. Go
to the beginning of your program and press "ST". You will
then see the first instruction displayed. If it is illegal, the
location and opcode will flash on and off. In that case, press
"RS". To display the next instruction press "+". To display
the current address and opcode press "PC", at any time. To
backstep press "B". When you have backstepped to the
beginning of your program, or changed locations 397 and 39A,
pressing "B" acts like "PC".
