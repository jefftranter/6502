all: bitz.ptp

bitz.ptp: bitz.bin Makefile
	srec_cat bitz.bin -binary -offset 0x0200 -o bitz.ptp -MOS_Technologies

bitz.bin: bitz.o
	ld65 -t osic1p -vm -m bitz.map -o bitz.bin bitz.o

bitz.o:	bitz.s
	ca65 -g -l bitz.lst bitz.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
