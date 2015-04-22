all: wozaci.mon

wozaci.mon: wozaci.bin
	bintomon -v `./getaddress` wozaci.bin >wozaci.mon

wozaci.bin: wozaci.o
	ld65 -t none -vm -m wozaci.map -o wozaci.bin wozaci.o

wozaci.o: wozaci.s
	ca65 -g -l wozaci.lst wozaci.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
