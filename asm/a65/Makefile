a65: a65.c a65.h
	gcc -Wall -O -o a65 a65.c

test: a65 test.asm
	./a65 test.asm
clean:
	$(RM) a65 *.lst

install: a65
	sudo cp a65 /usr/local/bin
