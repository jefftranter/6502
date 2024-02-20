all:	wozmon.mon wozmon-serial.mon

wozmon.mon: wozmon.bin
	bintomon -v `./getaddress wozmon.map` wozmon.bin >wozmon.mon

wozmon.bin: wozmon.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m wozmon.map -o wozmon.bin wozmon.o

wozmon.o: wozmon.s
	ca65 -g -l wozmon.lst wozmon.s

wozmon-serial.mon: wozmon-serial.bin
	bintomon -v `./getaddress wozmon-serial.map` wozmon-serial.bin >wozmon-serial.mon

wozmon-serial.bin: wozmon-serial.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m wozmon-serial.map -o wozmon-serial.bin wozmon-serial.o

wozmon-serial.o: wozmon-serial.s
	ca65 -g -l wozmon-serial.lst wozmon-serial.s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
	$(RM) *.mon
