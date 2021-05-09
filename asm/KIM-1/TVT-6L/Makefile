all: scanprom.run decodeprom.run

scanprom.run: scanprom.bin
	srec_cat scanprom.bin -binary -offset 0x1780 -o scanprom.run -Execution_Start_Address 0x17ad

scanprom.bin: scanprom.o
	ld65 -t none -vm -m scanprom.map -o scanprom.bin scanprom.o

scanprom.o: scanprom.s
	ca65 -g -l scanprom.lst scanprom.s

decodeprom.run: decodeprom.bin
	srec_cat decodeprom.bin -binary -offset 0x1780 -o decodeprom.run -Execution_Start_Address 0x17ad

decodeprom.bin: decodeprom.o
	ld65 -t none -vm -m decodeprom.map -o decodeprom.bin decodeprom.o

decodeprom.o: decodeprom.s
	ca65 -g -l decodeprom.lst decodeprom.s

clean:
	$(RM) *.o *.lst *.map *.bin *.run
