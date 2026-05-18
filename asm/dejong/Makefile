SRCS	= $(wildcard *.s)
MONS	= $(SRCS:.s=.mon)

all:	$(MONS)

%.mon:  %.bin Makefile
	bintomon -v $*.bin >$*.mon

%.bin:  %.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m $*.map -o $*.bin $*.o

%.o:	%.s
	ca65 -g -l $*.lst $*.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin

distclean: clean
