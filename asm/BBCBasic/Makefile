all: basic2.run mos.run

basic2.run: basic2.bin
	srec_cat basic2.bin -binary -offset 0x4000 -o basic2.run

basic2.bin: basic2.o
	ld65 -t none -vm -m basic2.map -o basic2.bin basic2.o

basic2.o: basic2.asm
	ca65 -g -l basic2.lst -o basic2.o basic2.asm

mos.run: mos.bin
	srec_cat mos.bin -binary -offset 0xff00 -o mos.run

mos.bin: mos.o
	ld65 -t none -vm -m mos.map -o mos.bin mos.o

mos.o: mos.asm
	ca65 -g -l mos.lst -o mos.o mos.asm

clean:
	$(RM) *.o *.lst *.run *.map *.bin

distclean: clean
