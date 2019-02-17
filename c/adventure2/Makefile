# "make native" will build for local machine (e.g. Linux desktop).
# Can also  build for Commodore 64 using cc65.

all: default

default: native

adventure2: adventure2.c
	cl65 -O -t c64 adventure2.c -L /usr/local/share/cc65/lib

native: adventure2.c
	gcc -Wall -g -o adventure2 adventure2.c

clean:
	$(RM) adventure2.o adventure2.lst adventure2.map adventure2

distclean: clean
