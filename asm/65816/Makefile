all:	demo1.mon demo2.mon demo3.mon debug16.mon

demo1.mon: demo1.bin
	bintomon -l 0x6000 -r - demo1.bin >demo1.mon

demo1.bin: demo1.o
	ld65 -t replica1 -vm -m demo1.map -o demo1.bin demo1.o

demo1.o: demo1.s
	ca65 -g -l demo1.s

demo2.mon: demo2.bin
	bintomon -l 0x6000 -r - demo2.bin >demo2.mon

demo2.bin: demo2.o
	ld65 -t replica1 -vm -m demo2.map -o demo2.bin demo2.o

demo2.o: demo2.s
	ca65 -g -l demo2.s

demo3.mon: demo3.bin
	bintomon -l 0x6000 -r - demo3.bin >demo3.mon

demo3.bin: demo3.o
	ld65 -t replica1 -vm -m demo3.map -o demo3.bin demo3.o

demo3.o: demo3.s
	ca65 -g -l demo3.s

debug16.mon: debug16.bin
	bintomon -l 0x0280 -r - debug16.bin >debug16.mon

debug16.bin: debug16.o
	ld65 -t replica1 -vm -m debug16.map -o debug16.bin debug16.o

debug16.o: debug16.s
	ca65 -g -l debug16.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
