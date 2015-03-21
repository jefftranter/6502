VU-TAPE
Jim Butterfield

     Program VUTAPE lets you actually see the contents of a KIM format
tape as it's going by.  It shows the data going by very quickly, because
of the tape speed..but you can at least "sense" the kind of material on
the tape.

     In case of tape troubles, this should give you a hint as to the area
of your problem: nothing? noise? dropouts? And you can prepare a test
tape (see below) to check out the tape quality and your recorder.  The
test tape will also help you establish the best settings for your volume
and tone controls.

     Perhaps VUTAPE's most useful function, though, is to give you a
"feeling" for how data is stored on tape.  You can actually watch the
processor trying to synchronize into the bit stream.  Once it's synched,
you'll see the characters rolling off the tape...until an END or illegal
character drops you back into the sync mode again.  It's educational to
watch.  And since the program is fairly short, you should be able to trace
out just how the processor tracks the input tape.

     VUTAPE starts at location 0000 and is fully relocatable (so you can
load it anyplace it fits).

Checking Out Tapes/Recorders
----------------------------

     Make a test tape containing an endless stream of SYNC characters
with the following program:

0050   A0  BF       GO     LDY #$BF           directional..
0052   8C  45  17          STY PBOD           ...registers
0055   A9  16       LP     LDA #$16           SYNC
0057   20  7A  19          JST OUTCH          ...out to tape
005A   D0  F9              BNE LP

     Now use the program VUTAPE.  The display should show a steady
synchronization pattern consisting of segments b,c, and e on the right
hand LED,  Try playing with your controls and see over what range the
pattern stays locked in.  The wider the range, the better your cassette/
recorder.
