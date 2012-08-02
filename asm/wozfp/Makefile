wozfp.mon: wozfp.bin
	bintomon -v -l 0x1d00 -r - wozfp.bin >wozfp.mon

wozfp.bin: wozfp.o
	ld65 -t replica1 -vm -m wozfp.map -o wozfp.bin wozfp.o

wozfp.o: wozfp.s
	ca65 -g -l wozfp.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
