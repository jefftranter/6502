all: life.c1p

life.c1p: life.c
	CC65_HOME=/usr/local/share/cc65 cl65 -u __BOOT__ -O -t osic1p -o life.c1p life.c -L /usr/local/share/cc65/lib

clean:
	$(RM) *.c1p
