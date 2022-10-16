The Abandoned Farmhouse Adventure is a text adventure game in the
spirit of similar games that ran on 8-bit microcomputers of the 1970s
and 80s or the more ambitious Colossal Cave adventure that originally
only ran on mainframes and minicomputers.

The plot and game should be self-explanatory. Figuring it out is the
point of the game.

I started writing it in BASIC but some things were very awkward to do
efficiently in Apple 1 BASIC. I also considered writing it in assembly
language, but ended up writing it in C because the excellent CC65
assembler worked very well for me.

It was written to run on the Apple Replica 1 although it is in
portable C and should run on any system with a C compiler (I did most
of the development and testing on a Linux system).

Because it was intended to run on the Replica 1 it was kept small and
efficient to run within the 32K memory limit and only use uppercase
characters and fit on a 40x24 character screen. Some code looks a
little unusual because it makes some optimizations for size and speed,
e.g. chars instead of ints, pre versus post increment/decrement. It is
a little too big to fit in an 8K EEPROM. It also won't run on an
original Apple 1 with 4K of memory but I am willing to port it if
someone sends me a system :-)

The source is included and under an Apache license so you can modify
and adapt the code if you wish. Much of the code is data-driven and
could be used to implement an entirely different adventure just by
changing the map, strings, and some of the logic that handles special
actions.

Oh and by the way, the farm described here is based on a real
farmhouse where my father lived many years ago, right down to the
layout of most of the rooms. And I also have grandson who was
almost 3 years old at the time I wrote this.

Jeff Tranter <tranter@pobox.com>
http://jefftranter.blogspot.ca/
