rts: rtc.s
	ca65 -g -l rtc.lst rtc.s
	ld65 -t none -vm -o rtc.bin rtc.o
	../bintolod -s 0000 -l 0000 rtc.bin >rtc.lod

upload:
	ascii-xfr -s example1.lod >/dev/ttyUSB0 

clean:
	$(RM) rtc.o rtc.lst rtc.bin rtc.lod

