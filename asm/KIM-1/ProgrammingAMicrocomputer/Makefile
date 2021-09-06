all:	chapter3.ptp chapter4.ptp

chapter3.ptp: chapter3.bin Makefile
	srec_cat chapter3.bin -binary -offset 0x0000 -o chapter3.ptp -MOS_Technologies

chapter3.bin: chapter3.o
	ld65 -t none -vm -m chapter3.map -o chapter3.bin chapter3.o

chapter3.o:	chapter3.s
	ca65 -g -l chapter3.lst chapter3.s

chapter4.ptp: chapter4.bin Makefile
	srec_cat chapter4.bin -binary -offset 0x0000 -o chapter4.ptp -MOS_Technologies

chapter4.bin: chapter4.o
	ld65 -t none -vm -m chapter4.map -o chapter4.bin chapter4.o

chapter4.o:	chapter4.s
	ca65 -g -l chapter4.lst chapter4.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
