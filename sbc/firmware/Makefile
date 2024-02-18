default: osi_bas.run wozmon.run

osi_bas.run: osi_bas.bin
	srec_cat osi_bas.bin -binary -o osi_bas.run

osi_bas.bin: osi_bas.s
	ca65 -DSBC -I /usr/local/share/cc65/asminc osi_bas.s -o osi_bas.o -l osi_bas.lst
	ld65 -C osi_bas.cfg -m osi_bas.map osi_bas.o -o osi_bas.bin

wozmon.run: wozmon.bin
	srec_cat wozmon.bin -binary -o wozmon.run

wozmon.bin: wozmon.s
	ca65 -g -l wozmon.lst wozmon.s
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m wozmon.map -o wozmon.bin wozmon.o

clean:
	$(RM) osi_bas.map osi_bas.lst osi_bas.o
	$(RM) wozmon.map wozmon.lst wozmon.o

distclean: clean
	$(RM) osi_bas.bin osi_bas.run
	$(RM) wozmon.bin wozmon.run
