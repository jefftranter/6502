# Disassemble Rockwell AIM-65 assembler ROM image

assembler.s: aim65.bin labels.sym datablocks.dxa routines.dxa Makefile
	dxa -a enabled -R routines.dxa -B datablocks.dxa -l labels.sym -g D000 -O -N aim65.bin > assembler.s

# Merge assembler (D000-DFFF) and monitor (E000-FFFF) ROM images in a single binary image starting at D000
# Required to solve monitor calls
aim65.bin: aim65.bin
	# Assembler ROM in socket Z24 ($D000):
	$(eval ASM_ROM_D_URL=http://retro.hansotten.nl/uploads/aim65/R3224.BIN)
	# Monitor ROM in socket Z23 ($E000), 1st part:
	$(eval MON_ROM_E_URL=http://retro.hansotten.nl/uploads/aim65/R3223-11.BIN)
	# Monitor ROM in socket Z22 ($F000), 2nd part:
	$(eval MON_ROM_F_URL=http://retro.hansotten.nl/uploads/aim65/R3222.BIN)
	wget --output-document=aim65.bin $(ASM_ROM_D_URL) $(MON_ROM_E_URL) $(MON_ROM_F_URL)

# Merge assembler and monitor symbols in a single symbols file
labels.sym: assembler-dxa.sym aimmon.sym
	cat assembler-dxa.sym aimmon.sym > labels.sym

clean:
	rm assembler.s labels.sym aim65.bin
