all: apple_dos_rw.o apple_dos.o

apple_dos_rw.o:	apple_dos_rw.s
	ca65 -g -l apple_dos_rw.s

apple_dos.o:	apple_dos.s
	ca65 -g -l apple_dos.s

clean:
	$(RM) *.o *.lst *.map

distclean: clean
