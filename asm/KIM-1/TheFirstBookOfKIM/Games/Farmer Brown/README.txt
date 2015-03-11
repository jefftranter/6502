FARMER BROWN
by Jim Butterfield

You are farmer Brown. You are growing a beautiful crop of corn
But the following animals try to come and steal your corn:

Ant     Bird     Cow     Dog     Elephant     Fox

As soon as you see one of these animals coming for your corn,
you can scare it away by calling its name. Press the button
with the first letter of the animal's name. So you would
press A to shoo away an ant, B to shoo away a bird, and so on.

If you press the right button, the animal will go back. If you
press the wrong button, it will think you mean somebody else
and keep coming for your corn. And when all your corn is gone,
KIM will show 000 and the game is over.

The animal won't "shoo" unless it has completely entered the
display. Speed of the animals can be adjusted by changing the
contents of location 026A.

-----------------------------------------------------

FARMER BROWN....

Exercises:

1. You can see that each animal occupies 6 memory locations,
starting at 02AA (the Ant) - and the last location must always
be zero. Can you make up your own animals? The letters may
not fit exactly, but you can always invent names or use
odd ones (you could make an Aardvark, a Burfle, a Cobra, and
so on).

2. The game might be more fun if the animals went faster after
a while, so that sooner or later they would just zip by.
The location that controls speed is at address 026A;
the lower the number, the faster the animals will go.
So if you could arrange to have the program decrease
this number automatically once in a while, you'd get
a nice speed-up feature.

3. You can't "shoo" the animal until it's completely entered
the display; but you can still catch it after it's partly
left. The game would be harder - and maybe more fun -
if you could only shoo it while it was completely in the
display. Hint - testing location 005F (WINDOW-1) would
tell you if an animal was on its way out.

4. You'd have a "Target Practice" game if you made the animal
disappear (instead of backing up) when you pressed the
right button. With a little planning, you'll find that
this is quite easy to do.
