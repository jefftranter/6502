The disk operating system for the Apple ][ was recently open sourced.
See http://www.computerhistory.org/atchm/apple-ii-dos-source-code/

For fun I tried to get it to build using the CC65 assembler. Since I
do not own an Apple ][ I am not able to test it. but the files
assemble and appear to be correct.

I did not check every instruction in detail against the PDF source
listing but the length of the code is correct and I checked a good
chunk of the addresses. The Microsoft Word (docx) version was very
helpful and was used as a starting point, but it did contain a number
of errors which were resolved by looking at the scan of the assembly
listing. Interestingly enough, the original source code assembler
listing reports one assembly error in the code.

Files:

apple_dos_rw.s  Port of low-level read/write routines (original filename Apple_DOS_RW_30May1978.txt)
apple_dos.s     Port of DOS code (original filename Apple_DOS_6Oct1978_retyped.docx)
Makefile        Make file for building on Linux.
