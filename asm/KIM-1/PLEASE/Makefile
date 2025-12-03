
all: please.ptp program1.ptp program2.ptp program3.ptp program4.ptp program5.ptp

please.ptp: please.bin Makefile
	srec_cat please.bin -binary -offset 0x00a0 -crop 0x00a0 0x00ef 0x0100 0x0120 0x0200 0x0400 0x1780 0x17e5 -o please.ptp -MOS_Technologies

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

program2.ptp: program2.bin Makefile
	srec_cat program2.bin -binary -offset 0x0000 -crop 0x0000 0x008c 0x0120 0x01e4 -o program2.ptp -MOS_Technologies

program2.bin: program2.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m program2.map -o program2.bin program2.o

program2.o:	program2.s
	ca65 -g -l program2.lst program2.s

program3.ptp: program3.bin Makefile
	srec_cat program3.bin -binary -offset 0x0000 -crop 0x0000 0x0068 0x0120 0x0121f -o program3.ptp -MOS_Technologies

program3.bin: program3.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m program3.map -o program3.bin program3.o

program3.o:	program3.s
	ca65 -g -l program3.lst program3.s

program4.ptp: program4.bin Makefile
	srec_cat program4.bin -binary -offset 0x0000 -crop 0x0000 0x0044 0x0120 0x01b6 -o program4.ptp -MOS_Technologies

program4.bin: program4.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m program4.map -o program4.bin program4.o

program4.o:	program4.s
	ca65 -g -l program4.lst program4.s

program5.ptp: program5.bin Makefile
	srec_cat program5.bin -binary -offset 0x0000 -crop 0x0000 0x00a0 0x0120 0x0172 -o program5.ptp -MOS_Technologies

program5.bin: program5.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m program5.map -o program5.bin program5.o

program5.o:	program5.s
	ca65 -g -l program5.lst program5.s

clean:
	$(RM) *.o *.map *.bin

distclean: clean
	$(RM) *.lst *.ptp
