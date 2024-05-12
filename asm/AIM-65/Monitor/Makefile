.PHONY := all

BINDIR := ./bin
OBJDIR := ./obj
TARGET := $(BINDIR)/aim65monitor.bin

all:	aim65monitor.ptp aim65monitor.pdf

aim65monitor.ptp: aim65monitor.bin
	srec_cat aim65monitor.bin -binary -offset 0xE000 -o aim65monitor.ptp -MOS_Technologies

# EPROMs binary image ()
aim65monitor.bin: aim65monitor.o aim65monitor.cfg
	ld65 \
	  --config aim65monitor.cfg \
	  -vm \
	  --mapfile aim65monitor.map \
	  -o aim65monitor.bin \
	  aim65monitor.o

# Main program
aim65monitor.o: aim65monitor.s aim65monitor.cfg Makefile
	ca65 \
	  --debug-info \
	  --listing aim65monitor.lst \
	  aim65monitor.s

# Generate listing in "old" fanfold style
aim65monitor.pdf: aim65monitor.o
	enscript \
	  --landscape \
	  --media=A4 \
	  --highlight-bars=1 \
	  --highlight-bar-gray=.85 \
	  --title='Rockwell AIM-65 Monitor Listing' \
	  --header='Rockwell AIM-65 Monitor Listing|%D{%F}|Page $$% of $$=' \
	  --output=- \
	  aim65monitor.lst | ps2pdf - aim65monitor.pdf

# Compare generated code with original EPROM
test: aim65monitor.bin
	# ROM in socket Z23 ($E000):
	$(eval MON_ROM_E_URL=http://retro.hansotten.nl/uploads/aim65/R3223-11.BIN)
	# ROM in socket Z22 ($D000):
	$(eval MON_ROM_F_URL=http://retro.hansotten.nl/uploads/aim65/R3222.BIN)
	$(eval ROM_DIR:=$(shell mktemp --directory))
	# Original Monitor ROM image:
	$(eval MON_ROM_O=AIMMON.BIN)
	wget --output-document=$(ROM_DIR)/$(MON_ROM_O) $(MON_ROM_E_URL) $(MON_ROM_F_URL)
	cmp -l -b aim65monitor.bin $(ROM_DIR)/$(MON_ROM_O)
	rm $(ROM_DIR)/$(MON_ROM_O)
	rmdir $(ROM_DIR)

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp *.pdf

distclean: clean
