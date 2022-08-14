all: fig6502.lod

fig6502.lod: fig6502.bin
	~/git/6502/asm/OSI/bintolod -s 0380 -l 0380 fig6502.bin >fig6502.lod

send:	fig6502.lod
	ascii-xfr -s fig6502.lod  >/dev/ttyUSB0

fig6502.bin: fig6502.o
	ld65 -C /usr/local/share/cc65/cfg/none.cfg -vm -m fig6502.map -o fig6502.bin fig6502.o

fig6502.o: fig6502.asm
	ca65 -g -l fig6502.lst fig6502.asm

clean:
	$(RM) fig6502.o fig6502.lst fig6502.map fig6502.bin fig6502.lod

distclean: clean
	$(RM) fig6502.lod
