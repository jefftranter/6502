# Adjust the run address to match the location of RES_vec
basic.mon: basic.bin
	bintomon -v -l 0x5000 -r 0x7825 basic.bin >basic.mon

basic.bin: basic.o
	ld65 -t replica1 -vm -m basic.map -o basic.bin basic.o

basic.o: basic.asm min_mon.asm
	ca65 -g -l --feature labels_without_colons -o basic.o min_mon.asm

basic.asm: source.zip
	unzip source.zip
	patch -p1 <REPLICA1.patch

clean:
	$(RM) *.o *.lst *.map *.bin basic.asm min_mon.asm readme.txt

distclean: clean

