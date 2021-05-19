all: scungy.run scan.run

scungy.run: scungy.bin
	srec_cat scungy.bin -binary -offset 0x0200 -o scungy.run -Execution_Start_Address 0x17ad

scungy.bin: scungy.o
	ld65 -t none -vm -m scungy.map -o scungy.bin scungy.o

scungy.o: scungy.s
	ca65 -g -l scungy.lst scungy.s

scan.run: scan.bin
	srec_cat scan.bin -binary -offset 0x1780 -o scan.run -Execution_Start_Address 0x17ad

scan.bin: scan.o
	ld65 -t none -vm -m scan.map -o scan.bin scan.o

scan.o: scan.s
	ca65 -g -l scan.lst scan.s

clean:
	$(RM) *.o *.lst *.map *.bin *.run
