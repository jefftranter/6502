all: osirom.lod basicrom.lod cegmon.lod os65dv32.bin os65dv33.bin basic32.bin basic33.bin compare.bin copier32.bin copier33.bin os65d32.bin os65d33.bin exmon.bin edasm.bin loader.bin

patch: errormessage.patch garbagecollection.patch
	patch -p3 <errormessage.patch
	patch -p3 <garbagecollection.patch

unpatch: errormessage.patch garbagecollection.patch
	patch -R -p3 <errormessage.patch
	patch -R -p3 <garbagecollection.patch
	$(RM) -f msbasic/*.orig

osirom.lod: osirom.bin
	./bintolod -s F800 -l FFF0 osirom.bin >osirom.lod

basicrom.lod: basicrom.bin
	./bintolod -s A000 -l A000 basicrom.bin >basicrom.lod

cegmon.lod: cegmon.bin
	./bintolod -s F800 -l F800 cegmon.bin >cegmon.lod

osirom.bin: fill.o diskboot.o keyboard.o osi65v.o coldstart.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m osirom.map -o osirom.bin fill.o diskboot.o keyboard.o osi65v.o coldstart.o

fill.o:	fill.s
	ca65 -g -l fill.lst --feature labels_without_colons --feature pc_assignment fill.s

diskboot.o: diskboot.s
	ca65 -g -l diskboot.lst --feature labels_without_colons --feature pc_assignment diskboot.s

keyboard.o: keyboard.s
	ca65 -g -l keyboard.lst --feature labels_without_colons --feature pc_assignment keyboard.s

osi65v.o: osi65v.s
	ca65 -g -l osi65v.lst --feature labels_without_colons --feature pc_assignment osi65v.s

coldstart.o: coldstart.s
	ca65 -g -l coldstart.lst --feature labels_without_colons --feature pc_assignment coldstart.s

osibasic.o: osibasic.s
	ca65 -g -l osibasic.lst --feature labels_without_colons --feature pc_assignment osibasic.s

cegmon.o: cegmon.s
	ca65 -g -l cegmon.lst --feature labels_without_colons --feature pc_assignment cegmon.s

osibasic.bin: osibasic.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m osirom.map -o osibasic.bin osibasic.o

cegmon.bin: cegmon.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m cegmon.map -o cegmon.bin cegmon.o

basicrom.bin: basic.bin osibasic.bin
	cat basic.bin osibasic.bin >basicrom.bin

basic.bin:
	cd msbasic ; ./make.sh
	cp msbasic/tmp/osi.bin basic.bin

os65dv32.bin: os65dv32.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -o os65dv32.bin os65dv32.o

os65dv32.o: os65dv32.s
	ca65 --feature labels_without_colons -g -l os65dv32.lst os65dv32.s

os65dv33.bin: os65dv33.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -o os65dv33.bin os65dv33.o

os65dv33.o: os65dv33.s
	ca65 --feature labels_without_colons -g -l os65dv33.lst os65dv33.s

basic32.bin: basic32.asm
	a65 -L -B basic32.asm

basic33.bin: basic33.asm
	a65 -L -B basic33.asm

compare.bin: compare.asm
	a65 -L -B compare.asm

copier32.bin: copier32.asm
	a65 -L -B copier32.asm

copier33.bin: copier33.asm
	a65 -L -B copier33.asm

os65d32.bin: os65d32.asm
	a65 -L -B os65d32.asm

os65d33.bin: os65d33.asm
	a65 -L -B os65d33.asm

exmon.bin: exmon.asm
	a65 -B -O -L -G0800 exmon.asm

edasm.bin: edasm.asm
	a65 -B -O -L -G1300 edasm.asm

loader.bin: loader.s
	a65 -B -O -L loader.s

clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.lod
	$(RM) -rf msbasic/tmp msbasic/msbasic.lst

distclean: clean
