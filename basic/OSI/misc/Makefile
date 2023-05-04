all: sound.lod wave.lod swap.lod

sound.lod: sound.s
	a65 -L -O -G0C00 sound.s
	a65 -L -B sound.s

wave.lod: wave.s
	a65 -L -O -G0300 wave.s
	a65 -L -B wave.s

swap.lod: swap.s
	a65 -L -O swap.s
	a65 -L -B swap.s

clean:
	$(RM) *.lst *.lod *.bin
