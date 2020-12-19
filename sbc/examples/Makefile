all: hello.bas led.bas button.bas

hello.bas: hello.bin
	../../asm/jmon/loader.py -l 4096 hello.bin >hello.bas

hello.bin: hello.o
	ld65 -t none -vm -m hello.map -o hello.bin hello.o

hello.o: hello.s
	ca65 -g -l hello.lst hello.s

led.bas: led.bin
	../../asm/jmon/loader.py -l 4096 led.bin >led.bas

led.bin: led.o
	ld65 -t none -vm -m led.map -o led.bin led.o

led.o: led.s
	ca65 -g -l led.lst led.s

button.bas: button.bin
	../../asm/jmon/loader.py -l 4096 button.bin >button.bas

button.bin: button.o
	ld65 -t none -vm -m button.map -o button.bin button.o

button.o: button.s
	ca65 -g -l button.lst button.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas
