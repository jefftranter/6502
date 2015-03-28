all:	TinyBasic.ptp

TinyBasic.ptp: TinyBasic.bin
	srec_cat TinyBasic.bin -binary -offset 0x0100 -crop 0x0100 0x0115 0x0200 0x1000 -o TinyBasic.ptp -MOS_Technologies

TinyBasic.bin: TinyBasic.o
	ld65 -t none -vm -m TinyBasic.map -o TinyBasic.bin TinyBasic.o

TinyBasic.o: TinyBasic.s
	ca65 -g -l TinyBasic.lst --feature labels_without_colons -o TinyBasic.o TinyBasic.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.ptp
