all: hello.bas led.bas button.bas rtc.bas lcd.bas hello.jm led.jm button.jm rtc.jm lcd.jm

hello.jm: hello.bin
	../../asm/jmon/loader2.py -l 8192 hello.bin >hello.jm

hello.bas: hello.bin
	../../asm/jmon/loader.py -l 8192 hello.bin >hello.bas

hello.bin: hello.o
	ld65 -t none -vm -m hello.map -o hello.bin hello.o

hello.o: hello.s
	ca65 -g -l hello.lst hello.s

led.jm: led.bin
	../../asm/jmon/loader2.py -l 8192 led.bin >led.jm

led.bas: led.bin
	../../asm/jmon/loader.py -l 4096 led.bin >led.bas

led.bin: led.o
	ld65 -t none -vm -m led.map -o led.bin led.o

led.o: led.s
	ca65 -g -l led.lst led.s

button.jm: button.bin
	../../asm/jmon/loader2.py -l 8192 button.bin >button.jm

button.bas: button.bin
	../../asm/jmon/loader.py -l 4096 button.bin >button.bas

button.bin: button.o
	ld65 -t none -vm -m button.map -o button.bin button.o

button.o: button.s
	ca65 -g -l button.lst button.s

rtc.jm: rtc.bin
	../../asm/jmon/loader2.py -l 28672 rtc.bin >rtc.jm

rtc.bas: rtc.bin
	../../asm/jmon/loader.py -l 28672 rtc.bin >rtc.bas

rtc.bin: rtc.o
	ld65 -t none -vm -m rtc.map -o rtc.bin rtc.o

rtc.o: rtc.s
	ca65 -g -l rtc.lst rtc.s

lcd.jm: lcd.bin
	../../asm/jmon/loader2.py -l 28672 lcd.bin >lcd.jm

lcd.bas: lcd.bin
	../../asm/jmon/loader.py -l 28672 lcd.bin >lcd.bas

lcd.bin: lcd.o
	ld65 -t none -vm -m lcd.map -o lcd.bin lcd.o

lcd.o: lcd.s
	ca65 -g -l lcd.lst lcd.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas *.jm
