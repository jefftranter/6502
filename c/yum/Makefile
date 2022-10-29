# "make native" will build for local machine (e.g. Linux desktop).
# "make yum.mon" will build for Replica 1 using CC65.

all: default

#default: native
default: yum.mon

# Below may only work with my modified version of bintomon
yum.mon: yum.bin
	bintomon -v -f yum.bin >yum.mon

yum.bin: yum.c Makefile
	CC65_HOME=/usr/local/share/cc65 cl65 -O -l yum.lst -vm -m yum.map -t apple2enh -o yum.bin yum.c -L /usr/local/share/cc65/lib

# SEND is a script I wrote.
upload: yum.mon
	SEND yum.mon

native: yum

yum:	yum.c Makefile
	gcc -g -Wall -o yum yum.c

release: yum.mon
	zip yum-1.0.zip yum.c Makefile yum.mon README.txt LICENSE-2.0.txt

clean:
	$(RM) yum.o yum.lst yum.map yum.bin yum

distclean: clean
	$(RM) yum.mon
