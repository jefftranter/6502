#all: AppleIIcROM00.bin AppleIIcROM03.bin AppleIIcROM04.bin AppleIIcROMFF.bin 

all: AppleIIcROM03.bin AppleIIcROM03.bin

AppleIIcROM04.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=4 -l AppleIIcROM04.lst appleiicrom1.asm
	ca65 -g -DROMVER=4 -l AppleIIcROM04.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROM04.map -o AppleIIcROM04.bin appleiicrom1.o  appleiicrom2.o

AppleIIcROM03.bin: appleiicrom1.asm  appleiicrom2.asm
	ca65 -g -DROMVER=3 -l AppleIIcROM03.lst appleiicrom1.asm
	ca65 -g -DROMVER=3 -l AppleIIcROM03.lst appleiicrom2.asm
	ld65 -t none -vm -m AppleIIcROM03.map -o AppleIIcROM03.bin appleiicrom1.o  appleiicrom2.o

check:	AppleIIcROM03.bin AppleIIcROM04.bin
	diff AppleIIcROM03.bin good/AppleIIcROM03.bin
	diff AppleIIcROM04.bin good/AppleIIcROM04.bin

hex:	AppleIIcROM03.bin  AppleIIcROM04.bin
	hexdump -C AppleIIcROM03.bin > AppleIIcROM03.hex
	hexdump -C AppleIIcROM04.bin > AppleIIcROM04.hex
	hexdump -C good/AppleIIcROM03.bin > good/AppleIIcROM03.hex
	hexdump -C good/AppleIIcROM04.bin > good/AppleIIcROM04.hex

clean:
	$(RM) *.o *.lst *.bin *.hex *.map good/*.hex

distclean: clean
