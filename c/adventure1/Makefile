# Instructions for building in running on various platforms:

# Desktop computers:
#
# Running "make native" will build on a machine that has a native C
# compiler and C library. It has been tested on the Ubuntu Linux
# desktop but should also work on other desktop platforms like Windows
# and macOS. You can directly run the executable.

# Commodore 64 and compatibles like the C64 Mini:
#
# Running "make c64" will build for the Commodore 64 using cc65. Copy
# the resulting file "adventure1" to your media and run it from BASIC
# using the commands:
#
#   LOAD"ADVENTURE1",8
#   RUN
#
# With a C64 Mini you can use the Linux utility c1541 to copy the file
# to a USB key that has a d64 filesystem on it, and then insert the USB key
# into the C64 Mini to run it.
# The other Commodore platforms supported by cc65 like the c16, c128,
# and vic20 should work if the relevant -t <system> option is used,
# but have not been tested.

# Apple 2 series:
#
# Running "make apple2" will build for the Apple 2 platform using
# cc65. Copy the resulting file "adventure1" to your media and run it
# from BASIC. I have tested it with an Apple //c using a FloppyEmu
# flash drive. I used AppleCommander to copy the binary to a ProDOS
# disk image.

# Ohio Scientific Challenger 1P/SuperBoard II and compatibles like the Briel Superboard III:
#
# Running "make osi" will build for this platform. Transfer the
# generated file adventure1.mon over a serial interface using the OSI
# monitor.
# Not currently supported as cc65 does not support file i/o on the
# OSIC1P platform.

# Apple 1 and compatibles like the Briel Replica 1:
# TBD

all: default

default: native

native: adventure1.c
	gcc -Wall -g -o adventure1 adventure1.c

c64:	adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t c64 adventure1.c -L /usr/local/share/cc65/lib

apple2: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t apple2enh adventure1.c -o adventure1 -L /usr/local/share/cc65/lib

osi:	adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t osic1p adventure1.c -L /usr/local/share/cc65/lib
	bintomon -l 0x200 -r 0x200 adventure1 >adventure1.mon

replica1: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t replica1 adventure1.c -o adventure1 -L /usr/local/share/cc65/lib

apple1: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t apple1 adventure1.c -o adventure1 -L /usr/local/share/cc65/lib

clean:
	$(RM) adventure1.o adventure1.lst adventure1.map adventure1 adventure1.mon

distclean: clean
