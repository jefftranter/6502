all: basic2.run

basic2.run: basic2.bin
	srec_cat basic2.bin -binary -offset 0xc000 -o basic2.run

basic2.bin: basic2.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m basic2.map -o basic2.bin basic2.o

basic2.o: basic2.asm mos.asm
	ca65 -g -l basic2.lst -o basic2.o basic2.asm

sim: basic2.bin
	../../simulator/sim6502 -l basic2.bin -a 0xc000

program: basic2.bin
	minipro -p 27C128@DIP28 -y -w basic2.bin

verify: basic2.bin
	minipro -p 27C128@DIP28 -y -m basic2.bin

clean:
	$(RM) *.o *.lst *.run *.map *.bin

distclean: clean
