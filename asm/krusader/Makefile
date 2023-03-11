krusader.run: krusader.bin
	srec_cat krusader.bin -binary -o krusader.run

krusader.bin: krusader.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -m krusader.map krusader.o -o krusader.bin

krusader.o: krusader.s
	ca65 krusader.s -o krusader.o -l krusader.lst

clean:
	$(RM) krusader.lst krusader.map krusader.run krusader.bin krusader.o
