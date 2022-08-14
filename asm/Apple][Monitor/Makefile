all:	appleiimonitor.mon

appleiimonitor.mon: appleiimonitor.bin
	bintomon -v `./getaddress` appleiimonitor.bin >appleiimonitor.mon

appleiimonitor.bin: appleiimonitor.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m appleiimonitor.map -o appleiimonitor.bin appleiimonitor.o

appleiimonitor.o: appleiimonitor.s
	ca65 -g -l appleiimonitor.lst appleiimonitor.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
