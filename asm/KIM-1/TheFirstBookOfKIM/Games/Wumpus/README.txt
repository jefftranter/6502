WUMPUS
By Stan Ockers

Description -
     Wumpus lives in a cave of 16 rooms, (labeled 0-F).
Each room has four tunnels leading to other rooms, (see
the figure)   When the program is started at 0305, you and
Wumpus are placed at random in the rooms. Also placed
at random are two bottomless pits (they don't bother Wumpus,
he has sucker-type feet) and two rooms with Superbats,
(also no trouble to Wumpus, He's too heavy). If you enter
a bat's room you are picked up and flown at random to
another room.  You will be warned when bats, pits or Wumpus
are nearby   If you enter the room with Wumpus, he wakes
and either moves to an adjacent room or just eats you up
(YOU lose)  In order to capture Wumpus, you have three
cans of "mood change" gas. When thrown into a room
containing Wumpus, the gas causes him to turn from a vicious
snarling beast into a meek and loveable creature. He will
even come out and give you a hug. Beware though, once you
toss a can of gas in the room, it is contaminated and you
cannot enter or the gas will turn you into a beast (you lose).
   If you lose and want everything to stay the same for
another try, start at 0316. The byte at 0229 controls the
speed of the display. Once you get use to the characters,
you can speed things up by putting in a lower number. The
message normally given tells you what room you are in and
what the choices are for the next room. In order to fire
the mood gas, press PC (pitch can?), when the rooms to be
selected are displayed. Then indicate the room into which
you want to pitch the can. It takes a fresh can to get
Wumpus (he may move into a room already gassed) and he will
hear you and change rooms whenever a can is tossed (unless
you get him). Good hunting!
   The program is adapted from a game by Gregory Yob
which appears in The Best of Creative Computing.

Corrections:

If Wumpus moves to a room containing a pit or superbats, he will be
hidden and you won't be told when you are near him. You must either
guess his location or make him move again by pitching a can.
