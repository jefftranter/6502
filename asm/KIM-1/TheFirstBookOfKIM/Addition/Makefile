all: addition.ptp

addition.ptp: addition.bin Makefile
	srec_cat addition.bin -binary -offset 0x0200 -o addition.ptp -MOS_Technologies

addition.bin: addition.o
	ld65 -t osic1p -vm -m addition.map -o addition.bin addition.o

addition.o:	addition.s
	ca65 -g -l addition.lst addition.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
