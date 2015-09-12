SUBDIRS = \
    2ksa \
    6522via \
    6551acia \
    65816 \
    a1basic \
    Apple][DOS \
    Apple][Monitor \
    BeyondGames \
    disasm \
    ehbasic \
    jmon \
    KIM-1 \
    msbasic \
    OSI \
    ProDOS \
    sweet16 \
    tinybasic \
    wozaci \
    wozfp \
    wozmon \

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) all); done

clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
