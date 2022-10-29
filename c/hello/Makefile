PLATFORM = apple2enh

all: hello1.mon hello2.mon nqueens.mon sieve.mon

hello1.mon: hello1
	bintomon -v -f hello1 >hello1.mon

hello1: hello1.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m hello1.map -t $(PLATFORM) hello1.c

hello2.mon: hello2
	bintomon -v -f hello2 >hello2.mon

hello2: hello2.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m hello2.map -t $(PLATFORM) hello2.c

nqueens.mon: nqueens
	bintomon -v -f nqueens >nqueens.mon

nqueens: nqueens.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m nqueens.map -t $(PLATFORM) nqueens.c

sieve.mon: sieve
	bintomon -v -f sieve >sieve.mon

sieve: sieve.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m sieve.map -t $(PLATFORM) sieve.c

clean:
	$(RM) *.o *.lst *.map hello1 hello2 nqueens sieve

distclean: clean
	$(RM) *.mon
