This directory contains a port of some floating point routines for the
6502 to the Replica 1 and CC65 assembler. The code was published in
Dr. Dobb's Journal, August 1976, pages 17-19. It includes the fixes
described in the errata published in Dr. Dobb's Journal,
November/December 1976, page 57.

The original code was downloaded from http://6502.org/source/

It also contains code for converting between ASCII and floating point
representations. This was taken from two articles: "A BCD to
Floating-Point Binary Routine" by Marvin L. De Jong, Compute! Issue 9,
February 1981, page 46 and "A Floating-Point Binary to BCD Routine" by
Marvin L. De Jong, Compute! Issue 11, April 1981, Page 66.

The versions in the orig directory should match the code in the
original magazine articles. The original listings had many errors
(e.g. "#" missing). I believe I have corrected all errors and the
routines are working correctly.

The file test.s is a demonstration and test program that exercises all
of the functions.

---

Examples of FP format using DeJong routines:

String:           Exponent  Mantissa     Sign  Comments

0                 00        00 00 00 00  00    0
1                 01        80 00 00 00  00    0.1 x 2^1
-1                01        80 00 00 00  FF
2                 02        80 00 00 00  00    0.1 x 2^2
-2                02        80 00 00 00  FF
4                 03        80 00 00 00  00    0.1 x 2^3
1.5               01        C0 00 00 00  00    .11 x 2^1
0.75              00        C0 00 00 00  00    0.11 x 2^0
0.1               FD        CC CC CC CD  00    0.1100... x 2^-3
31                05        F8 00 00 00  00
32                06        80 00 00 00  00
1234              0B        9A 40 00 00  00   .1001101001 x 2^11
1.234E+10         22        B7 E1 5D 40  00
-1.234E+10        22        B7 E1 5D 40  FF
1.234E-10         E0        87 AE 03 1B  00
1.234E-10         E0        87 AE 03 1B  00

Example for:

1234              0B        9A 40 00 00        .1001101001 x 2^11

  .1001101001 x 2^11 
= 10011010010.
= 2^10 + 2^7 + 2^6 + 2^4 + 2^1
= 1024 + 128 + 64 + 16 + 2
= 1234

Examples of FP format using Woz Routines:

Decimal           Exponent  Mantissa     Comments

0                 00        00 00 00     0
1                 80        40 00 00     1.0 x 2^0
-1                7F        80 00 00     -0 x 2^-1
2                 81        40 00 00     1.0 x 2^1
-2                80        80 00 00     -0 x 2^0
4                 82        40 00 00     1.0 x 2^2
31                84        7C 00 00     0.11111 x 2^2
32                85        40 00 00     1.0 x 2^5
1234              8A        4D 20 00     0.1001101001 x 2^10

---

WozFP format for 1234 $04D2 is

  8A 4D2000

  01.0011010010 x 2^10
= 0100 1101 0010.

Which is the same as above except normalized differently.

N    Woz            De Jong

     X1  M1 +1 +2   BEXP MSB NMSB NLSB LSB MFLAG
---- ------------   -------------------
0    00  00 00 00   00  00 00 00 00  00
1    80  40 00 00   01  80 00 00 00  00
-1   7F  80 00 00   01  80 00 00 00  FF
2    81  40 00 00   02  80 00 00 00  00
-2   80  80 00 00   02  80 00 00 00  FF
4    82  40 00 00   03  80 00 00 00  00
31   84  7C 00 00   05  F8 00 00 00  00
32   85  40 00 00   06  80 00 00 00  00
1234 8A  4D 20 00   0B  9A 40 00 00  00

To convert from DeJong format to Woz:

Exponent:
 subtract 1
 complement bit 7.

Mantissa:
  shift all bytes right one position
  set most significant bit to 1 if sign is $FF
  throw away least significant byte.

To convert from Woz format to DeJong:

Sign:
  Set MFLAG to $FF if most significant bit of mantissa is 1, else set to $00.

Mantissa:
  Shift all bytes left one position. Set LSB byte to $00.

Exponent:
  complement bit 7
  add 1

---

Example: Calculating square root of 2

2^0.5 = e^(ln(2) / 2)

2 in FP is 81 400000
ln(2) is 7F 5979D4

7F 5979D4 divided by 81 400000 is 7E 5979D4
e^X of 7E 5979D4 is 80 5AC6BC
which is 141837978E.E-8
