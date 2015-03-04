all: blackjack.ptp

blackjack.ptp: blackjack.bin Makefile
	srec_cat blackjack.bin -binary -offset 0x0200 -o blackjack.ptp -MOS_Technologies

blackjack.bin: blackjack.o
	ld65 -t osic1p -vm -m blackjack.map -o blackjack.bin blackjack.o

blackjack.o:	blackjack.s
	ca65 -g -l blackjack.lst blackjack.s

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp

distclean: clean
