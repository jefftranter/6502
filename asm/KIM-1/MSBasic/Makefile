# This builds the KIM-1 version of Basic and generates a PTP file that
# can be loaded from the serial monitor. Run it from address 4065.

all: kb9v2.ptp

kb9v2.o: msbasic.s
	ca65 -D kb9 msbasic.s -o kb9v2.o -l kb9v2.lst

kb9v2.bin: kb9v2.o
	ld65 -C kb9.cfg kb9v2.o -o kb9v2.bin -Ln kb9v2.lbl

kb9v2.ptp: kb9v2.bin
	srec_cat kb9v2.bin -binary -offset 0x2000 -o kb9v2.ptp -MOS_Technologies
upload:
	ascii-xfr -s -l 100 -c 100 INIT1 > /dev/ttyUSB0
	sleep 2
	ascii-xfr -s -l 100 -c 10 kb9v2.ptp > /dev/ttyUSB0
	sleep 2
	ascii-xfr -s -l 100 -c 100 INIT2 > /dev/ttyUSB0

clean:
	$(RM) *.o *.bin *.ptp *.lbl *.lst
