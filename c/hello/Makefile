PLATFORM = apple2enh

all: hello1.mon hello2.mon nqueens.mon sieve.mon kim1.ptp

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

kim1: kim1.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m kim1.map -t kim1 -C kim1-60k.cfg kim1.c

kim1.ptp: kim1
	srec_cat kim1 -binary -offset 0x2000 -o kim1.ptp -MOS_Technologies

clean:
	$(RM) *.o *.lst *.map hello1 hello2 nqueens sieve kim1

distclean: clean
	$(RM) *.mon *.ptp
