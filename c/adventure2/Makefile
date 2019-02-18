# "make native" will build for local machine (e.g. Linux desktop).
# "make cc65" will build for Commodore 64 using cc65.

all: default

default: native

native: adventure2.c
	gcc -Wall -g -o adventure2 adventure2.c

cc65: adventure2.c
	cl65 -O -t c64 adventure2.c -L /usr/local/share/cc65/lib

install: cc65
	c1541 /media/tranter/5CC8-F90F/adventure2.d64 -delete adventure2 -write adventure2

clean:
	$(RM) adventure2.o adventure2.lst adventure2.map adventure2

distclean: clean
