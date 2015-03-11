all:	kim.ptp

kim.ptp: kim.bin Makefile
	srec_cat kim.bin -binary -offset 0x1800 -o kim.ptp -MOS_Technologies

kim.bin: kim.o
	ld65 -t none -vm -m kim.map -o kim.bin kim.o

kim.o:	kim.s
	ca65 -g -l kim.lst --feature labels_without_colons kim.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
