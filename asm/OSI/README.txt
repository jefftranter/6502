This is the source code for the Ohio Scientific Superboard II /
Challenger 1P / Model 600 ROMs, including the monitor, boot program,
keyboard scan routine, and BASIC.

The source code came from various sources including disassembly of the
ROMs.

This version builds with the CC65 assembler. In some cases I have also
added additional comments to the code.

Included here are a couple of optional patches to BASIC. One fixes the
display of error messages, and the other addresses the well-known
garbage collection bug.

On a Linux system with the CC65 assembler installed, you can build
everything by running "make" in this directory. Do "make patch" to
apply the two patches to BASIC. See the Makefile for more details.
