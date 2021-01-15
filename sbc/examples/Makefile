all: hello.bas led.bas button.bas rtc.bas lcd1.bas lcd2.bas hello.jm led.jm button.jm rtc.jm lcd1.jm lcd2.jm

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

lcd1.jm: lcd1.bin
	../../asm/jmon/loader2.py -l 28672 lcd1.bin >lcd1.jm

lcd1.bas: lcd1.bin
	../../asm/jmon/loader.py -l 28672 lcd1.bin >lcd1.bas

lcd1.bin: lcd1.o
	ld65 -t none -vm -m lcd1.map -o lcd1.bin lcd1.o

lcd1.o: lcd1.s
	ca65 -g -l lcd1.lst lcd1.s

lcd2.jm: lcd2.bin
	../../asm/jmon/loader2.py -l 28672 lcd2.bin >lcd2.jm

lcd2.bas: lcd2.bin
	../../asm/jmon/loader.py -l 28672 lcd2.bin >lcd2.bas

lcd2.bin: lcd2.o
	ld65 -t none -vm -m lcd2.map -o lcd2.bin lcd2.o

lcd2.o: lcd2.s
	ca65 -g -l lcd2.lst lcd2.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas *.jm
