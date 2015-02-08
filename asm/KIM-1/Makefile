kim.hex: kim.bin Makefile
	srec_cat kim.bin -binary -offset 0x1800 -o kim.hex -MOS_Technologies

kim.bin: kim.o
	ld65 -t replica1 -vm -m kim.map -o kim.bin kim.o

kim.o:	kim.s
	ca65 -g -l --feature labels_without_colons kim.s

clean:
	$(RM) *.o *.lst *.map *.bin *.hex

distclean: clean
