all:	sim6502

sim6502: sim6502.o main.o
	g++ -o sim6502 sim6502.o main.o

sim6502.o: sim6502.cpp sim6502.h
	g++ -Wall -g -c sim6502.cpp

main.o: sim6502.h main.cpp
	g++ -Wall -g -c main.cpp

rom.bin: rom.o
	ld65 -t none -vm -m rom.map -o rom.bin rom.o

rom.o:	rom.s
	ca65 -g -l rom.lst rom.s
clean:
	$(RM) sim6502.o main.o sim6502
	$(RM) *.o *.lst *.map *.bin

distclean: clean
