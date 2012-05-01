jmon.mon: jmon.bin
	bintomon -v `./getaddress` jmon.bin >jmon.mon

jmon.bin: jmon.o
	ld65 -t replica1 -vm -m jmon.map -o jmon.bin jmon.o

jmon.o:	jmon.s disasm.s memtest4.s
	ca65 -g -l jmon.s

archive: jmon.mon
	zip jmon-0.4.zip jmon.s disasm.s memtest4.s README.txt jmon.mon Makefile

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
