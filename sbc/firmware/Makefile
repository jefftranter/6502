rom.bin: osi_bas.s
	ca65 -DSBC osi_bas.s -o osi_bas.o -l osi_bas.lst
	ld65 -C osi_bas.cfg osi_bas.o -o osi_bas.bin

clean:
	$(RM) osi_bas.bin osi_bas.lst osi_bas.o
