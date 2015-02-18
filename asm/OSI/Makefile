all: osirom.lod basicrom.lod cegmon.lod

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
	ld65 -t none -vm -m osirom.map -o osirom.bin fill.o diskboot.o keyboard.o osi65v.o coldstart.o

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
	ld65 -t none -vm -m osirom.map -o osibasic.bin osibasic.o

cegmon.bin: cegmon.o
	ld65 -t none -vm -m cegmon.map -o cegmon.bin cegmon.o

basicrom.bin: basic.bin osibasic.bin
	cat basic.bin osibasic.bin >basicrom.bin

basic.bin:
	cd msbasic ; ./make.sh
	cp msbasic/tmp/osi.bin basic.bin

clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.lod
	$(RM) -rf msbasic/tmp

distclean: clean
