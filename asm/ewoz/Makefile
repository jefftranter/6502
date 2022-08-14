all:	ewoz.mon

ewoz.mon: ewoz.bin
	bintomon -1 -v `./getaddress` ewoz.bin >ewoz.mon

ewoz.bin: ewoz.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m ewoz.map -o ewoz.bin ewoz.o

ewoz.o:	ewoz.s
	ca65 -g -l ewoz.lst ewoz.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
