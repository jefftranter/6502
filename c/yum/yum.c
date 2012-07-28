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

Up to 3 players (set at compile time, limited by screen size).
Players can be the computer.

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

/* Mark all dice to be rolled. */
void markAllDiceToBeRolled()
{
    int p;

    for (p = 0; p < MAXDICE; p++) {
        dice[p] = UNSET;
    }
}

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

    /* Initialize all dice to UNSET state too. */
    markAllDiceToBeRolled();
}

/* Wait fot user to press enter then continue. */
void pressEnter()
{
    fgets(buffer, sizeof(buffer)-1, stdin);
}

/* Print a score value as a number. If set to UNSET, displayw blanks. */
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
           "computer players.\n\n");
}

/* Return number of dice that are n. */
int numberOf(int n)
{
    int i;
    int sum = 0;

    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] == n) {
            sum += 1;
        }
    }
    return sum;
}

/*
 *  Return if dice form a low straight.
 * The dice must be sorted in order from low to high
 */
bool hasLowStraight()
{
    int i;

    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] != i + 1) {
            return false;
        }
    }
    return true;
}

/*
 *  Return if dice form a high straight.
 * The dice must be sorted in order from low to high
 */
bool hasHighStraight()
{
    int i;

    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] != i + 2) {
            return false;
        }
    }
    return true;
}

/* Return sum of dice. */
int sum()
{
    int i;
    int sum = 0;

    for (i = 0; i < MAXDICE; i++) {
            sum += dice[i];
    }
    return sum;
}

/* Return if dice form a full house. Dice must be sorted in order. */
bool hasFullHouse()
{
    if ((dice[0] == dice[1]) && (dice[1] == dice[2]) && (dice[3] == dice[4]))
        return true;
    if ((dice[0] == dice[1]) && (dice[2] == dice[3]) && (dice[3] == dice[4]))
        return true;
    return false;
}

/* Return if dice form a Yum. */
bool hasYum()
{
    int i;

    for (i = 1; i < MAXDICE; i++) {
        if (dice[i] != dice[0]) {
            return false;
        }
    }
    return true;
}

/* Display a string and prompt for a string. */
char *promptString(char *string)
{
    printf("%s?", string);
    fgets(buffer, sizeof(buffer)-1, stdin);
    buffer[strlen(buffer)-1] = '\0'; /* Remove newline at end of string */
    return buffer;
}

/* Display a string and prompt for a number. Number must be in range
 * min through max. Returns numeric value.
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

/* Display a string and prompt for Y or N. Return boolean value. */
bool promptYesNo(char *string)
{
    while (true) {
        printf("%s (y/n)?", string);
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

/* Return if dice contains number i. */
bool contains(int die)
{
    int i;
 
    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] == die)
            return true;
    }
    return false;
}

/* Return location of number i in dice array. */
int find(int die)
{
    int i;
 
    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] == die)
            return i;
    }
    return UNSET;
}

/* Ask what what dice to roll again. Return false if does not want to roll any. */
int askPlayerDiceToRollAgain()
{
    int i;
    bool valid;
    
    while (true) {

        printf("What dice you want to roll again?");
        fgets(buffer, sizeof(buffer)-1, stdin);
        buffer[strlen(buffer)-1] = '\0'; /* Remove newline at end of string */

        /* If empty string, no dice to roll again and we return with false status. */
        if (strlen(buffer) == 0) {
            return false;
        }

        valid = true;
        /* First validate the input line. */
        for (i = 0; i < strlen(buffer); i++) {
            /* Validate character. */
            if ((buffer[i] != ' ') && ((buffer[i] < '1') || (buffer[i] > '6'))) {
                printf("Invalid input: '%c', try again.\n", buffer[i]);
                valid = false;
                break;
            }
        }

        /* Try again if not valid. */
        if (!valid) {
            continue;
        }

        /* Now examine the input line */
        for (i = 0; i < strlen(buffer); i++) {
            /* Skip any space */
            if (buffer[i] == ' ') {
                continue;
            }
            
            /* Does it match a die we have? If so, unset it to mark it to be rolled again. */
            if (contains(buffer[i] - '0')) {
                dice[find(buffer[i] - '0')] = UNSET;
            } else {
                printf("You don't have a '%c', try again.\n", buffer[i]);
                valid = false;
                break; 
           }
        }

        /* Try again if not valid. */
        if (!valid) {
            continue;
        }

        return true;
    }
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

/* Roll the dice. Only some dice need to be rolled, the ones that are set to UNSET. */
void rollDice()
{
    int i;

    for (i = 0; i < MAXDICE; i++) {
        if (dice[i] == UNSET) {
            dice[i] = randomNumber(1, 6);
        }
    }
}

/* Ask what category to claim (only show possible ones). */
void playerPlayCategory()
{
    int category;
    char buffer[40];

    for (category = 0; category < MAXCATEGORY; category++) {
        /* Some categories need to be skipped. */
        if ((category == 6) || (category == 7) || (category == 14)) {
            continue;
        }

        if (scoreSheet[player][category] == UNSET) {
            printf("%d  - %s\n", category + 1, labels[category]);
        }
    }

    while (true) {
        sprintf(buffer, "%s, what do you want to claim?", playerName[player]);
        category = promptNumber(buffer, 1, MAXCATEGORY-1) - 1;
        if (scoreSheet[player][category] != UNSET) {
            printf("You already used that category. Try again.\n");
        } else {
            break;
        }
    }

    switch (category) {
    case 0: case 1: case 2: case 3: case 4: case 5:
        /* Score is number of the dice times the die value. */
        scoreSheet[player][category] = numberOf(category + 1) * (category + 1);
        break;
    case 8: /* Low straight */
        scoreSheet[player][category] = hasLowStraight() ? 15 : 0;
        break;
    case 9: /* High straight */
        scoreSheet[player][category] = hasHighStraight() ? 20 : 0;
        break;
    case 10: /* Low score TODO: Must be less than high score. */
        scoreSheet[player][category] = (sum() >= 21) ? sum() : 0;
        break;
    case 11: /* High score TODO: Must be more than low score. */
        scoreSheet[player][category] = (sum() >= 22) ? sum() : 0;
        break;
    case 12: /* Full House */
        scoreSheet[player][category] = hasFullHouse() ? 25 : 0;
        break;
    case 13: /* YUM */
        scoreSheet[player][category] = hasYum() ? 30 : 0;
        break;
    }
}

/* Display winner. */
void displayWinner()
{
    int max = UNSET;
    int winner = UNSET;
    int p;

    for (p = 0; p < numHumanPlayers + numComputerPlayers; p++) {
        if (scoreSheet[p][14] > max) {
            winner = p;
        }
    }

    // TODO: Check for a tie.

    /* Display the winner. */
    printf("The winner is %s with %d points.\n", playerName[winner], scoreSheet[winner][14]);

    /* Display other player's scores. */
    for (p = 0; p < numHumanPlayers + numComputerPlayers; p++) {
        if (p != winner) {
            printf("%s has %d points.\n", playerName[p], scoreSheet[p][14]);
        }
    }
}

/* Computer decides what dice to roll again. Return false if does not want to roll any. */
bool askComputerDiceToRollAgain()
{
    // TODO: Implement
    return false;
}

/* Computer decides what category to play. */
int computerPlayCategory()
{
    // TODO: Implement
    return 0;
}

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
            markAllDiceToBeRolled();

            for (roll = 1; roll <= MAXROLLS; roll++) {
                bool ret;

                rollDice();
                sortDice();
                if (roll == 1) {
                    printf("On your first roll you have:");
                } else if (roll == 2) {
                    printf("On your second roll you have:");
                } else {
                    printf("On your last roll you have:");
                }
                displayDice();
                printf("\n");
                if (roll < 3) {
                    if (isComputerPlayer[player]) {
                        ret = askComputerDiceToRollAgain();
                    } else {
                        ret = askPlayerDiceToRollAgain();
                    }
                    /* Player wants to roll again? */
                    if (ret == false) {
                        break;
                    }
                }
            }

            if (isComputerPlayer[player]) {
                computerPlayCategory();
            } else {
                playerPlayCategory();
            }

            updateScore();
            displayScore();

        }
    }

    displayWinner();

    //Would you like to play again (Y/N) ? Y
    //Same players as last time (Y/N)? Y

    return 0;
}
