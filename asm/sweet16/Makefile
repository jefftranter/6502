all:	sweet16.mon test.o

sweet16.mon: sweet16.bin
	bintomon -l 0x289 sweet16.bin >sweet16.mon

sweet16.bin: sweet16.o
	ld65 -t none -vm -m sweet16.map -o sweet16.bin sweet16.o

sweet16.o: sweet16.s
	ca65 -g -l sweet16.lst sweet16.s

test.o: test.s
	ca65 -g -l test.lst test.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
