all: basic2.mon

basic2.mon: basic2.bin
	bintomon -v -l 0x5000 basic2.bin >basic2.mon

basic2.bin: basic2.o
	ld65 -t none -vm -m basic2.map -o basic2.bin basic2.o

basic2.o: basic2.asm
	ca65 -g -l basic2.lst -o basic2.o basic2.asm

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
