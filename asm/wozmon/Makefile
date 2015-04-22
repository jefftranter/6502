all:	wozmon.mon

wozmon.mon: wozmon.bin
	bintomon -v `./getaddress` wozmon.bin >wozmon.mon

wozmon.bin: wozmon.o
	ld65 -t none -vm -m wozmon.map -o wozmon.bin wozmon.o

wozmon.o:	wozmon.s
	ca65 -g -l wozmon.lst wozmon.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
