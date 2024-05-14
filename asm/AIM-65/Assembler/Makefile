.PHONY := all

BINDIR := ./bin
OBJDIR := ./obj
TARGET := $(BINDIR)/aim65assembler.bin

all:	aim65assembler.ptp aim65assembler.pdf

aim65assembler.ptp: aim65assembler.bin
	srec_cat aim65assembler.bin -binary -offset 0xD000 -o aim65assembler.ptp -MOS_Technologies

aim65assembler.bin: aim65assembler.o
	ld65 --config aim65assembler.cfg -vm --mapfile aim65assembler.map -o aim65assembler.bin aim65assembler.o

aim65assembler.o: aim65assembler.s aim65assembler.cfg aim65monitor.inc Makefile
	ca65 --debug-info --listing aim65assembler.lst aim65assembler.s

aim65assembler.pdf: aim65assembler.o
	enscript \
	  --landscape \
	  --media=A4 \
	  --highlight-bars=1 \
	  --highlight-bar-gray=.85 \
	  --title='Rockwell AIM-65 Assembler Listing' \
	  --header='Rockwell AIM-65 Assembler Listing|%D{%F}|Page $$% of $$=' \
	  --output=- \
	  aim65assembler.lst | ps2pdf - aim65assembler.pdf

# Verify generated rom comparing byte-for-byte with original dump
test: aim65assembler.bin
	$(eval ASM_ROM_URL=http://retro.hansotten.nl/uploads/aim65/R3224.BIN)
	$(eval ROM_DIR:=$(shell mktemp --directory))
	@echo ROM_DIR IS $(ROM_DIR)
	@echo ASM_ROM_URL IS $(ASM_ROM_URL)
	wget --directory-prefix=$(ROM_DIR) $(ASM_ROM_URL)
	cmp -l -b aim65assembler.bin $(ROM_DIR)/R3224.BIN
	rm $(ROM_DIR)/R3224.BIN
	rmdir $(ROM_DIR)

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp *.pdf

distclean: clean
