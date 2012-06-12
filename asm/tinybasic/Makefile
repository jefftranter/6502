# Adjust the run address to match the .org in the source code
TinyBasic.mon: TinyBasic.bin
	bintomon -v -l 0x7600 TinyBasic.bin >TinyBasic.mon

TinyBasic.bin: TinyBasic.o
	ld65 -t replica1 -vm -m TinyBasic.map -o TinyBasic.bin TinyBasic.o

TinyBasic.o: TinyBasic.asm
	ca65 -g -l --feature labels_without_colons -o TinyBasic.o TinyBasic.asm

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
