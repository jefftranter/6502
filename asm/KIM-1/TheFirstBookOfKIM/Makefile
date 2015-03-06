SUBDIRS = Addition Asteroid Bagels Bandit Bitz "Black Match" Blackjack "Card Dealer" "Chess Clock" Clock "Code Test" Craps Duel "Farmer Brown" Hi-Lo Horserace "Key Train" "Memory Test"

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) all); done

clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
