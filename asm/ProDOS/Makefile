all: mliexample.bin bitsyboot.bin

mliexample.bin: mliexample.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m mliexample.map -o mliexample.bin mliexample.o

mliexample.o:	mliexample.s
	ca65 -g -l mliexample.lst mliexample.s

bitsyboot.bin: bitsyboot.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m bitsyboot.map -o bitsyboot.bin bitsyboot.o

bitsyboot.o:	bitsyboot.s
	ca65 -g -l bitsyboot.lst bitsyboot.s

clean:
	$(RM) mliexample.o mliexample.lst mliexample.map mliexample.bin
	$(RM) bitsyboot.o bitsyboot.lst bitsyboot.map bitsyboot.bin

distclean: clean
