all:	memorytest.ptp

memorytest.ptp: memorytest.bin Makefile
	srec_cat memorytest.bin -binary -o memorytest.ptp -MOS_Technologies

memorytest.bin: memorytest.o
	ld65 -t osic1p -vm -m memorytest.map -o memorytest.bin memorytest.o

memorytest.o:	memorytest.s
	ca65 -g -l memorytest.lst memorytest.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
