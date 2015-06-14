all:	demo1.mon demo2.mon demo3.mon demo4.mon

demo1.mon: demo1.bin
	bintomon -l 0x1000 demo1.bin >demo1.mon

demo1.bin: demo1.o
	ld65 -t none -vm -m demo1.map -o demo1.bin demo1.o

demo1.o: demo1.s
	ca65 -g -l demo1.lst demo1.s

demo2.mon: demo2.bin
	bintomon -l 0x1000 demo2.bin >demo2.mon

demo2.bin: demo2.o
	ld65 -t none -vm -m demo2.map -o demo2.bin demo2.o

demo2.o: demo2.s
	ca65 -g -l demo2.lst demo2.s

demo3.mon: demo3.bin
	bintomon -l 0x1000 demo3.bin >demo3.mon

demo3.bin: demo3.o
	ld65 -t none -vm -m demo3.map -o demo3.bin demo3.o

demo3.o: demo3.s
	ca65 -g -l demo3.lst demo3.s

demo4.mon: demo4.bin
	bintomon -l 0x1000 demo4.bin >demo4.mon

demo4.bin: demo4.o
	ld65 -t none -vm -m demo4.map -o demo4.bin demo4.o

demo4.o: demo4.s
	ca65 -g -l demo4.lst demo4.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
