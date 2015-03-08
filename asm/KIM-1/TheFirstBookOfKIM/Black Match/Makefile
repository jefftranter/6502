PROGRAM1 = blackmatch1
PROGRAM2 = blackmatch2

all: $(PROGRAM1).ptp $(PROGRAM2).ptp

$(PROGRAM1).ptp: $(PROGRAM1).bin Makefile
	srec_cat $(PROGRAM1).bin -binary -offset 0x0200 -o $(PROGRAM1).ptp -MOS_Technologies

$(PROGRAM1).bin: $(PROGRAM1).o
	ld65 -t none -vm -m $(PROGRAM1).map -o $(PROGRAM1).bin $(PROGRAM1).o

$(PROGRAM1).o:	$(PROGRAM1).s
	ca65 -g -l $(PROGRAM1).lst $(PROGRAM1).s

$(PROGRAM2).ptp: $(PROGRAM2).bin Makefile
	srec_cat $(PROGRAM2).bin -binary -offset 0x0200 -o $(PROGRAM2).ptp -MOS_Technologies

$(PROGRAM2).bin: $(PROGRAM2).o
	ld65 -t none -vm -m $(PROGRAM2).map -o $(PROGRAM2).bin $(PROGRAM2).o

$(PROGRAM2).o:	$(PROGRAM2).s
	ca65 -g -l $(PROGRAM2).lst $(PROGRAM2).s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
