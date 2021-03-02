all: hello.bas led.bas button.bas rtc.bas lcd.bas hello.jm led.jm button.jm rtc.jm lcd.jm hello.run lcd.run led.run button.run rtc.run srecloader.run srecloader.jm

hello.run: hello.bin
	srec_cat hello.bin -binary -offset 0x2000 -o hello.run -Execution_Start_Address 0x2000

hello.jm: hello.bin
	../../asm/jmon/loader2.py -l 8192 hello.bin >hello.jm

hello.bas: hello.bin
	../../asm/jmon/loader.py -l 8192 hello.bin >hello.bas

hello.bin: hello.o
	ld65 -t none -vm -m hello.map -o hello.bin hello.o

hello.o: hello.s
	ca65 -g -l hello.lst hello.s

led.run: led.bin
	srec_cat led.bin -binary -offset 0x1000 -o led.run -Execution_Start_Address 0x1000

led.jm: led.bin
	../../asm/jmon/loader2.py -l 8192 led.bin >led.jm

led.bas: led.bin
	../../asm/jmon/loader.py -l 4096 led.bin >led.bas

led.bin: led.o
	ld65 -t none -vm -m led.map -o led.bin led.o

led.o: led.s
	ca65 -g -l led.lst led.s

button.run: button.bin
	srec_cat button.bin -binary -offset 0x1000 -o button.run -Execution_Start_Address 0x1000

button.jm: button.bin
	../../asm/jmon/loader2.py -l 8192 button.bin >button.jm

button.bas: button.bin
	../../asm/jmon/loader.py -l 4096 button.bin >button.bas

button.bin: button.o
	ld65 -t none -vm -m button.map -o button.bin button.o

button.o: button.s
	ca65 -g -l button.lst button.s

rtc.run: rtc.bin
	srec_cat rtc.bin -binary -offset 0x7000 -o rtc.run -Execution_Start_Address 0x7000

rtc.jm: rtc.bin
	../../asm/jmon/loader2.py -l 28672 rtc.bin >rtc.jm

rtc.bas: rtc.bin
	../../asm/jmon/loader.py -l 28672 rtc.bin >rtc.bas

rtc.bin: rtc.o
	ld65 -t none -vm -m rtc.map -o rtc.bin rtc.o

rtc.o: rtc.s
	ca65 -g -l rtc.lst rtc.s

lcd.run: lcd.bin
	srec_cat lcd.bin -binary -offset 0x7000 -o lcd.run -Execution_Start_Address 0x7000

lcd.jm: lcd.bin
	../../asm/jmon/loader2.py -l 28672 lcd.bin >lcd.jm

lcd.bas: lcd.bin
	../../asm/jmon/loader.py -l 28672 lcd.bin >lcd.bas

lcd.bin: lcd.o
	ld65 -t none -vm -m lcd.map -o lcd.bin lcd.o

lcd.o: lcd.s
	ca65 -g -l lcd.lst lcd.s

srecloader.run: srecloader.bin
	srec_cat srecloader.bin -binary -offset 0x3000 -o srecloader.run -Execution_Start_Address 0x3000

srecloader.jm: srecloader.bin
	../../asm/jmon/loader2.py -l 12288 srecloader.bin >srecloader.jm

srecloader.bas: srecloader.bin
	../../asm/jmon/loader.py -l 12288 srecloader.bin >srecloader.bas

srecloader.bin: srecloader.o
	ld65 -t none -vm -m srecloader.map -o srecloader.bin srecloader.o

srecloader.o: srecloader.s
	ca65 -g -l srecloader.lst srecloader.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas *.jm *.run
