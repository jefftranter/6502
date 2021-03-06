# Uncomment one of the following lines to set your platform
#PLATFORM=APPLE1
#PLATFORM=APPLE2
#PLATFORM=OSI
#PLATFORM=KIM1
PLATFORM=SBC

all: jmon.mon jmon.lod jmon.ptp jmon.jm jmon.run

# RUN file
jmon.run: jmon.bin
	srec_cat jmon.bin -binary -offset 0x2000 -o jmon.run -Execution_Start_Address 0x0000

# JMON load file
jmon.jm: jmon.bin
	./loader2.py -l 8192 jmon.bin >jmon.jm

# Apple 1/Replica 1/Apple 2 version binary
# Use -1 option for Apple 1, -2 option for Apple 2
jmon.mon: jmon.bin
	bintomon -v -2 `./getaddress` jmon.bin >jmon.mon

# OSI version binary
jmon.lod: jmon.bin
	~/git/6502/asm/OSI/bintolod -s 0380 -l 0380 jmon.bin >jmon.lod

# KIM-1 version binary
jmon.ptp: jmon.bin
	srec_cat jmon.bin -binary -offset 0x2000 -o jmon.ptp -MOS_Technologies

send:	jmon.lod
	ascii-xfr -s jmon.lod  >/dev/ttyUSB0

jmon.bin: jmon.o
	ld65 -t none -vm -m jmon.map -o jmon.bin jmon.o

jmon.o:	jmon.s disasm.s miniasm.s trace.s info.s memtest4.s
	ca65 -D$(PLATFORM) -g -l jmon.lst jmon.s

archive: jmon.mon
	zip jmon-0.4.zip jmon.s disasm.s miniasm.s trace.s info.s memtest4.s README.txt jmon.mon Makefile

clean:
	$(RM) jmon.o jmon.lst jmon.map jmon.bin jmon.lod jmon.mon jmon.ptp jmon.jm jmon.run
