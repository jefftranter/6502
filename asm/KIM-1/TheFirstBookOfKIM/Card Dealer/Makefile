all: carddealer.ptp

carddealer.ptp: carddealer.bin Makefile
	srec_cat carddealer.bin -binary -offset 0x0000 -o carddealer.ptp -MOS_Technologies

carddealer.bin: carddealer.o
	ld65 -t osic1p -vm -m carddealer.map -o carddealer.bin carddealer.o

carddealer.o:	carddealer.s
	ca65 -g -l carddealer.lst carddealer.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
