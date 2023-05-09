all: life.c1p

life.c1p: life.c
	CC65_HOME=/usr/local/share/cc65 cl65 -u __BOOT__ -O -t osic1p -T -l life.lst -m life.map -o life.c1p life.c -L /usr/local/share/cc65/lib

clean:
	$(RM) *.lst *.map *.c1p
