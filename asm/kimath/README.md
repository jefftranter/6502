This contains KIMATH and MATHPAC.

KIMATH is a library of floating-point math functions for the 6502
written by MOS Technology, originally for the KIM-1 platform. I have
ported it to the cc65 assembler.

MATHPAC is an extension program to KIMATH by John Eaton that was
originally published in issue 20 of Dr. Dobb's Journal. I have ported
it to the cc65 assembler and filled in some missing pieces needed to
get it to build and run on a KIM-1 (along with KIMATH).

I've included the KIMATH bug fix described in the MATHPAC article.
I've also included a bug fix to USTRES reported by the original author
in the November 1977 issue of Kilobaud Magazine.

Also included is the example application described in the KIMATH documentation.

All have been confirmed to run on a KIM-1 computer with 60K of RAM.

Sample run of MATHPAC:

```
@=1/3
.33333333333333
@=1.23E6*4.56E-7
.56088
@=LOG(1E6)
6.00000001
@=ALG(3)
1000
@=SIN(45)
.70710678
@=COS(0)
1.
A=SQR(2)
@=A
1.41421356
@=A*A
1.99999999328787
```

I obtained the original files from these locations:

http://www.crbond.com/downloads/kimath.zip
http://www.6502.org/trainers/kim1/mathpac.zip
