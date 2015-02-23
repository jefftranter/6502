2ksa.mon: 2ksa.bin Makefile
	bintomon -v `./getaddress` 2ksa.bin >2ksa.mon

2ksa-kim-0200.pap: 2ksa.bin
	srec_cat 2ksa.bin -binary -offset 0x0200 -o 2ksa-kim-0200.pap -MOS_Technologies -execution-start-address=0x05B8

2ksa-kim-2000.pap: 2ksa.bin
	srec_cat 2ksa.bin -binary -offset 0x2000 -o 2ksa-kim-2000.pap -MOS_Technologies -execution-start-address=0x23B8

2ksa.bin: 2ksa.o
	ld65 -t osic1p -vm -m 2ksa.map -o 2ksa.bin 2ksa.o

2ksa.o:	2ksa.s
	ca65 -g -l 2ksa.lst 2ksa.s

iosystem.o: iosystem.s
	ca65 -g -l iosystem.lst iosystem.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
