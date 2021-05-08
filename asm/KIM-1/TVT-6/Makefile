all: table2.run table3.run table4.run table5.run

table2.run: table2.bin
	srec_cat table2.bin -binary -offset 0x1780 -o table2.run -Execution_Start_Address 0x17ad

table2.bin: table2.o
	ld65 -t none -vm -m table2.map -o table2.bin table2.o

table2.o: table2.s
	ca65 -g -l table2.lst table2.s

table3.run: table3.bin
	srec_cat table3.bin -binary -offset 0x1780 -o table3.run -Execution_Start_Address 0x17ad

table3.bin: table3.o
	ld65 -t none -vm -m table3.map -o table3.bin table3.o

table3.o: table3.s
	ca65 -g -l table3.lst table3.s

table4.run: table4.bin
	srec_cat table4.bin -binary -offset 0x1780 -o table4.run -Execution_Start_Address 0x17ad

table4.bin: table4.o
	ld65 -t none -vm -m table4.map -o table4.bin table4.o

table4.o: table4.s
	ca65 -g -l table4.lst table4.s

table5.run: table5.bin
	srec_cat table5.bin -binary -offset 0x1780 -o table5.run -Execution_Start_Address 0x17ad

table5.bin: table5.o
	ld65 -t none -vm -m table5.map -o table5.bin table5.o

table5.o: table5.s
	ca65 -g -l table5.lst table5.s

clean:
	$(RM) *.o *.lst *.map *.bin *.run
