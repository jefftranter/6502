all:	kim apple

kim:	2ksa-kim-0200.ptp 2ksa-kim-2000.ptp

apple:	2ksa-apple.mon

2ksa-apple.mon: 2ksa-apple.bin
	bintomon -v `./getaddress` 2ksa-apple.bin >2ksa-apple.mon

2ksa-kim-0200.ptp: 2ksa-kim-0200.bin
	srec_cat 2ksa-kim-0200.bin -binary -offset 0x0200 -o 2ksa-kim-0200.ptp -MOS_Technologies -execution-start-address=0x05B8

2ksa-kim-2000.ptp: 2ksa-kim-2000.bin
	srec_cat 2ksa-kim-2000.bin -binary -offset 0x2000 -o 2ksa-kim-2000.ptp -MOS_Technologies -execution-start-address=0x23B8

2ksa-kim-0200.bin: 2ksa-kim-0200.o
	ld65 -t none -vm -m 2ksa-kim-0200.map -o 2ksa-kim-0200.bin 2ksa-kim-0200.o

2ksa-kim-2000.bin: 2ksa-kim-2000.o
	ld65 -t none -vm -m 2ksa-kim-2000.map -o 2ksa-kim-2000.bin 2ksa-kim-2000.o

2ksa-apple.bin: 2ksa-apple.o
	ld65 -t none -vm -m 2ksa-apple.map -o 2ksa-apple.bin 2ksa-apple.o

2ksa-kim-0200.o: 2ksa.s
	ca65 -D KIM1 -DSTARTADDRESS=\$$0200 -g -l 2ksa-kim-0200.lst -o 2ksa-kim-0200.o 2ksa.s

2ksa-kim-2000.o: 2ksa.s
	ca65 -D KIM1 -DSTARTADDRESS=\$$2000 -g -l 2ksa-kim-2000.lst -o 2ksa-kim-2000.o 2ksa.s

2ksa-apple.o: 2ksa.s
	ca65 -D REPLICA1 -DSTARTADDRESS=\$$02E2 -g -l 2ksa-apple.lst -o 2ksa-apple.o 2ksa.s

iosystem.o: iosystem.s
	ca65 -g -l iosystem.lst iosystem.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon *.ptp
