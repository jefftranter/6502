
all: please.ptp program1.ptp

please.ptp: please.bin Makefile
	srec_cat please.bin -binary -offset 0x0100 -crop 0x0100 0x0120 0x0200 0x0400 0x1780 0x17e5 -o please.ptp -MOS_Technologies

please.bin: please.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m please.map -o please.bin please.o

please.o:	please.s
	ca65 -g -l please.lst please.s

program1.ptp: program1.bin Makefile
	srec_cat program1.bin -binary -offset 0x0000 -crop 0x0000 0x008c 0x0120 0x01ef -o program1.ptp -MOS_Technologies

program1.bin: program1.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m program1.map -o program1.bin program1.o

program1.o:	program1.s
	ca65 -g -l program1.lst program1.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
