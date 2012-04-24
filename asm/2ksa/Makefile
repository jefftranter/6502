#2ksa.mon: 2ksa.bin
#	bintomon -v 2ksa.bin >2ksa.mon

2ksa.bin: 2ksa.o
	ld65 -t replica1 -vm -m 2ksa.map -o 2ksa.bin 2ksa.o

2ksa.o:	2ksa.s
	ca65 -g -l 2ksa.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
