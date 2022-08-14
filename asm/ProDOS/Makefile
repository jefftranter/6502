all: mliexample.bin

mliexample.bin: mliexample.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m mliexample.map -o mliexample.bin mliexample.o

mliexample.o:	mliexample.s
	ca65 -g -l mliexample.lst mliexample.s

clean:
	$(RM) mliexample.o mliexample.lst mliexample.map mliexample.bin

distclean: clean
