all: bagels.ptp

bagels.ptp: bagels.bin Makefile
	srec_cat bagels.bin -binary -offset 0x0200 -o bagels.ptp -MOS_Technologies

bagels.bin: bagels.o
	ld65 -t osic1p -vm -m bagels.map -o bagels.bin bagels.o

bagels.o:	bagels.s
	ca65 -g -l bagels.lst bagels.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
