PLATFORM = replica1

all: hello.mon sieve.mon

hello.mon: hello
	bintomon -1 -l 0x300 -r 0x300 hello >hello.mon

sieve.mon: sieve
	bintomon -1 -l 0x300 -r 0x300 sieve >sieve.mon

hello: hello.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m hello.map -t $(PLATFORM) hello.c

sieve: sieve.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m sieve.map -t $(PLATFORM) sieve.c

clean:
	$(RM) *.lst *.map *.mon hello sieve

