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
# generated file adventure1.c1p over a serial interface using the OSI
# monitor.

# My 6502 Single Board Computer:
#
# Running "make sbc" will build for this platform using cc65. You need
# a patched version of cc65 with support for the "sbc" target as
# provided elsewhere in this git repository. Load the .run file from
# JMON using the "J" command.

# Briel Replica 1:
#
# Running "make replica1" will build for this platform using cc65. You need
# a patched version of cc65 with support for the "replica1" target as
# provided elsewhere in this git repository. Load the .mon file from
# the WozMon monitor.

# KIM-1:
#
# Running "make kim1" will build for this platform using cc65. You will
# require a KIM-1 with a 60K memory expansion. Load the PTP file from
# the serial port.

all: default

default: native

native: adventure1.c
	gcc -Wall -g -o adventure1 adventure1.c

c64:	adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t c64 adventure1.c -L /usr/local/share/cc65/lib

apple2: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t apple2enh adventure1.c -o adventure1 -L /usr/local/share/cc65/lib

osi:	adventure1.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -t osic1p adventure1.c -L /usr/local/share/cc65/lib
	srec_cat adventure1 -binary -offset 0x200 -o adventure1.c1p -Ohio_Scientific -execution-start-address=0x200
	# Below version works as well
	#CC65_HOME=/usr/local/share/cc65 cl65 -u __BOOT__ -O -t osic1p -o adventure1.c1p adventure1.c -L /usr/local/share/cc65/lib

replica1: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t replica1 adventure1.c -o adventure1 -L /usr/local/share/cc65/lib
	bintomon -1 -l 0x300 -r 0x300 adventure1 >adventure1.mon

sbc: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t sbc adventure1.c -o adventure1 -L /usr/local/share/cc65/lib
	srec_cat adventure1 -binary -offset 0x0200 -o adventure1.run -Execution_Start_Address 0x0200

kim1: adventure1.c
	CC65_HOME=/usr/local/share/cc65	cl65 -O -t kim1 -C kim1-60k.cfg adventure1.c -o adventure1 -L /usr/local/share/cc65/lib
	srec_cat adventure1 -binary -offset 0x2000 -o adventure1.ptp -MOS_Technologies

clean:
	$(RM) adventure1 *.o *.lst *.map *.mon *.run *.ptp *.c1p

distclean: clean
