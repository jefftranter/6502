all:	example-2-1.mon example-2-2.mon example-2-3.mon example-2-4.mon \
	example-2-5.mon example-2-6.mon example-2-7.mon example-2-8.mon \
	example-2-9.mon exercise-2-1.mon exercise-2-2.mon exercise-2-3.mon \
	exercise-2-4.mon exercise-2-5.mon exercise-2-7.mon exercise-2-8.mon \
	example-3-6.mon example-3-7.mon example-3-8.mon example-3-9.mon \
	example-3-10.mon example-3-11.mon example-3-12.mon example-3-13.mon \
	exercise-3-1.mon

%.mon:  %.bin Makefile
	bintomon -v $*.bin >$*.mon

%.bin:  %.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m $*.map -o $*.bin $*.o

%.o:	%.s
	ca65 -g -l $*.lst $*.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
