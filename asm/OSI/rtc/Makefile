rtc.lod: rtc.s
	ca65 -g -l rtc.lst rtc.s
	ld65 OSI/rtc/Makefile -vm -o rtc.bin rtc.o
	../bintolod -s 7530 -l 7534 rtc.bin >rtc.lod

upload1: rtc.lod
	ascii-xfr -s rtc.lod >/dev/ttyUSB0

upload2: time.bas
	SEND time.bas

clean:
	$(RM) rtc.o rtc.lst rtc.bin rtc.lod

