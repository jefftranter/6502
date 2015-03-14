SUBDIRS = Branch Browse Directory Hypertape "Memory Test" "Mini Dis" Movit "PLL Set" Relocate Sort Super-Dupe "Verify Tape" VU-Tape

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) all); done

clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
