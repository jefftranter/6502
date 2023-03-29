all: kimath.run kimath.ptp mathpac.run mathpac.ptp

kimath.o: kimath.s
	ca65 --feature labels_without_colons -g -l kimath.lst kimath.s

kimath.bin: kimath.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m kimath.map -o kimath.bin kimath.o

kimath.run: kimath.bin
	srec_cat kimath.bin -binary -unfill 0x00 10 -offset 0xf74f -o kimath.run -Execution_Start_Address 0xf800

kimath.ptp: kimath.bin
	srec_cat kimath.bin -binary -unfill 0x00 10 -offset 0xf74f -o kimath.ptp -MOS_Technologies

mathpac.o: mathpac.s
	ca65 --feature labels_without_colons -g -l mathpac.lst mathpac.s

mathpac.bin: mathpac.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m mathpac.map -o mathpac.bin mathpac.o

mathpac.run: mathpac.bin
	srec_cat mathpac.bin -binary -unfill 0x00 10 -offset 0x3000 -o mathpac.run -Execution_Start_Address 0x3607

mathpac.ptp: mathpac.bin
	srec_cat mathpac.bin -binary -unfill 0x00 10 -offset 0x3000 -o mathpac.ptp -MOS_Technologies

clean:
	$(RM) *.o *.lst *.map *.bin *.run *.ptp
