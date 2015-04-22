all:	debug16.mon

debug16.mon: debug16.bin
	bintomon -l 0x6000 -r - debug16.bin >debug16.mon

debug16.bin: debug16.o
	ld65 -t none -vm -m debug16.map -o debug16.bin debug16.o

debug16.o: debug16.s
	ca65 -g -l debug16.lst debug16.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
