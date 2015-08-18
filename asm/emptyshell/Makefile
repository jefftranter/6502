all: emptyshell.o

emptyshell.o:	emptyshell.s
	ca65 -g -l emptyshell.lst emptyshell.s

clean:
	$(RM) *.o *.lst *.map

