all: table2.run

table2.run: table2.bin
	srec_cat table2.bin -binary -offset 0x1780 -o table2.run -Execution_Start_Address 0x17ad

table2.bin: table2.o
	ld65 -t none -vm -m table2.map -o table2.bin table2.o

table2.o: table2.s
	ca65 -g -l table2.lst table2.s

clean:
	$(RM) *.o *.lst *.map *.bin *.bas *.jm *.run
