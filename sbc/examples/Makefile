all: bas jm run

bas: button.bas hello.bas lcd.bas led.bas rtc.bas ds1302.bas dht.bas

jm: button.jm hello.jm lcd.jm led.jm rtc.jm ds1302.jm dht.jm

run: button.run hello.run lcd.run led.run rtc.run ds1302.run dht.run

hello.run: hello.bin
	srec_cat hello.bin -binary -offset 0x2000 -o hello.run -Execution_Start_Address 0x2000

hello.jm: hello.bin
	../../asm/jmon/loader2.py -l 8192 hello.bin >hello.jm

hello.bas: hello.bin
	../../asm/jmon/loader.py -l 8192 hello.bin >hello.bas

hello.bin: hello.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m hello.map -o hello.bin hello.o

hello.o: hello.s
	ca65 -g -l hello.lst hello.s

led.run: led.bin
	srec_cat led.bin -binary -offset 0x1000 -o led.run -Execution_Start_Address 0x1000

led.jm: led.bin
	../../asm/jmon/loader2.py -l 8192 led.bin >led.jm

led.bas: led.bin
	../../asm/jmon/loader.py -l 4096 led.bin >led.bas

led.bin: led.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m led.map -o led.bin led.o

led.o: led.s
	ca65 -g -l led.lst led.s

button.run: button.bin
	srec_cat button.bin -binary -offset 0x1000 -o button.run -Execution_Start_Address 0x1000

button.jm: button.bin
	../../asm/jmon/loader2.py -l 4096 button.bin >button.jm

button.bas: button.bin
	../../asm/jmon/loader.py -l 4096 button.bin >button.bas

button.bin: button.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m button.map -o button.bin button.o

button.o: button.s
	ca65 -g -l button.lst button.s

rtc.run: rtc.bin
	srec_cat rtc.bin -binary -offset 0x7000 -o rtc.run -Execution_Start_Address 0x7000

rtc.jm: rtc.bin
	../../asm/jmon/loader2.py -l 28672 rtc.bin >rtc.jm

rtc.bas: rtc.bin
	../../asm/jmon/loader.py -l 28672 rtc.bin >rtc.bas

rtc.bin: rtc.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m rtc.map -o rtc.bin rtc.o

rtc.o: rtc.s
	ca65 -g -l rtc.lst rtc.s

lcd.run: lcd.bin
	srec_cat lcd.bin -binary -offset 0x7000 -o lcd.run -Execution_Start_Address 0x7000

lcd.jm: lcd.bin
	../../asm/jmon/loader2.py -l 28672 lcd.bin >lcd.jm

lcd.bas: lcd.bin
	../../asm/jmon/loader.py -l 28672 lcd.bin >lcd.bas

lcd.bin: lcd.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m lcd.map -o lcd.bin lcd.o

lcd.o: lcd.s
	ca65 -g -l lcd.lst lcd.s

srecloader.run: srecloader.bin
	srec_cat srecloader.bin -binary -offset 0x3000 -o srecloader.run -Execution_Start_Address 0x3000

srecloader.jm: srecloader.bin
	../../asm/jmon/loader2.py -l 12288 srecloader.bin >srecloader.jm

srecloader.bas: srecloader.bin
	../../asm/jmon/loader.py -l 12288 srecloader.bin >srecloader.bas

srecloader.bin: srecloader.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m srecloader.map -o srecloader.bin srecloader.o

srecloader.o: srecloader.s
	ca65 -g -l srecloader.lst srecloader.s

ds1302.run: ds1302.bin
	srec_cat ds1302.bin -binary -offset 0x1000 -o ds1302.run -Execution_Start_Address 0x1000

ds1302.jm: ds1302.bin
	../../asm/jmon/loader2.py -l 4096 ds1302.bin >ds1302.jm

ds1302.bas: ds1302.bin
	../../asm/jmon/loader.py -l 4096 ds1302.bin >ds1302.bas

ds1302.bin: ds1302.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m ds1302.map -o ds1302.bin ds1302.o

ds1302.o: ds1302.s
	ca65 -g -l ds1302.lst ds1302.s

dht.run: dht.bin
	srec_cat dht.bin -binary -offset 0x1000 -o dht.run -Execution_Start_Address 0x1000

dht.jm: dht.bin
	../../asm/jmon/loader2.py -l 4096 dht.bin >dht.jm

dht.bas: dht.bin
	../../asm/jmon/loader.py -l 4096 dht.bin >dht.bas

dht.bin: dht.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m dht.map -o dht.bin dht.o

dht.o: dht.s
	ca65 -g -l dht.lst dht.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas *.jm *.run
