all: asteroid.ptp

asteroid.ptp: asteroid.bin Makefile
	srec_cat asteroid.bin -binary -offset 0x0200 -o asteroid.ptp -MOS_Technologies

asteroid.bin: asteroid.o
	ld65 -t osic1p -vm -m asteroid.map -o asteroid.bin asteroid.o

asteroid.o:	asteroid.s
	ca65 -g -l asteroid.lst asteroid.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
