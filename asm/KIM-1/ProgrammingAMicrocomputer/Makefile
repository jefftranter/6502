all:	chapter3.ptp chapter4.ptp chapter5.ptp chapter6.ptp chapter7.ptp chapter8.ptp

%.ptp:  %.bin Makefile
	srec_cat $*.bin -binary -offset 0x0000 -o $*.ptp -MOS_Technologies

%.bin:  %.o
	ld65 -t none -vm -m $*.map -o $*.bin $*.o

%.o:	%.s
	ca65 -g -l $*.lst $*.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
