SRCS	= $(wildcard *.s)
MONS	= $(SRCS:.s=.mon)

all:	$(MONS)

%.mon:  %.bin
	bintomon $*.bin >$*.mon

%.bin:  %.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -o $*.bin $*.o

%.o:	%.s
	ca65 -g -l $*.lst $*.s

.PRECIOUS: %.bin

clean:
	$(RM) *.o *.lst *.mon *.bin

distclean: clean
