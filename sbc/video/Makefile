all: scungy.run scungy-orig.run

scungy.run: scungy.bin
	srec_cat scungy.bin -binary -offset 0x1fa0 -o scungy.run -Execution_Start_Address 0x0

scungy.bin: scungy.o
	ld65 -t none -vm -m scungy.map -o scungy.bin scungy.o

scungy.o: scungy.s
	ca65 -g -l scungy.lst scungy.s

scungy-orig.run: scungy-orig.bin
	srec_cat scungy-orig.bin -binary -offset 0x1fb0 -o scungy-orig.run -Execution_Start_Address 0x0

scungy-orig.bin: scungy-orig.o
	ld65 -t none -vm -m scungy-orig.map -o scungy-orig.bin scungy-orig.o

scungy-orig.o: scungy-orig.s
	ca65 -g -l scungy-orig.lst scungy-orig.s

clean:
	$(RM) *.o *.lst *.map *.bin *.run
