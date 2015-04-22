all: disasm.mon

disasm.mon: disasm.bin
	bintomon disasm.bin >disasm.mon

disasm.bin: disasm.o
	ld65 -t none -vm -m disasm.map -o disasm.bin disasm.o

disasm.o:	disasm.s
	ca65 -g -l disasm.lst disasm.s

archive: disasm.mon
	zip disasm-0.9.zip disasm.s disasm.mon Makefile README.txt LICENSE-2.0.txt

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
