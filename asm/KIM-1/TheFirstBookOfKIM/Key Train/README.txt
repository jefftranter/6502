KEY TRAIN
BY JIM BUTTERFIELD

Ever wish you could touch-type your KIM keypad like some people
can type?  It's not hard; all you need is practice.  And what
better teacher to drill you on key entry than the KIM system 
itself?

Load this fully relocatable program anywhere.  Start it up, and
the display will show a random hexadecimal digit, from 0 to F.
Hit the corresponding key, and the display will blank, and then
present you with another random digit.  Hit the wrong key and
nothing will happen.

The educational principle involved is called positive reinforcement.
That is, you're rewarded for doing the right thing, and ignored if
you do it wrong.  A few minutes of practice a day. and you'll become
a speed demon on the keyboard!

                               --------

The random number used in this program is taken from the KIM timer.
This timer runs continuously and might be anywhere between 00 and FF
at the instant we push the button.  We use the four left hand (high order)
bits of the timer to produce the next digit.

Be sure that KIM is not in decimal mode when you run this program -
set address 00F1 to 00 before starting.  If you forget, you might
find that the alphabetic keys (A to F) don't work right.

Exercises:  can you make the program clear decimal mode automatically?
How about a counter to record the number of correct keystrokes you
have made?  That way, you could time yourself to see how many keys
you can get right in 60 seconds.  The count could be shown in the
two right hand digits of the display.  Do you think it should be
in decimal or hexadecimal?
