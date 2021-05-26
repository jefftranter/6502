all: scungy.run

scungy.run: scungy.bin
	srec_cat scungy.bin -binary -offset 0x1f00 -o scungy.run -Execution_Start_Address 0x1f00

scungy.bin: scungy.o
	ld65 -t none -vm -m scungy.map -o scungy.bin scungy.o

scungy.o: scungy.s
	ca65 -g -l scungy.lst scungy.s

clean:
	$(RM) *.o *.lst *.map *.bin *.run
