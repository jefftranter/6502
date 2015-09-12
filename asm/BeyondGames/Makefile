all:	C1.bin C13.bin C15.bin

C1.bin: C1.o
	ld65 -t none -vm -m C1.map -o C1.bin C1.o

C13.bin: C13.o
	ld65 -t none -vm -m C13.map -o C13.bin C13.o

C15.bin: C15.o
	ld65 -t none -vm -m C15.map -o C15.bin C15.o

C1.o:	C1.s
	ca65 -g -l C1.lst --feature labels_without_colons --feature pc_assignment C1.s

C13.o: C13.s
	ca65 -g -l C13.lst --feature labels_without_colons --feature pc_assignment C13.s

C15.o: C15.s
	ca65 -g -l C15.lst --feature labels_without_colons --feature pc_assignment C15.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin ALL.bas

distclean: clean
