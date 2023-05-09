/*

Conway's Game of Life in assembler for the Ohio Scientific Challenger 1P.

Summary of rules:
- Any live cell with two or three live neighbours survives.
- Any dead cell with three live neighbours becomes a live cell.
- All other live cells die in the next generation. Similarly, all other dead cells stay dead.

See https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

Jeff Tranter <tranter@pobox.com>

To Do:
- Poll for keyboard commands more often.
- Optimization: Write critical code as in-line assembler.
- Option to wrap around at edges?

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
    "..XX...................."
    "..XX...................."
    ".............XX........."
    "............X..X........"
    ".............X.X........"
    "..............X........."
    "........................"
    "...XX..................."
    "..X..X.................."
    "...XX..................."
    "........................"
    "........................"
    "........................"
    "......XX......X........."
    "......X.X....X.X........"
    ".......X......X........."
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
    "....XXX.......XXX......."
    ".............XXX........"
    "........................"
    "........................"
    "........................"
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

// Cell data is 24x24, but we add an extra row and column around the
// edges so we don't have to handle the special cases of checking for
// the edges of the screen, which speeds up the calculations.
// So the valid range of data is elements 1 to 24.
// Using size of 32 makes array access use shift and not multiply and
// is a big performance boost.

unsigned char old[32][32]; // Old cell data
unsigned char new[32][32]; // New cell data

// Fill new cell array with random data
// Roughly half the cells are set to one.
void FillRandom()
{
    unsigned char i, j;

    memset(new, 0, sizeof(new));

    for (i = 1; i <= 24; i++) {
        for (j = 1; j <= 24; j++) {
            if (rand() & 0x01) {
                new[i][j] = 1;
            }
        }
    }
}

void loadPattern(const char *p)
{
    unsigned char i, j, c;

    memset(new, 0, sizeof(new));

    for (i = 1 ; i <= 24; i++) {
        for (j = 1 ; j <= 24; j++) {
            c = p[i + 24 * j];
            if (c == 'X') {
                new[i][j] = 1;
            }
        }
    }
}

// Copy new array to old.
void CopyNewToOld()
{
    memcpy(old, new, sizeof(new));
}

// Display new values in video memory.
void Display()
{
    unsigned char i, j;
#ifdef __OSIC1P__
    char *v = (char *)0xd085;

    memset(v, 0x20, 0x0400); // Initially clear screen

    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (new[i+1][j+1] == 1) {
                v[i + j * 32] = 0xa1; // Block character
            }
        }
    }
#else
    for (i = 0; i < 24; i++) {
        for (j = 0; j < 24; j++) {
            if (new[i+1][j+1] == 1) {
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

#ifdef __OSIC1P__
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
#endif

// Calculate new generation based on data in old.
void CalculateGeneration()
{
    unsigned char i, j;
    unsigned char n;

    memset(new, 0, sizeof(new)); // Initially clear

    for (i = 1; i <= 24; i++) {
        for (j = 1; j <= 24; j++) {

            // Calculate number of live neighbours for old cell
            // Check:
            // [i-1][j-1] [i][j-1] [i+1][j-1]
            // [i-1][j]     CELL   [i+1][j]
            // [i-1][j+1] [i][j+1] [i+1][j+1]

            // Any performance optimization should focus on speeding up the line below.
            n = old[i-1][j-1] + old[i][j-1] + old[i+1][j-1] + old[i-1][j] + old[i+1][j] + old[i-1][j+1] + old[i][j+1] + old[i+1][j+1];

            if (n != 2 && n != 3) { // Can skip calculation
                continue;
            }

            if (old[i][j] == 0) { // Dead cell
                if (n == 3) {
                    new[i][j] = 1;
                }
            } else { // Live cell
                if (n == 2 || n == 3) {
                    new[i][j] = 1;
                }
            }
        }
    }
}

int main()
{
    long iterations = 0;
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

        // Uncomment lines below to show # iterations on screen.
        //*(char *)0xd365 = iterations/100 + '0';
        //*(char *)0xd366 = (iterations % 100) / 10 + '0';
        //*(char *)0xd367 = (iterations % 10) + '0';
        //iterations++;

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
