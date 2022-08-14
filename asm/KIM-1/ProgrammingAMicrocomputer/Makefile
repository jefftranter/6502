all:	chapter3.ptp chapter4.ptp chapter5.ptp chapter6.ptp chapter7.ptp chapter8.ptp chapter9.ptp chapter10.ptp chapter11.ptp chapter12.ptp chapter13.ptp chapter14.ptp

%.ptp:  %.bin Makefile
	srec_cat $*.bin -binary -offset 0x0000 -unfill 0x00 16 -o $*.ptp -MOS_Technologies

%.bin:  %.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m $*.map -o $*.bin $*.o

%.o:	%.s
	ca65 -g -l $*.lst $*.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
