all: AppleIIcROMFF.bin AppleIIcROM00.bin AppleIIcROM03.bin AppleIIcROM04.bin

AppleIIcROMFF.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=255 -l AppleIIcROMFF-1.lst appleiicrom1.asm
	ca65 -g -DROMVER=255 -l AppleIIcROMFF-2.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROMFF.map -o AppleIIcROMFF.bin appleiicrom1.o  appleiicrom2.o

AppleIIcROM00.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=0 -l AppleIIcROM00-1.lst appleiicrom1.asm
	ca65 -g -DROMVER=0 -l AppleIIcROM00-2.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROM00.map -o AppleIIcROM00.bin appleiicrom1.o  appleiicrom2.o

AppleIIcROM03.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=3 -l AppleIIcROM03-1.lst appleiicrom1.asm
	ca65 -g -DROMVER=3 -l AppleIIcROM03-2.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROM03.map -o AppleIIcROM03.bin appleiicrom1.o  appleiicrom2.o

AppleIIcROM04.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=4 -l AppleIIcROM04-1.lst appleiicrom1.asm
	ca65 -g -DROMVER=4 -l AppleIIcROM04-2.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROM04.map -o AppleIIcROM04.bin appleiicrom1.o  appleiicrom2.o

check:	AppleIIcROMFF.bin AppleIIcROM00.bin AppleIIcROM03.bin AppleIIcROM04.bin
	cmp -b AppleIIcROM04.bin good/AppleIIcROM04.bin
	cmp -b AppleIIcROM03.bin good/AppleIIcROM03.bin
#	cmp -b AppleIIcROM00.bin good/AppleIIcROM00.bin
#	cmp -b AppleIIcROMFF.bin good/AppleIIcROMFF.bin

hex:	AppleIIcROMFF.bin AppleIIcROM00.bin AppleIIcROM03.bin AppleIIcROM04.bin
	hexdump -C AppleIIcROMFF.bin > AppleIIcROMFF.hex
	hexdump -C AppleIIcROM00.bin > AppleIIcROM00.hex
	hexdump -C AppleIIcROM03.bin > AppleIIcROM03.hex
	hexdump -C AppleIIcROM04.bin > AppleIIcROM04.hex
	hexdump -C good/AppleIIcROMFF.bin > good/AppleIIcROMFF.hex
	hexdump -C good/AppleIIcROM00.bin > good/AppleIIcROM00.hex
	hexdump -C good/AppleIIcROM03.bin > good/AppleIIcROM03.hex
	hexdump -C good/AppleIIcROM04.bin > good/AppleIIcROM04.hex

clean:
	$(RM) *.o *.lst *.bin *.hex *.map good/*.hex

distclean: clean
