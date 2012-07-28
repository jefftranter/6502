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
 * TODO:
 * - compile time option for all uppercase output
 * - make computer player smarter
 *
 * Revision History:
 *
 * Version  Date         Comments
 * -------  ----         --------
 * 0.0      25 Jul 2012  Started coding
 *
 */

#include <ctype.h>
#include <errno.h>
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

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXX       YYYYYYYYXXXXXXXXYYYYYYYY
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

1  - 1's (0/5)
2  - 2's (0/10)
3  - 3's (9/15)
4  - 4's (0/20)
5  - 5's (0/25)
6  - 6's (12/30)
7  - Low Straight (0/15)
8  - High Straight (0/20)
9  - Low Score (25)
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
#define MAXCATEGORY 15

/* Number of dice. */
#define MAXDICE 5

/* Number of rounds. */
#define MAXROUNDS 12

/* Number of dice rolls. */
#define MAXROLLS 3

/* TYPES */

/* DATA */

/* Number of players. */
int numHumanPlayers;

/* Number of players. */
int numComputerPlayers;

/* Current round. */
int currentRound;

/* Current player. */
int player;

/* Current dice roll number (1-3). */
int roll;

/* Returns true if a given player is a computer. */
bool isComputerPlayer[MAXPLAYERS];

/* Names of each player. */
char playerName[MAXPLAYERS][10];

/* 2d array of values given player number and category. */
int scoreSheet[MAXPLAYERS][MAXCATEGORY];

/* Current dice for player. */
int dice[MAXDICE];

/* General purpose buffer for user input. */
char buffer[40];

/* Names of computer players. */
char *computerNames[MAXPLAYERS] = { "Apple", "Replica", "Woz" };

/* Names of categories */
char *labels[MAXCATEGORY] = { "1's", "2's", "3's", "4's", "5's", "6's", "Sub-total", "Bonus", "Low Straight", "High Straight", "Low Score", "High Score", "Full House", "YUM", "TOTAL" };

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

/* Wait fot user to press enter then continue. */
void pressEnter()
{
    fgets(buffer, sizeof(buffer)-1, stdin);
}

/* Print a score value as a number. If set to UNSET, display blanks. */
void printField(int i)
{
    if (i == UNSET) {
        printf("        ");
    } else {
        printf("%-8d", i);
    }
}

/* Print numeric row of the score card. */
void printRow(char *label, int row)
{
    int p;

    printf("%-15s", label);
    for (p = 0; p < numHumanPlayers + numComputerPlayers; p++) {
        printField(scoreSheet[p][row]);
    }
    printf("\n");
}

/* Update scores after a turn, i.e. recalculate totals. */
void updateScore()
{
    int p, i, total;

    for (p = 0; p < numHumanPlayers + numComputerPlayers; p++) {

        /* Calculate sub-total. */
        total = 0;
        for (i = 0; i <= 5 ; i++) {
            if (scoreSheet[p][i] != -1) {
                total += scoreSheet[p][i];
            }
        }
        scoreSheet[p][6] = total;

        /* Calculate bonus. */
        if (scoreSheet[p][6] >= 63) {
            scoreSheet[p][7] = 25;
        } else {
            scoreSheet[p][7] = 0;
        }

        /* Calculate total. */
        total = 0;
        for (i = 6; i <= 13 ; i++) {
            if (scoreSheet[p][i] != -1) {
                total += scoreSheet[p][i];
            }
        }
        scoreSheet[p][14] = total;
    }
}

/* Display the current score card. Displays final results if all categories are played. */
void displayScore()
{
    int i;

    printf("Current Score after %d of 12 rounds:\n", currentRound);
    printf("Roll           ");
    for (i = 0; i < numHumanPlayers + numComputerPlayers; i++) {
        printf("%-8s", playerName[i]);
    }
    printf("\n");

    for (i = 0; i < MAXCATEGORY; i++) {
        printRow(labels[i], i);
    }
}

/* Display help information. Needs to fit on 40 char by 22 line screen. */
void displayHelp()
{
    printf("%s",
           "This is a computer version of the game\n"
           "YUM, similar to games known as Yahtzee,\n"
           "Yacht and Generala. Each player rolls\n"
           "five dice up to three times and then\n"
           "applies the dice toward a category to\n"
           "claim points. The game has 12 rounds\n"
           "during which each player attempts to\n"
           "claim the most points in each category.\n"
           "\n"
           "The winner is the person scoring the\n"
           "most points at the end of the game.\n"
           "\n"
           "This version supports up to three\n"
           "players of which any can be human or\n"
           "computer players.\n");
}

/* Display a string and prompt for a string. */
char *promptString(char *string)
{
    printf("%s?", string);
    fgets(buffer, sizeof(buffer)-1, stdin);
    buffer[strlen(buffer)-1] = '\0'; // Remove newline at end of string
    return buffer;
}

/* Display a string and prompt for a number. Number must be in range
 * min through max. Returns numeric value. TODO: Filter and ignore
 * invalid characters?
 */
int promptNumber(char *string, int min, int max)
{
    int val = 0;
    char *endptr = 0;

    while (true) {
        printf("%s (%d-%d)?", string, min, max);
        fgets(buffer, sizeof(buffer)-1, stdin);
        errno = 0;
        val = strtol(buffer, &endptr, 10);
        if ((errno == 0) && (endptr != buffer) && (val >= min) && (val <= max))
            return val;
    }
}

/*
 * Ask number and names of players. Sets values of numPlayers,
 *  isComputerPlayer, and playerName.
 */
void setPlayers()
{
    int i;

    numHumanPlayers = promptNumber("How many human players", 0, MAXPLAYERS);
    if (numHumanPlayers < MAXPLAYERS) {
        numComputerPlayers = promptNumber("How many computer players", (numHumanPlayers == 0) ? 1 : 0, MAXPLAYERS - numHumanPlayers);
    } else {
        numComputerPlayers = 0;
    }

    for (i = 0; i < numHumanPlayers; i++) {
        sprintf(buffer, "Name of player %d", i+1);
        strcpy(playerName[i], promptString(buffer));
        isComputerPlayer[i] = false;
    }

    for (i = numHumanPlayers; i < numHumanPlayers + numComputerPlayers; i++) {
        strcpy(playerName[i], computerNames[i - numHumanPlayers]);
        isComputerPlayer[i] = true;
    }
}

/* Clear the screen */
void clearScreen()
{
    int i;

    for (i = 0; i < 24; ++i)
        printf("\n");
}

/* Display a string and prompt for Y or N. Return boolean value.
 * TODO: Remove need to hit <Enter> ?
 */
bool promptYesNo(char *string)
{
    while (true) {
        printf("%s (Y/N)?", string);
        fgets(buffer, sizeof(buffer)-1, stdin);    
        if (toupper(buffer[0]) == 'Y')
            return true;
        if (toupper(buffer[0]) == 'N')
            return false;
    }
}

/* Compare function for sorting. */
int compare(const void *i, const void *j)
{
    return *(int *)(i) - *(int *)(j);
}

/* Sort dice */
void sortDice()
{
    qsort(dice, sizeof(dice) / sizeof(dice[0]), sizeof(dice[0]), compare);
}

/* Display what dice user has. */
void displayDice()
{
    int i;
 
    for (i = 0; i < MAXDICE; i++) {
        printf(" %d", dice[i]);
    }
}

/* Ask what what dice to keep. Return false if does not want to roll any. */
bool askPlayerDiceToKeep()
{
    printf("What numbers do you want to keep?");

}   

/* Roll dice being kept. */
void rollKeptDice()
{
}

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

/* Roll the dice. */
void rollDice()
{
    int i;
 
    for (i = 0; i < MAXDICE; i++) {
        dice[i] = randomNumber(1, 6);
    }
}

/* Ask what category to claim (only show possible ones). */
int playerPlayCategory()
{
    //Jeff, what do you want to claim (1-12)? 3
}

/* Display winner. */
void displayWinner();

/* Computer decides what dice to keep. Return false if does not want to roll any. */
bool askComputerDiceToKeep()
{
}

/* Computer decides what category to play. */
int computerPlayCategory();

/*
 * Call srand() with a key based on player's names to try to make it
 * somewhat random. Be sure to call this after setting player
 * names. 
 */
void setRandomSeed()
{
    int i, p, seed;

    seed = 0;

    for (p = 0; p < numHumanPlayers + numComputerPlayers; p++) {
        for (i = 0; i < strlen(playerName[p]); i++) {
            seed = (seed << 1) ^ playerName[p][i];
        }
    }
    srand(seed);
}

/* Main program */
int main(void)
{
    initialize();

    clearScreen();
    printf("%s", "\nWelcome to YUM!\n");

    if (promptYesNo("Do you want instructions")) {
        clearScreen();
        displayHelp();        
    }

    setPlayers();

    /* This needs to be done after setting player names since the seed is based on names. */
    setRandomSeed();

    printf("Press <Enter> to start the game");
    pressEnter();

    for (currentRound = 1; currentRound <= MAXROUNDS; currentRound++) {
        for (player = 0; player < numHumanPlayers + numComputerPlayers; player++) {

            printf("%s's turn. Press <Enter> to roll", playerName[player]);
            pressEnter();

            for (roll = 1; roll <= MAXROLLS; roll++) {
                rollDice();
                sortDice();
                printf("On your first roll you have:");
                displayDice();
                printf("\n");

                askPlayerDiceToKeep();
                rollKeptDice();
            }

            playerPlayCategory();
            updateScore();
            displayScore();
        }
    }

    return 0;
}
