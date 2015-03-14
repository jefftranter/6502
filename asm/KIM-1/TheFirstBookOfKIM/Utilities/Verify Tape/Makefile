PROGRAM = verifytape

all: $(PROGRAM).ptp

$(PROGRAM).ptp: $(PROGRAM).bin Makefile
	srec_cat $(PROGRAM).bin -binary -offset 0x17EC -o $(PROGRAM).ptp -MOS_Technologies

$(PROGRAM).bin: $(PROGRAM).o
	ld65 -t none -vm -m $(PROGRAM).map -o $(PROGRAM).bin $(PROGRAM).o

$(PROGRAM).o:	$(PROGRAM).s
	ca65 -g -l $(PROGRAM).lst $(PROGRAM).s

clean:
	$(RM) *.o *.lst *.map *.bin

distclean: clean
