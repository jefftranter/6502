.PHONY := all

BINDIR := ./bin
OBJDIR := ./obj
TARGET := $(BINDIR)/aim65monitor.bin

all:	aim65monitor.ptp aim65monitor.pdf

aim65monitor.ptp: aim65monitor.bin
	srec_cat aim65monitor.bin -binary -offset 0xE000 -o aim65monitor.ptp -MOS_Technologies

aim65monitor.bin: aim65monitor.o
	ld65 --config aim65monitor.cfg -vm --mapfile aim65monitor.map -o aim65monitor.bin aim65monitor.o

aim65monitor.o: aim65monitor.s aim65monitor.cfg Makefile
	ca65 --debug-info --listing aim65monitor.lst aim65monitor.s

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

clean:
	$(RM) *.o *.lst *.map *.bin *.ptp *.pdf

distclean: clean
