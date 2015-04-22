all: apple_dos_rw.o apple_dos.o

bin: apple_dos.bin

apple_dos.bin: apple_dos.o
	ld65 -t apple2 -vm -m apple_dos.map -o apple_dos.bin apple_dos.o

apple_dos_rw.o:	apple_dos_rw.s
	ca65 -g -l apple_dos_rw.lst apple_dos_rw.s

apple_dos.o:	apple_dos.s
	ca65 -g -l apple_dos.lst apple_dos.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
