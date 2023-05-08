/*

Conway's Game of Life in assembler for the Ohio Scientic Challenger 1P.

Summary of rules:
- Any live cell with two or three live neighbours survives.
- Any dead cell with three live neighbours becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.

See https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

To Do:
- Optimize speed
- Add keyboard commands to pause, restart, quit
- Restart if new pattern is same as old?
- Print number of generations?
*/

#include <stdlib.h>
#ifndef __OSIC1P__
#include <stdio.h>
#include <time.h>
#endif

char old[24][24]; // Old cell data
char new[24][24]; // New cell data

// Return true if new cell data has no living cells
int IsEmpty()
{
    int i, j;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (new[i][j] == 1)
                return 0;
        }
    }
    return 1;
}

// Fill new cell array with random data
// Roughly half the cells are set to one.
void FillRandom()
{
    int i, j;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (rand() & 0x01) {
                new[i][j] = 1;
            } else {
                new[i][j] = 0;
            }
        }
    }
}

// Return 1 if x and y are valid for array
int inRange(int x, int y)
{
    return x >= 0 && x < 24 && y >= 0 && y < 24;
}

// Return number of live neighbours for old cell
int numberOfNeighbours(int x, int y)
{
    int n = 0;

    // Check:
    // [x-1][y-1] [x][y-1] [x+1][y-1]
    // [x-1][y]     CELL   [x+1][y]
    // [x-1][y+1] [x][y+1] [x+1][y+1]

    if (inRange(x-1,y-1) && old[x-1][y-1] == 1)
        n += 1;
    if (inRange(x,y-1) && old[x][y-1] == 1)
        n += 1;
    if (inRange(x+1,y-1) && old[x+1][y-1] == 1)
        n += 1;
    if (inRange(x-1,y) && old[x-1][y] == 1)
        n += 1;
    if (inRange(x+1,y) && old[x+1][y] == 1)
        n += 1;
    if (inRange(x-1,y+1) && old[x-1][y+1] == 1)
        n += 1;
    if (inRange(x,y+1) && old[x][y+1] == 1)
        n += 1;
    if (inRange(x+1,y+1) && old[x+1][y+1] == 1)
        n += 1;

    return n;
}

// Copy new array to old.
// TODO: Use memcpy?
void CopyNewToOld()
{
    int i, j;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            old[i][j] = new[i][j];
        }
    }
}

// Display new values in video memory.
void Display()
{
    int i, j;
#ifdef __OSIC1P__
    char c;
    char *v = (char *)0xd085;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (new[i][j] == 1) {
                c = 0xa1;
            } else {
                c = 0x20;
            }
            *(v + i + 32 * j) = c;
        }
    }
#else
    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (new[i][j] == 1) {
                printf("*");
            } else {
                printf(".");
            }
        }
        printf("\n");
    }
    printf("\n");

#endif
}

// Calculate new generation based on data in old.
void CalculateGeneration()
{
    int i, j;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (old[i][j] == 0) { // Dead cell
                if (numberOfNeighbours(i, j) == 3) {
                    new[i][j] = 1;
                } else {
                    new[i][j] = 0;
                }
            } else { // Live cell
                if (numberOfNeighbours(i, j) == 2 || numberOfNeighbours(i, j) == 3) {
                    new[i][j] = 1;
                } else {
                    new[i][j] = 0;
                }
            }
        }
    }
}

int main()
{
#ifndef __OSIC1P__
    srand(time(0));
#endif

    while (1) {

        // If new cells empty (due to being at start or all cells have
        // died) we fill it again with random data.
        if (IsEmpty()) {
            FillRandom();
        }

        // Display new array on screen.
        Display();

        // Copy new data to old
        CopyNewToOld();

        // Calculate new data
        CalculateGeneration();
    }

    return 0;
}
