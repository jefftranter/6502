all: kimath.run kimath.ptp mathpac.run mathpac.ptp example.run example.ptp

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
	srec_cat mathpac.bin -binary -offset 0x0000 -crop 0x0000 0x0001 0x0300 0x0400 0x3000 0x37e9 -o mathpac.run -Execution_Start_Address 0x3607

mathpac.ptp: mathpac.bin
	srec_cat mathpac.bin -binary -offset 0x0000 -crop 0x0000 0x0001 0x0300 0x0400 0x3000 0x37e9 -o mathpac.ptp -MOS_Technologies

example.o: example.s
	ca65 --feature labels_without_colons -g -l example.lst example.s

example.bin: example.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m example.map -o example.bin example.o

example.run: example.bin
	srec_cat example.bin -binary -offset 0x5000 -o example.run -Execution_Start_Address 0x501F

example.ptp: example.bin
	srec_cat example.bin -binary -offset 0x5000 -o example.ptp -MOS_Technologies

upload: kimath.ptp mathpac.ptp
	echo "L" >/dev/ttyUSB0
	sleep 1
	ascii-xfr -s -l 50 -c 10 kimath.ptp > /dev/ttyUSB0
	sleep 1
	echo "L" >/dev/ttyUSB0
	ascii-xfr -s -l 50 -c 10 mathpac.ptp > /dev/ttyUSB0
	sleep 1
	echo "3607 G" >/dev/ttyUSB0

clean:
	$(RM) *.o *.lst *.map *.bin *.run *.ptp
