# "make native" will build for local machine (e.g. Linux desktop).
# Otherwise by default will build for Apple OO using cc65.

all: default

default: native
#default: adventure2

adventure2: adventure2.c
	cl65 -O -l adventure2.lst -vm -m adventure2.map -t apple2enh adventure2.c

native: adventure2.c
	gcc -Wall -o adventure2 adventure2.c

clean:
	$(RM) adventure2.o adventure2.lst adventure2.map adventure2

distclean: clean
