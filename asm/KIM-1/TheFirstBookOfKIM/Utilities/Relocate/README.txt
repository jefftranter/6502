RELOCATE
Jim Butterfield

     Ever long for an assembler?  Remember when you wrote that 300 byte
program - and discovered that you'd forgotten one vital instruction in the
middle?  And to make room, you'd have to change all those branches, all
those address...  Or the program with that neat piece of coding in it, that
you suddenly need to remove (say, to change it to a subroutine)...but if
you do, you'll have to fill all that empty space with NOPs?  It's enough
to make a grown programmer cry...

     Dry those tears.  Program RELOCATE will fix up all those addresses
and branches for you, whether you're opening out a program to fit in an
extra instruction, closing up space you don't need, or just moving the whole
thing someplace else.

     RELOCATE doesn't move the data.  It just fixes up the addresses before
you make the move.  It won't touch zero page addresses; you'll want them
to stay the same.  And be careful: it won't warn you if a branch instruc-
tion goes out of range.

     You'll have to give RELOCATE a lot of information about your program:

       (1)  Where your program starts.  This is the first instruction in
            your whole program (including the part that doesn't move).
            RELOCATE has to look through your whole program, instruction
            by instruction, correcting addresses and branches where neces-
            sary.  Be sure your program is a continuous series of instruc-
            tions (don't mix data in; RELOCATE will take a data value of
            10 as a BEL instruction and try to correct the branch address),
            and place a dud instruction (FF) behind your last program in-
            struction.  This tells RELOCATE where to stop.

            Place the program start address in locations EA and EB, low
            order first as usual.  Don't forget the FF behind the last
            instruction; it doesn't matter if you temporarily wipe out a
            byte of data - you can always put it back later.

       (2)  Where relocation starts, this is the first address in your
            program that you want to move.  If you're moving the whole
            program, it will be the same as the program start address,
            above.  This address is called the boundary.

            Place the boundary address in locations EC and ED, low order
            first.

       (3)  How far you will want to relocate information above the bound-
            ary.  This value is called the increment. For example, if you
            want to open up three more locations in your program, the in-
            crement will be 0003.  If you want to close up four addresses,
            the increment will be FFFC (effectively, a negative number).

            Place the increment value in locations E8 and E9, low order
            first.

       (4)  A page limit, above which relocation should be disabled.  For
            example, if you're working on a program in the 0200 to 03FF
            range, your program might also address a timer or I/O regist-
            ers, and might call subroutines in the monitor.  You don't
            want these addresses relocated, even though they are above the
            boundary!  So your page limit would be 17, since these addresses
            are all over l700.

            On the other hand, if you have memory expansion and your program
            is at address 2000 and up, your page limit will need to be much
            higher.  You'd normally set the page limit to FF, the highest
            page in memory.

            Place the page limit in location E7.

           Now you're ready to go.  Set RELOCATE's start address, hit go - and
      ZAP!-your addresses are fixed up.

           After the run, it's a good idea to check the address now in 00EA and
      00EB - it should point at the FF at the end of your program, confirming
      that the run went OK.

           Now you can move the program.  If you have lots of memory to spare,
      you can write a general MOVE program and link it in to RELOCATE, so as to
      do the whole job in one shot.

           But if, like me, you're memory-deprived, you'll likely want to run
      RELOCATE first, and then load in a little custom-written program to do
      the actual moving. The program will vary depending on which way you want
      to move, how far, and how much memory is to be moved.  In a pinch, you can
      use the FF option of the cassette input program to move your program.

           Last note: the program terminates with a BRK instruction.  Be sure
      your interrupt vector (at l7FE and 17FF) is set to KIM address 1C00 so
      that you get a valid "halt".


     Credit for the concept of RELOCATE goes to Stan Ockers, who insisted
that it was badly needed, and maintained despite my misgivings that it
should be quite straightforward to program. He was right on both counts.

---

USING PROGRAM RELOCATE - an example.        Jim Butterfield

Program RELOCATE is important, and powerful.  But it takes
a little getting used to.  Let's run through an example.
Follow along on your KIM, if you like.

Suppose we'd like to change program LUNAR LANDER.
When you run out of fuel on the lander, you get no
special indication, except that you start falling
very quickly.  Let's say we want to make this minor
change:  if you run out of fuel, the display flips
over to Fuel mode, so that the pilot will see immediately.

Digging through the program reveals two things:  (i) you
go to fuel mode by storing 00 into MODE (address E1);
and, (ii) the out-of-fuel part of the program is located
at 024C to 0257.  So if we can insert a program to store
zero in mode as part of our out-of-fuel, we should have
accomplished our goal.  Closer inspection reveals that
we can accomplish this by inserting 85 E1 (STA MODE)
right behind the LDA instruction at 024C.

Let's do it.

First, we must store value FF behind the last instruction
of our program.  So put FF into address 02CC.  That wipes
out the value 45, but we'll put it back later.

Now, we put out program start address (0200) into addresses
EA and EB.  Low order first, so 00 goes into address 00EA
and 02 goes into 00EB.

Next, the part that we want to move.  Since we want to
insert a new instruction at address 024E, we must move
the program up at this point to make space.  In goes
the address, low order first:  4E into address 00EC and
02 into address 00ED.

The page limit should be set to 17, since we don't want
the addresses of the KIM subroutines to be changed
(SCANDS, GETKEY, etc.).  So put 17 into address 00E7.

Finally, how far do we want to move the program to make
room?  Two bytes, of course.  Put 02 and 00 into
addresses 00E8 and 00E9 respectively.

We're ready to go.  Be sure your vectors have been set
properly (at addresses 17FA to 17FF).  Then set address
0110, the start address of RELOCATE, and press GO.

The display will stop showing 0114 EA, confirming that
RELOCATE ran properly.  Now check to see the whole program
was properly converted by looking at the addresses 00EA-B.
We put address 0200 there, remember?  Now we'll see
address 0200 stored there - the address of the value FF
we stored to signal end of program.

Go back to 02CC, where we stored FF, and restore the
original value of 45.

We've completed part I.  The addresses have been corrected
for the move.  Let's go on to part II and actually move
the program to make room.

My favorite method is to use a tiny program to do the
move itself.  For moving 1 to 256 bytes to a higher address,
I use the program:  A2 nn BD xx xx 9D tt tt CA D0 F7 00.

In the above, nn is the number of bytes to be moved, and
xxxx and tttt are the from and to addresses of the data,
minus one.  Since we want to move about 160 bytes from
a block starting at 024E to a block starting at 0250,
we code like this:  A2 AC BD 4D 02 9D 4F 02 CA D0 F7 00.

This little program can be fitted in anywhere.  Let's
put it in memory starting at address 0040.  The final
byte, value 00, should end up in 004B.  Now back to
0040, hit GO ... and your data/program is moved over.
(The tiny program should stop showing address 004D).

There's nothing left to do but actually put the extra
instruction (85 E1) into the program at 024E and 024F.

Now run the program.  Try deliberately running out of
fuel and see if the display flips over to fuel mode
automatically when you run out.

If you have followed the above successfully with your
KIM, it all seems very easy.  It's hard to realize that
program RELOCATE has done so much work.  But if you
check, you'll find the following addresses have been
automatically changed:

   0203   024B   0256/8   0263/5   0265/7   02A5/7

Do you think that you'd have caught every one of
those addresses if you'd tried to do the job manually?
