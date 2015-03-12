TEASER
By Lew Edwards

     Description -
        This program is an adaptation of the "Shooting Stars" 
     game utilizing the keyboard and display of the KIM-1.
     originally published in the Sept. '74 issue of PCC, a
     version also appeared in the May '76 issue of Byte magazine.
         The starfield is displayed on the horizontal segments
     of the second through fourth digits of the display. The
     segments represent stars when lit and are numbered as follows
     Shooting a star creates a hole where the star     7 8 9
     was. The resulting "explosion" changes the        4 5 6
     condition of certain adjacent stars or holes,     1 2 3
     (stars to holes, or holes to stars) according to the following:

                  ^                                  ^
     Center (5) <-+-> , Sides (2,8)  <-+->  or (4,6) +
                  v                                  v

     Corners (1) |/ ,  (3)  \| , (7) -- , (9) _  
                 --         --       |\       /|

        The game starts with a star in position 5; the rest
     are holes. The object of the game is to reverse the initial
     condition, making 5 a hole and all the rest stars. Eleven
     moves are the minimum number.
        Should you attempt to "shoot" a hole, the first digit
     displays a "H" until a star key is pressed. This digit
     also displays a valid number selection. A count of valid
     moves is given at the right of the display. A win gives
     a "F" in the first digit. All holes is a losing situation,
     ("L" in the first digit). You may start over at any time
     by pressing the "Go" button. The program starts at 0200.
