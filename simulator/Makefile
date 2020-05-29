# Compiler
CXX = g++

# Flags for debug
CXXFLAGS = -Wall -g

#Flags for optimized code
#CXXFLAGS = -Wall -O

all:	sim6502

sim6502: sim6502.o main.o
	$(CXX) $(CXXFLAGS) -o sim6502 sim6502.o main.o

sim6502.o: sim6502.cpp sim6502.h
	$(CXX) $(CXXFLAGS) -c sim6502.cpp

main.o: sim6502.h main.cpp
	$(CXX) $(CXXFLAGS) -c main.cpp

clean:
	$(RM) sim6502.o main.o sim6502
	$(RM) *.o *.lst *.map *.bin

distclean: clean
