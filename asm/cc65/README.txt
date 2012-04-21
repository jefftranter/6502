These are patches for the CC65 assembler/compiler tools to add support
for the Apple 1 and Replica 1. The patches were based on ones for
earlier versions of CC65 and updated for 2.13.3, which was the latest
at the time of writing.

Apply the patch to the source and then build it as normal.

These commands should work under Linux to build it (or use the "build"
script):

  tar xjf cc65-sources-2.13.3.tar.bz2
  patch -p0  <cc65-2.13.3-replica1.patch
  cd cc65-2.13.3
  make -f make/gcc.mak
  sudo make -f make/gcc.mak install

I am hoping to get these patches applied to the original source at
cc65.org.
