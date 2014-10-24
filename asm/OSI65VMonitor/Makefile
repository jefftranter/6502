all:	osi65v.bin

osi65v.bin: osi65v.o
	ld65 -t none -vm -m osi65v.map -o osi65v.bin osi65v.o

osi65v.o: osi65v.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment osi65v.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin ALL.bas

distclean: clean
