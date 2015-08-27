all:	appleiicrom.bin

diff: appleiicrom.bin AppleIIcROM04.bin
	diff appleiicrom.bin AppleIIcROM04.bin

appleiicrom.bin: appleiicrom1.bin appleiicrom2.bin
	cat appleiicrom1.bin appleiicrom2.bin > appleiicrom.bin

hex: appleiicrom1.hex appleiicrom2.hex

appleiicrom1.hex: appleiicrom1.bin
	hexdump -C appleiicrom1.bin > appleiicrom1.hex

appleiicrom2.hex: appleiicrom2.bin
	hexdump -C appleiicrom2.bin > appleiicrom2.hex

appleiicrom1.bin: appleiicrom1.o
	ld65 -t none -vm -m appleiicrom1.map -o appleiicrom1.bin appleiicrom1.o

appleiicrom2.bin: appleiicrom2.o
	ld65 -t none -vm -m appleiicrom2.map -o appleiicrom2.bin appleiicrom2.o

appleiicrom1.o: appleiicrom1.asm
	ca65 -g -l appleiicrom1.lst appleiicrom1.asm

appleiicrom2.o: appleiicrom2.asm
	ca65 -g -l appleiicrom2.lst appleiicrom2.asm

clean:
	$(RM) appleiicrom1.o appleiicrom1.lst appleiicrom1.bin appleiicrom1.hex appleiicrom1.map
	$(RM) appleiicrom2.o appleiicrom2.lst appleiicrom2.bin appleiicrom2.hex appleiicrom2.map
	$(RM) appleiicrom.bin

distclean: clean
