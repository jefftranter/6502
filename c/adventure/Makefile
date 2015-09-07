# "make native" will build for local machine (e.g. Linux desktop).
# "make adventure.mon" will build for Replica 1 using CC65.

all: default

#default: native
default: adventure.mon

# Below may only work with my modified version of bintomon
adventure.mon: adventure
	bintomon -v -f adventure >adventure.mon

adventure: adventure.c
#	cl65 -O -l -vm -m adventure.map -t replica1 adventure.c
	cl65 -O -l adventure.lst -vm -m adventure.map -t apple2enh adventure.c

# SEND is a script I wrote.
upload: adventure.mon
	SEND adventure.mon

native: adventure.c
	gcc -Wall -o adventure adventure.c

release: adventure.mon
	zip adventure-1.0.zip adventure.c Makefile adventure.mon README.txt LICENSE-2.0.txt

clean:
	$(RM) adventure.o adventure.lst adventure.map adventure

distclean: clean
	$(RM) adventure.mon
