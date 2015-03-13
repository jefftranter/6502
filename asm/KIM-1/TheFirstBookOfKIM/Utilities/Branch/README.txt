BRANCH
BY JIM BUTTERFIELD

Load this fully relocatable program anywhere.
Once it starts, key in the last two digits of
a branch instruction address; then the last two
digits of the address to which you are branching;
and read off the relative branch address.

For example, to calculate the branch to ADDR near the
end of this program:  hit 26 (from 0026); 20 (from 0020)
and read F8 on the two right hand digits of the display.
The program must be stopped with the RS key.

Keep in mind that the maximum "reach" of a branch instruction
is 127 locations forward (7F) or 128 locations backward (80).
If you want a forward branch, check that the calculated branch
is in the range 01 to 7F. Similarly, be sure that a backward
branch produces a value from 80 to FE. In either case, a value
outside these limits means that your desired branch is out of
reach.
