This directory contains a port of some floating point routines for the
6502 to the Replica 1 and CC65 assembler. The code was published in
Dr. Dobb's Journal, August 1976, pages 17-19. It includes the fixes
described in the errata published in Dr. Dobb's Journal,
November/December 1976, page 57.

The original code was downloaded from http://6502.org/source/

---

Floating point representation example:

1,000 * 1,200 = 1,200,000 = 1.2 E+06

1000 = $03E8
1200 = $04B0

03E8 -> 89 7D0000
04B0 -> 8A 4B0000

89 7D0000 x 8A 4B0000 = 94 493E00

94 493E00

Exponent $94 = +$14 or decimal 20 or 2^20 or decimal 1,048,576

Mantissa is (always in range 1..2):

01.00 1001 0011 1110 0000 0000 
^- sign +
   00 0000 0001 1111 1111 1222
   12 3456 7890 1234 5678 9012

1 + 1/(2^3) + 1/(2^6) + 1/(2^9) + 1/(2^10) + 1/(2^11) + 1/(2^12) + 1/(2^13)

= 1 + 1/8   + 1/64    + 1/512   + 1/1024   + 1/2048   + 1/4096   + 1/8192

= 1.14440918

1.14440918 x 1,048,576 = 1,200,000
