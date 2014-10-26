all: osirom.lod basicrom.lod

osirom.lod: osirom.bin
	./bintolod -s F800 -l FFF0 osirom.bin >osirom.lod

basicrom.lod: basicrom.bin
	./bintolod -s A000 -l A000 basicrom.bin >basicrom.lod

osirom.bin: fill.o diskboot.o keyboard.o osi65v.o coldstart.o
	ld65 -t none -vm -m osirom.map -o osirom.bin fill.o diskboot.o keyboard.o osi65v.o coldstart.o

fill.o:	fill.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments fill.s

diskboot.o: diskboot.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments diskboot.s

keyboard.o: keyboard.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments keyboard.s

osi65v.o: osi65v.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments osi65v.s

coldstart.o: coldstart.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments coldstart.s

osibasic.o: osibasic.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments osibasic.s

osibasic.bin: osibasic.o
	ld65 -t none -vm -m osirom.map -o osibasic.bin osibasic.o

basicrom.bin: basic.bin osibasic.bin
	cat basic.bin osibasic.bin >basicrom.bin

basic.bin:
	cd msbasic ; ./make.sh
	cp msbasic/tmp/osi.bin basic.bin

clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.lod
	$(RM) -rf msbasic/tmp

distclean: clean
