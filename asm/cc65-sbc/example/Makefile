PLATFORM = sbc

all: hello.run sieve.run

hello.run: hello
	srec_cat hello -binary -offset 0x0200 -o hello.run -Execution_Start_Address 0x0200

sieve.run: sieve
	srec_cat sieve -binary -offset 0x0200 -o sieve.run -Execution_Start_Address 0x0200

hello: hello.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m hello.map -t $(PLATFORM) hello.c

sieve: sieve.c
	CC65_HOME=/usr/local/share/cc65 cl65 -O -vm -m sieve.map -t $(PLATFORM) sieve.c

clean:
	$(RM) *.lst *.map *.run hello sieve

