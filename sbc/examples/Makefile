all: hello.bas

hello.bas: hello.bin
	../../asm/jmon/loader.py -l 4096 hello.bin >hello.bas

hello.bin: hello.o
	ld65 -t none -vm -m hello.map -o hello.bin hello.o

hello.o: hello.s
	ca65 -g -l hello.lst hello.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas
