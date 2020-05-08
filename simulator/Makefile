sim6502: sim6502.o main.o
	g++ -o sim6502 sim6502.o main.o

sim6502.o: sim6502.cpp sim6502.h
	g++ -Wall -g -c sim6502.cpp

main.o: sim6502.h main.cpp
	g++ -Wall -g -c main.cpp

clean:
	$(RM) sim6502.o main.o sim6502

distclean: clean
