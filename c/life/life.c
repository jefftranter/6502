/*

Conway's Game of Life in assembler for the Ohio Scientific Challenger 1P.

Summary of rules:
- Any live cell with two or three live neighbours survives.
- Any dead cell with three live neighbours becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.

See https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

Jeff Tranter <tranter@pobox.com>

*/

#include <stdlib.h>
#include <string.h>
#ifdef __OSIC1P__
#include <conio.h>
#else
#include <stdio.h>
#include <time.h>
#endif

// Some fixed initial patterns.

// 1 - Still Lifes:
const char *pat1 =
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "..XX.........XX........."
    "..XX........X..X........"
    ".............X.X........"
    "...XX.........X........."
    "..X..X.................."
    "...XX..................."
    "........................"
    "......XX......X........."
    "......X.X....X.X........"
    ".......X......X........."
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................";

// 2 - Blinker/Toad/Beacon:
const char *pat2 =
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "....XXX.......XXXX......"
    ".............XXXX......."
    "........................"
    "........................"
    "........XX.............."
    "........XX.............."
    "..........XX............"
    "..........XX............"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................";

// 3 - Pulsar:
const char *pat3 =
    "........................"
    "........................"
    "........................"
    "........................"
    ".......X.....X.........."
    ".......X.....X.........."
    ".......XX...XX.........."
    "........................"
    "...XXX..XX.XX..XXX......"
    ".....X.X.X.X.X.X........"
    ".......XX...XX.........."
    "........................"
    ".......XX...XX.........."
    ".....X.X.X.X.X.X........"
    "...XXX..XX.XX..XXX......"
    "........................"
    ".......XX...XX.........."
    ".......X.....X.........."
    ".......X.....X.........."
    "........................"
    "........................"
    "........................"
    "........................"
    "........................";

// 4 - Pentadecathlon:
const char *pat4 =
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    ".........XXX............"
    ".........X.X............"
    ".........XXX............"
    ".........XXX............"
    ".........XXX............"
    ".........XXX............"
    ".........X.X............"
    ".........XXX............"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................"
    "........................";

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

void loadPattern(const char *p)
{
    int i, j;
    char c;

    for (i = 0 ; i < 24; i++) {
        for (j = 0 ; j < 24; j++) {
            c = p[i + 24 * j];
            if (c == 'X') {
                new[i][j] = 1;
            } else {
                new[i][j] = 0;
            }
        }
    }
}

// Return if x and y are valid for array
#define INRANGE(x,y) (x >= 0 && x < 24 && y >= 0 && y < 24)

// Return number of live neighbours for old cell
int numberOfNeighbours(int x, int y)
{
    int n = 0;

    // Check:
    // [x-1][y-1] [x][y-1] [x+1][y-1]
    // [x-1][y]     CELL   [x+1][y]
    // [x-1][y+1] [x][y+1] [x+1][y+1]

    if (INRANGE(x-1,y-1) && old[x-1][y-1] == 1)
        n += 1;
    if (INRANGE(x,y-1) && old[x][y-1] == 1)
        n += 1;
    if (INRANGE(x+1,y-1) && old[x+1][y-1] == 1)
        n += 1;
    if (INRANGE(x-1,y) && old[x-1][y] == 1)
        n += 1;
    if (INRANGE(x+1,y) && old[x+1][y] == 1)
        n += 1;
    if (INRANGE(x-1,y+1) && old[x-1][y+1] == 1)
        n += 1;
    if (INRANGE(x,y+1) && old[x][y+1] == 1)
        n += 1;
    if (INRANGE(x+1,y+1) && old[x+1][y+1] == 1)
        n += 1;

    return n;
}

// Copy new array to old.
void CopyNewToOld()
{
    memcpy(old, new, sizeof(new));
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
            *(v + i + j * 32) = c;
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

// Handle keyboard command
void keyboardCommand()
{
    char c = cgetc();

    switch (c) {
    case 'H':
    case '?':
        clrscr();
        cprintf("Keyboard Commands:\r\n");
        cprintf("H or ? - Help\r\n");
        cprintf("<space> - Pause\r\n");
        cprintf("Q - Quit\r\n");
        cprintf("R - Restart (random)\r\n");
        cprintf("1..4 - Load pattern\r\n");
        while (!kbhit())
            ;
        break;
    case ' ':
        while (!kbhit())
            ;
        break;
    case 'Q':
        exit(0);
        break;
    case 'R':
        FillRandom();
        break;
    case '1':
        loadPattern(pat1);
        break;
    case '2':
        loadPattern(pat2);
        break;
    case '3':
        loadPattern(pat3);
        break;
    case '4':
        loadPattern(pat4);
        break;
    }
}

// Calculate new generation based on data in old.
void CalculateGeneration()
{
    int i, j, n;

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            n = numberOfNeighbours(i, j);
            if (old[i][j] == 0) { // Dead cell
                if (n == 3) {
                    new[i][j] = 1;
                } else {
                    new[i][j] = 0;
                }
            } else { // Live cell
                if (n == 2 || n == 3) {
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
#ifdef __OSIC1P__
    unsigned int i;

    clrscr();
    cprintf("\r\nPress a key to start...");
    while (!kbhit()) {
        i++;
    }
    srand(i); // Seed random number generator
#else
    srand(time(0)); // Seed random number generator
#endif

    FillRandom(); // Initialize with random cells

    while (1) {

        // Display new array on screen.
        Display();

        // Restart if new pattern is same as old
        if (!memcmp(old, new, sizeof(new))) {
            FillRandom(); // Initialize with random cells
        }

        // Copy new data to old
        CopyNewToOld();

        // Calculate new data
        CalculateGeneration();

#ifdef __OSIC1P__
        if (kbhit()) {
            keyboardCommand();
        }
#endif
    }

    return 0;
}
