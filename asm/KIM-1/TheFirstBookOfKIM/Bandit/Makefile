all: bandit.ptp

bandit.ptp: bandit.bin Makefile
	srec_cat bandit.bin -binary -offset 0x0200 -o bandit.ptp -MOS_Technologies

bandit.bin: bandit.o
	ld65 -t osic1p -vm -m bandit.map -o bandit.bin bandit.o

bandit.o:	bandit.s
	ca65 -g -l bandit.lst bandit.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
