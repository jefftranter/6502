all:	exp1.mon jmon.mon

exp1.mon: exp1.bin
	bintomon -v exp1.bin >exp1.mon

exp1.bin: exp1.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m exp1.map -o exp1.bin exp1.o

exp1.o: exp1.s
	ca65 -g -l exp1.lst exp1.s

jmon.mon: jmon.bin
	bintomon jmon.bin >jmon.mon

jmon.bin: jmon.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m jmon.map -o jmon.bin jmon.o

jmon.o:	jmon.s
	ca65 -g -l jmon.lst jmon.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
