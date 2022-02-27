# Do once to prepare SD card:
# cp /usr/local/share/cc65/target/apple2/drv/*/* .
# cp /usr/local/share/cc65/target/apple2enh/drv/*/* .
# for file in a2.* a2e.* ; do echo $file ; ac.sh -d ${HOME}/Documents/AppleIIc/diskimages/CC65-work.dsk $file ; done
# for file in a2.* a2e.* ; do echo $file ; ac.sh -p ${HOME}/Documents/AppleIIc/diskimages/CC65-work.dsk $file rel 0 < $file ; done

game: game.c
	cl65 -T -l game.lst -m game.map -O -t apple2enh --start-addr 0x4000 -o game game.c -L /usr/local/share/cc65/lib

native: game.c
	gcc -Wall -o game game.c

install: game
	ac.sh -d $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk tutorial
	ac.sh -p $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk tutorial txt 0 <tutorial.txt
	ac.sh -d $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk overview
	ac.sh -p $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk overview txt 0 <overview.txt
	ac.sh -d $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk levels
	ac.sh -p $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk levels txt 0 <levels.csv
	ac.sh -d $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk game
	ac.sh -as $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk game <game

sdcard:
	cp $(HOME)/Documents/AppleIIc/diskimages/CC65-work.dsk /media/tranter/7A45-0090/CC65-work.dsk 

clean:
	$(RM) game game.lst game.map

distclean: clean
