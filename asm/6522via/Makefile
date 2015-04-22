all:	exp1.mon exp2.mon exp3.mon exp4.mon exp5.mon exp6.mon

exp1.mon: exp1.bin
	bintomon -v exp1.bin >exp1.mon

exp1.bin: exp1.o
	ld65 -t none -vm -m exp1.map -o exp1.bin exp1.o

exp1.o: exp1.s
	ca65 -g -l exp1.lst exp1.s

exp2.mon: exp2.bin
	bintomon -v exp2.bin >exp2.mon

exp2.bin: exp2.o
	ld65 -t none -vm -m exp2.map -o exp2.bin exp2.o

exp2.o: exp2.s
	ca65 -g -l exp2.lst exp2.s

exp3.mon: exp3.bin
	bintomon -v exp3.bin >exp3.mon

exp3.bin: exp3.o
	ld65 -t none -vm -m exp3.map -o exp3.bin exp3.o

exp3.o: exp3.s
	ca65 -g -l exp3.lst exp3.s

exp4.mon: exp4.bin
	bintomon -v exp4.bin >exp4.mon

exp4.bin: exp4.o
	ld65 -t none -vm -m exp4.map -o exp4.bin exp4.o

exp4.o: exp4.s
	ca65 -g -l exp4.lst exp4.s

exp5.mon: exp5.bin
	bintomon -v exp5.bin >exp5.mon

exp5.bin: exp5.o
	ld65 -t none -vm -m exp5.map -o exp5.bin exp5.o

exp5.o: exp5.s
	ca65 -g -l exp5.lst exp5.s

exp6.mon: exp6.bin
	bintomon -v exp6.bin >exp6.mon

exp6.bin: exp6.o
	ld65 -t none -vm -m exp6.map -o exp6.bin exp6.o

exp6.o: exp6.s
	ca65 -g -l exp6.lst exp6.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean

archive: all
	zip 6522via.zip exp1.s exp2.x exp3.s exp4.s exp5.s exp6.s *.mon sinetable.ods Makefile
