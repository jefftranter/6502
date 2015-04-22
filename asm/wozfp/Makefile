all: wozfp.mon

wozfp.mon: wozfp.bin
	bintomon -v `./getaddress` wozfp.bin >wozfp.mon

wozfp.bin: test.o
	ld65 -t none -vm -m wozfp.map -o wozfp.bin test.o

test.o: test.s wozfp.s util.s bcdfloat.s
	ca65 -g -ltest.lst test.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
