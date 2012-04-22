all: hello1.mon hello2.mon

hello1.mon: hello1
	bintomon -v -f hello1 >hello1.mon

hello1: hello1.c
	cl65 -O -l -vm -m hello1.map -t replica1 hello1.c

hello2.mon: hello2
	bintomon -v -f hello2 >hello2.mon

hello2: hello2.c
	cl65 -O -l -vm -m hello2.map -t replica1 hello2.c

clean:
	$(RM) *.o *.lst *.map hello1 hello2

distclean: clean
	$(RM) *.mon
