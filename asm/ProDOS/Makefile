all: mliexample.bin

mliexample.bin: mliexample.o
	ld65 -t none -vm -m mliexample.map -o mliexample.bin mliexample.o

mliexample.o:	mliexample.s
	ca65 -g -l mliexample.lst mliexample.s

clean:
	$(RM) mliexample.o mliexample.lst mliexample.map mliexample.bin

distclean: clean
