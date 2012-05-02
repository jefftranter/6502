a1basic.mon: a1basic.bin
	bintomon -v -l 0xe000 -r 0xe000 a1basic.bin >a1basic.mon

a1basic.bin: a1basic.o
	ld65 -t replica1 -vm -m a1basic.map -o a1basic.bin a1basic.o

a1basic.o:	a1basic.s
	ca65 -g -l a1basic.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
