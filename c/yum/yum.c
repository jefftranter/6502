/*
 * 
 * YUM
 *
 * Jeff Tranter <tranter@pobox.com>
 *
 * Written in standard C but designed to run on the Apple Replica 1
 * using the CC65 6502 assembler.
 *
 * Copyright 2012 Jeff Tranter
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Revision History:
 *
 * Version  Date         Comments
 * -------  ----         --------
 * 0.0      25 Jul 2012  Started coding
 *
 */

//#include <ctype.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
//#include <string.h> 

/*

YUM - a variation of the game Yahtzee

Up to 3 players (compile time, limited by screen size).
Players can be the computer.
Compile time option for all uppercase output or not.

------------------------------------------------------------------------

Sample session:

Welcome to Yahtzee!

Do you want instructions (Y/N) ? N
How many human players? (0-3) 2
How many computer players? (0-1) 1
Name of player 1: Jeff
Name of player 2: Veronica
Player three will be "Apple 1".
Press <Enter> to start

Current Score after 6 of 12 turns:

Roll            Jeff  Veronica Apple 1
1's               5      3       4
2's               -      -       6
3's               -      6       -
4's               -      -      12
5's              15     25      20
6's               6      -       -
Sub-total        26     34      42
Bonus             -      -       -
Low Straight     15     15       -
High Straight     -      2      20
Low Score        17     12      11
High Score       22     26      24
Full House        -     25       -
YUM               -     30      30
TOTAL           114    178     169

Jeff's turn. Press <Enter> to roll 

Jeff, One your first roll you have:
1 2 3 3 6
What numbers do you want to keep? 336

Rolling again...
Jeff, One your second roll you have:
1 3 3 6 6
What numbers do you want to keep? 3366

Rolling again...
Jeff, One your final roll you have:
3 3 3 6 6

1 - 1's (0/5)
2 - 2's (0/10)
3 - 3's (9/15)
4 - 4's (0/20)
5 - 5's (0/25)
6 - 6's (12/30)
7 - Low Straight (0/15)
8 - High Straight (0/20)
9 - Low Score (25)
10 - High Score (25)
11 - Full House (25/25)
12 - YUM (0/30)

Jeff, what do you want to claim (1-12)? 3

Current Score after 7 of 12 rounds:

 ...

That was the last turn.
Here is the final score:

Roll            Jeff  Veron   Apple
1's               5      3       4
...
TOTAL           114    178     169


The winner was Veronica with 178 points.

Would you like to play again (Y/N) ? Y
Same players as last time (Y/N)? Y

------------------------------------------------------------------------

Routines:

Display board.
Display help.
Ask number and names of players.
Display a string and prompt for Y or N.
Display what dice user has (sorted)
Ask what what dice to keep.
Roll dice being kept.
Roll 1 die.
Roll n dice.
Ask what category to claim (only show possible ones).
Display winner.
Generate random number between i and j. Calls rand(). Randomize using _randomize().
Make move for computer.
Initialized data structures.

---

Data Structures


int numPlayers - number of players
bool isComputerPlayer[3] - returns true if a given player is a computer.
char *playerNames[3] - names of players
int scoreSheet[playerNum 3][category 12] 2d array of values given player number and category.
int dice[playerNum][6] Current dice for player.

*/

/* CONSTANTS */

/* Maximum number of players */
#define PLAYERS 3

/* TYPES */

/* DATA */



/* Main program */
int main(void)
{
    int i, n;

#ifdef __CC65__
    _randomize();
#endif

    printf("%s", "\nWelcome to YUM!\n");

    for (i=0; i < 5; i++) {
        n = rand() % 6 + 1;
        printf("%d ", n);
    }
    printf("\n");

    return 0;
}
