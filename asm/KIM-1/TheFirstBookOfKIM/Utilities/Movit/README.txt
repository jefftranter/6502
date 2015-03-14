MOVIT
By Lew Edwards

ANOTHER move program?  This one moves anything anywhere!
No limit to number of bytes, or locations in memory, or
overlapping of source and destination. Use it to lift sections
of code from other programs, close in or open up gaps for
altering programs, moving programs to another location (use
Butterfield's RELOCATE to take care of the branch and address
correction). Locate it wherever you have the room.

Use is straight forward. Old start address goes in D0,1 ;
old end address in D2,3; new start address in D4,D5 before
running the program which starts at 1780, or wherever you
want to have it in your system. Program uses zero page
locations D0 thru P9 to do the job.

P.S. Don't forget to set the IRQ vector for the break
(KIM - 1C00 at 17FE,FF)

Addition: The last address filled can be displayed after the
program is complete by adding the following code:
(1) 85 FA between instructions now at 1795 and 1797
(2) 85 FB between instructions now at 179B and 179D
(3) replace the break at the end with 4C 4F 1C
Use Movit to move itself to another location and then again
to open up the necessary spaces!
