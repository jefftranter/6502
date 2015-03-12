SUBDIRS = Addition Asteroid Bagels Bandit Bitz "Black Match" Blackjack "Card Dealer" "Chess Clock" Clock "Code Test" Craps Duel "Farmer Brown" Hi-Lo Horserace "Key Train" "Kim Nim" Kim-Tac-Toe "Lunar Lander" Multi-Maze "Music Box" "Ping Pong" Quick Reverse Teaser Timer Wumpus

all:
	@for i in $(SUBDIRS); do \
	echo "make all in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) all); done

clean:
	@for i in $(SUBDIRS); do \
	echo "Clearing in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
