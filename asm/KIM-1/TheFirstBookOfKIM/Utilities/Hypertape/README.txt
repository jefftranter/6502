HYPERTAPE
Jim Butterfield

How long does it take you to load a full 1K of KIM-1 
memory?  Over two minutes?  And if you're going for 
memory expansion, how long will it take you to load 
your 8K? Twenty minutes?

Hold onto your hats. Program HYPERTAPE! will write 
fully compatible tapes in a fraction of the time. 
You can load a full 1K in 21 seconds.

Fully compatible means this: once you've written 
a tape using HYPERTAPE! you can read it back in using 
the normal KIM-1 program (starting at 1873 as usual). 
And the utilities and diagnostic programs work on this
super-compressed data (e.g., DIRECTORY and VUTAPE).

You'll need some memory space for the program, of course. 
If you have memory expansion, there'll be no problem 
finding space, of course.  But if you're on the basic 
KIM-1, as I am, you'll have to "squeeze in" HYPERTAPE! 
along with the programs you're dumping to tape.  I try 
to leave page 1 alone usually (the stack can overwrite 
your program due to bugs), so I stage HYPERTAPE! in 
that area.  For the convenience of relocation, the 
listing underlines those addresses that will need
changing. There are also four values needed in page zero which 
you may change to any convenient location.

For those Interested in the theory of the thing, I 
should mention: HYPERTAPE! is not the limit.  If you 
wished to abandon KIM-1 monitor compatibility, you 
could continue to speed up tape by a factor of 4 or 5
times more.  Can you imagine reading 1K in four seconds? 
For the moment, however, HYPERTAPE! is plenty fast for me.

Thanks go to Julien Dubé for his help in staging early 
versions off HYPERTAPE.
