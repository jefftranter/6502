all:	C13.bin

C13.bin: C13.o
	ld65 -t none -vm -m C13.map -o C13.bin C13.o

C13.o: C13.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment C13.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
