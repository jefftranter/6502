all:	osi65v.lod boot.lod keyboard.lod

osi65v.lod: osi65v.bin
	./bintolod osi65v.bin >osi65v.lod

boot.lod: boot.bin
	./bintolod boot.bin >boot.lod

keyboard.lod: keyboard.bin
	./bintolod keyboard.bin >keyboard.lod

osi65v.bin: osi65v.o
	ld65 -t none -vm -m osi65v.map -o osi65v.bin osi65v.o

boot.bin: boot.o
	ld65 -t none -vm -m boot.map -o boot.bin boot.o

keyboard.bin: keyboard.o
	ld65 -t none -vm -m keyboard.map -o keyboard.bin keyboard.o

osi65v.o: osi65v.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment osi65v.s

boot.o:	boot.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments boot.s 

keyboard.o:	keyboard.s
	ca65 -g -l --feature labels_without_colons --feature pc_assignment --feature c_comments keyboard.s 

clean:
	$(RM) *.o *.lst *.mon *.map *.bin *.lod

distclean: clean
