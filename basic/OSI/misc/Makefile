all: sound.lod wave.lod

sound.lod: sound.s
	a65 -L -O sound.s
	a65 -L -B sound.s

wave.lod: wave.s
	a65 -L -O wave.s
	a65 -L -B wave.s

clean:
	$(RM) *.lst *.lod *.bin
