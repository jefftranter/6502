/*
 *
 * Boolean Logic Game
 * 
 * Jeff Tranter <tranter@pobox.com>
 *
 * TO DO:
 * Generate a minimal data file.
 * Parse data file and read into data structure.
 * Beep on bad input.
 */

// Includes

#ifdef __CC65__
#include <apple2enh.h>
#include <conio.h>
#include <peekpoke.h>
#endif
#include <stdio.h>
#include <stdlib.h>

// Constants

#define MAX_ENTRIES 16
#define MAX_GAMES 32
#define LEVEL_FILE "levels.csv"
#ifdef __CC65__
#define TUTORIAL "tutorial"
#define OVERVIEW "overview"
#else
#define TUTORIAL "tutorial.txt"
#define OVERVIEW "overview.txt"
#endif

// Data types

typedef struct game_t {
    char *name;
    int level;
    int numInputs;
    int numOutputs;
    int numEntries;
    char *imageFile;
    int input1[MAX_ENTRIES];
    int input2[MAX_ENTRIES];
    int input3[MAX_ENTRIES];
    int input4[MAX_ENTRIES];
    int output1[MAX_ENTRIES];
    int output2[MAX_ENTRIES];
    int output3[MAX_ENTRIES];
    int output4[MAX_ENTRIES];
} game_t;

// Global variables

int difficultyLevel;
game_t games[MAX_GAMES];

// Functions

// Clear the screen.
void clearScreen()
{
#ifdef __CC65__
    clrscr();
#endif
}

// Make an error beep.
void beep()
{
    putchar('\a');
}

// Prompt user to press a key to continue.
void pressKeyToContinue()
{
    printf("<Press any key to continue> ");
#ifdef __CC65__
    cgetc();
#else
    getchar();
#endif
    printf("\n");
}

// Read game data file into data structure.
void readDataFile()
{
}

// Print file on screen with paging every 24 lines.
void showFile(char *filename) {
    FILE *fp;
    char buffer[80];
    int lines = 0;

#ifdef __CC65__
    _filetype = PRODOS_T_TXT;
#endif

    fp = fopen(filename, "r");

    if (fp == NULL) {
        perror(filename);
        return;
    }

    clearScreen();
    
    while (!feof(fp)) {
        fgets(buffer, sizeof(buffer)-1, fp);
        printf("%s", buffer);

        lines += 1;
        if (lines >= 23) {
            pressKeyToContinue();
            lines = 0;
        }
    }

    pressKeyToContinue();
    fclose(fp);
}

int selectDifficulty()
{
    char c;

    printf("Select Difficulty Level:\n");
    printf("1. Basic Gates.\n");
    printf("2. Simple Circuits.\n");
    printf("3. Intermediate Circuits.\n");
    printf("4. Complex circuit.\n");
    printf("5. Return to main menu.\n");
    printf("Selection? ");

    while (1) {
#ifdef __CC65__
        c = cgetc();
#else
        c = getchar();
#endif
        if (c >= '1' && c <= '5') {
            break;
        } else {
            beep();
        }   
    }

    return c - '0';
}

void fillInTruthTable()
{
    difficultyLevel = selectDifficulty();
}

void guessTheCircuit()
{
    difficultyLevel = selectDifficulty();
}

int main (void)
{
    char c;

    readDataFile();

    while (1) {
        clearScreen();
  
        printf("The Boolean Game\n");
        printf("================\n");
        printf("1. Overview.\n");
        printf("2. Tutorial.\n");
        printf("3. Play Fill in the Truth Table.\n");
        printf("4. Play Guess the Circuit.\n");
        printf("5. Quit.\n");

        printf("Selection? ");

        while (1) {
#ifdef __CC65__
            c = cgetc();
#else
            c = getchar();
#endif
            if (c >= '1' && c <= '5') {
                break;
            } else {
                beep();
            }   
        }

        switch (c) {
        case '1':
            showFile(OVERVIEW);
            break;
        case '2':
            showFile(TUTORIAL);
            break;
        case '3':
            fillInTruthTable();
            break;
        case '4':
            guessTheCircuit();
            break;
        case '5':
            clearScreen();
            return EXIT_SUCCESS;        
            break;
        }
    }
}
