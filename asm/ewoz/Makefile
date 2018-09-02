all:	ewoz.mon

ewoz.mon: ewoz.bin
	bintomon -1 -v `./getaddress` ewoz.bin >ewoz.mon

ewoz.bin: ewoz.o
	ld65 -t none -vm -m ewoz.map -o ewoz.bin ewoz.o

ewoz.o:	ewoz.s
	ca65 -g -l ewoz.lst ewoz.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
