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

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

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

*/

/* CONSTANTS */

/* Sentinel value indicating that a category has not been played yet. */
#define UNSET -1

/* Maximum number of players */
#define MAXPLAYERS 3

/* Number of categories in score. */
#define MAXCATEGORY 12

/* Number of dice. */
#define MAXDICE 5

/* TYPES */

/* DATA */

/* Number of players. */
int numPlayers;

/* Returns true if a given player is a computer. */
bool isComputerPlayer[MAXPLAYERS];

/* Names of each player. */
char *playerName[MAXPLAYERS];

/* 2d array of values given player number and category. */
int scoreSheet[MAXPLAYERS][MAXCATEGORY];

/* Current dice for player. */
int dice[MAXPLAYERS][MAXDICE];

/* Functions*/

/*
 * Initialize score table to initial values for start of a game. Don't
 * clear player names since we may be starting a new game with the
 * same players.
 */

void initialize()
{
    int p, c;

    for (p = 0; p < MAXPLAYERS; p++) {
        for (c = 0; c < MAXCATEGORY; c++) {
            scoreSheet[p][c] = UNSET;
        }
    }
}

/* Display the current score card. Displays final results if all categories are played. */
void displayScore();

/* Display help information. */
void displayHelp();

/*
 * Ask number and names of players. Sets values of numPlayers,
 *  isComputerPlayer, and playerName.
 */

void setPlayers();

/* Display a string and prompt for Y or N. Return boolean value.
TODO: Remove  need to hit <Enter>?
*/

bool promptYesNo(char *string);

/* Display what dice user has (sorted) */
void displayDice(int playerNum);

/* Ask what what dice to keep. With checking of values. */
void askPlayerDiceToKeep(int playerNum);

/* Roll dice being kept. */
void rollKeptDice(int playerNum);

/* Generate random number from low and high inclusive, e.g. randomNumber(1, 6) for a die. Calls rand(). */
int randomNumber(low, high)
{
    return rand() % high + low;
}

/* Roll 1 die. */
int rollDie()
{
    return randomNumber(1, 6);
}

/* Roll n dice. */
int rollDice(int n);

/* Ask what category to claim (only show possible ones). */
int playerPlayCategory(int playerNum);

/* Display winner. */
void displayWinner();

/* Computer decides what dice to keep. */
void askComputerDiceToKeep(int playerNum);

/* Computer decides what category to play. */
int computerPlayCategory(int playerNum);

/* Call srand() with a key based on player's names to try to make it somewhat random. */
void setRandomSeed();

/* Main program */
int main(void)
{
    int i, n;


    printf("%s", "\nWelcome to YUM!\n");

    initialize();

    for (i=0; i < 5; i++) {
        n = rand() % 6 + 1;
        printf("%d ", n);
    }
    printf("\n");

    return 0;
}
