all: hello1.mon hello2.mon nqueens.mon sieve.mon

hello1.mon: hello1
	bintomon -v -f hello1 >hello1.mon

hello1: hello1.c
	cl65 -O -l -vm -m hello1.map -t replica1 hello1.c

hello2.mon: hello2
	bintomon -v -f hello2 >hello2.mon

hello2: hello2.c
	cl65 -O -l -vm -m hello2.map -t replica1 hello2.c

nqueens.mon: nqueens
	bintomon -v -f nqueens >nqueens.mon

nqueens: nqueens.c
	cl65 -O -l -vm -m nqueens.map -t replica1 nqueens.c

sieve.mon: sieve
	bintomon -v -f sieve >sieve.mon

sieve: sieve.c
	cl65 -O -l -vm -m sieve.map -t replica1 sieve.c

clean:
	$(RM) *.o *.lst *.map hello1 hello2 nqueens sieve

distclean: clean
	$(RM) *.mon
