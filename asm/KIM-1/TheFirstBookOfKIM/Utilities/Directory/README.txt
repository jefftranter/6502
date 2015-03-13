DIRECTORY
Jim Butterfield

     Ever thought about the best way to organize your programs on tape?
I used to call the first program on each tape number 01, the next 02, etc.
Mostly I was afraid of forgetting the ID number and having trouble reading
it in.  Program DIRECTORY (below) fixes up that part of the problem and
liberates you to choose a better numbering scheme.

     You've got 254 program IDs to choose from ... enough for most program
libraries with some to spare.

     So every program and data file would carry a unique number ... and if
you've forgotten what's on a given tape, just run DIRECTORY and get all the
IDs.

     Another thing that's handy to know is the starting address (SA) of a
program, especially if you want to copy it to another tape.  (Ending add-
resses are easy ... just load the program, then look at the contents of
17ED and 17EE).  Well, DIRECTORY shows starting addresses, too.

     The program is fully relocatable, so put it anywhere convenient.
Start at the first instruction (0000 in the listing).  Incidentally, 0001
to 001D of this program are functionally identical to the KIM monitor 188C
to 18C1.

     After you start the program, start your audio tape input.  When DI-
RECTORY finds a program, it will display the Start Address (first four
digits) and the Program ID.  Hit any key and it will scan for the next
program.
