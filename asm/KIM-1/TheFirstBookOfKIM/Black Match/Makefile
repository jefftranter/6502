all: blackmatch1.ptp blackmatch2.ptp

blackmatch1.ptp: blackmatch1.bin Makefile
	srec_cat blackmatch1.bin -binary -offset 0x0200 -o blackmatch1.ptp -MOS_Technologies

blackmatch1.bin: blackmatch1.o
	ld65 -t osic1p -vm -m blackmatch1.map -o blackmatch1.bin blackmatch1.o

blackmatch1.o:	blackmatch1.s
	ca65 -g -l blackmatch1.lst blackmatch1.s

blackmatch2.ptp: blackmatch2.bin Makefile
	srec_cat blackmatch2.bin -binary -offset 0x0200 -o blackmatch2.ptp -MOS_Technologies

blackmatch2.bin: blackmatch2.o
	ld65 -t osic1p -vm -m blackmatch2.map -o blackmatch2.bin blackmatch2.o

blackmatch2.o:	blackmatch2.s
	ca65 -g -l blackmatch2.lst blackmatch2.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
