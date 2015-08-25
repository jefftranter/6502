all:	appleiicrom.bin

appleiicrom.hex: appleiicrom.bin
	hexdump -C appleiicrom.bin > appleiicrom.hex

appleiicrom.bin: appleiicrom.o
	ld65 -t none -vm -m appleiicrom.map -o appleiicrom.bin appleiicrom.o

appleiicrom.o: appleiicrom.asm
	ca65 -g -l appleiicrom.lst appleiicrom.asm

clean:
	$(RM) appleiicrom.o appleiicrom.lst appleiicrom.bin appleiicrom.hex appleiicrom.map

distclean: clean
