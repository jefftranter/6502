This is a version of the A65 6502/65C02 cross-assembler.

Various versions can be found on the internet. This one came from
http://osi.marks-lab.com/software/tools.html

The sources say "A65 is a public domain work. It is derived from the
"as6502" cross-assembler written by J. H. Van Ornum and J. Swank."

I have made the following changes in this version:

- Removed some files other than source files (e.g. Windows executable).
- Removed Visual Studio related files (I only use it under Linux).
- Wrote a new make file for the Linux platform.
- Made a patch to a65 to support forcing absolute addressing for zero
  page addresses using '!'. This has only had minimal testing but seems
  to work. The documentation was updated to mention this.
- Fixed some spelling errors in the documentation.
- Fixed compile warnings with gcc on Linux.
- Bumped the version to 1.24.
