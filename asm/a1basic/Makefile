all: a1basic.mon

a1basic.mon: a1basic.bin
	bintomon -v `./getaddress` a1basic.bin >a1basic.mon

a1basic.bin: a1basic.o
	ld65 -t none -vm -m a1basic.map -o a1basic.bin a1basic.o

a1basic.o:	a1basic.s
	ca65 -g -l a1basic.lst a1basic.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
