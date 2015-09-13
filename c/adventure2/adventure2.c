/*
 * 
 * Skye's Castle Adventure
 *
 * A sequel to The Abandoned Farmhouse Adventure.

 * Jeff Tranter <tranter@pobox.com>
 *
 * Written in standard C but designed to run on the Apple II using the
 * CC65 6502 assembler.
 *
 * Copyright 2012-2015 Jeff Tranter
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
 * 0.0      07 Sep 2015  Started development
 *
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#ifdef __CC65__
#include <conio.h>
#endif

/* CONSTANTS */

/* Maximum number of items user can carry */
#define MAXITEMS 5

/* Number of locations */
#define NUMLOCATIONS 60

/* TYPES */

/* To optimize for code size and speed, most numbers are 8-bit chars when compiling for the Replica 1. */
#ifdef __CC65__
typedef char number;
#else
typedef int number;
#endif

/* Directions */
typedef enum {
    North,
    South,
    East,
    West,
    Up,
    Down
} Direction_t;

/* Items */
typedef enum {
    NoItem,
    Key,
    LastItem=Key
} Item_t;

/* Locations */
typedef enum {
    NoLocation,
    FrontEntrance,
    Vestibule,
    Entry,
    PeacockAlley1,
    PeacockAlley2,
    PeacockAlley3,    
    PeacockAlley4,
    PeacockAlley5,
    DiningRoom,
    Conservatory,
    BreakfastRoom,
    ServingRoom,
    Kitchen,
    Hallway1,
    Hallway2,
    Elevator1,
    Study,
    Library,
    GreatHall,
    Stairs1,
    Landing,
    OakDrawingRoom,
    SmokingRoom,
    CoveredPorch,
    BilliardsRoom,
    Hallway10,
    Hallway11,
    Hallway12,
    Hallway13,
    Hallway14,
    Corridor1,
    Corridor2,
    Narrowhallway,
    RoundRoom,
    PipeOrganLoft,
    Bedroom1,
    SittingRoom1,
    Bedroom3,
    SirHenrysBedroom,
    SittingRoom3,
    LadysBedroom,
    SittingRoom2,
    GuestBedroom,
    Elevator2,
    ChildrensBedroom,
    ServantsBedroom,
    Bedroom4,
    LinenRoom,
    Bedroom2,
    Bath,
    Stairs2,
    Stairs3,
    WineCellar,
    Tunnel1,
    Tunnel2,
    Tunnel3,
    SteamPlant,
    Tunnel4,
    Stables,
} Location_t;

/* TABLES */

/* Names of directions */
char *DescriptionOfDirection[] = {
    "north", "south", "east", "west", "up", "down"
};

/* Names of items */
char *DescriptionOfItem[LastItem+1] = {
    "",
    "key",

};

/* Names of locations */
char *DescriptionOfLocation[NUMLOCATIONS] = {
    "",
    "in the driveway near your car",

};

/* DATA */

/* Inventory of what player is carrying */
Item_t Inventory[MAXITEMS];

/* Location of each item. Index is the item number, returns the location. 0 if item is gone */
Location_t locationOfItem[LastItem+1];

/* Map. Given a location and a direction to move, returns the location it connects to, or 0 if not a valid move. Map can change during game play. */
Direction_t Move[NUMLOCATIONS][6] = {
    /* N  S  E  W  U  D */
    {  0, 0, 0, 0, 0, 0 }, /* 0 */
    {  2, 0, 0, 0, 0, 0 }, /* 1 */
    {  4, 1, 3, 5, 0, 0 }, /* 2 */
    {  0, 0, 6, 2, 0, 0 }, /* 3 */
    {  7, 2, 0, 0, 0, 0 }, /* 4 */
    {  0, 0, 2, 9, 0, 0 }, /* 5 */
    {  0, 0, 0, 3, 0, 0 }, /* 6 */
    {  0, 4, 0, 0, 8, 0 }, /* 7 */
    {  0, 0, 0, 0, 0, 7 }, /* 8 */
    {  0,10, 5, 0, 0,19 }, /* 9 */
    {  9, 0, 0,11, 0, 0 }, /* 10 */
    {  0, 0,10,12,14, 0 }, /* 11 */
    { 13, 0,11, 0, 0, 0 }, /* 12 */
    {  0,12, 0, 0, 0, 0 }, /* 13 */
    { 16, 0,15,17, 0,11 }, /* 14 */
    {  0, 0, 0,14, 0, 0 }, /* 15 */
    {  0,14, 0, 0, 0, 0 }, /* 16 */
    {  0, 0,14, 0, 0, 0 }, /* 17 */
    {  0, 0, 0, 0, 0,13 }, /* 18 */
    {  0, 0, 0,20, 9, 0 }, /* 19 */
    { 21, 0,19, 0, 0, 0 }, /* 20 */
    {  0,20, 0,22, 0, 0 }, /* 21 */
    {  0, 0,21, 0, 0, 0 }, /* 22 */
    { 24,21, 0, 0, 0, 0 }, /* 23 */
    { 29,23, 0,26, 0, 0 }, /* 24 */
    { 26, 0,24, 0, 0, 0 }, /* 25 */
    { 27,25,29, 0, 0, 0 }, /* 26 */
    {  0,26,28, 0, 0, 0 }, /* 27 */
    {  0,29,31,27, 0, 0 }, /* 28 */
    { 28,24,30,26, 0, 0 }, /* 29 */
    { 31, 0, 0,29, 0, 0 }, /* 30 */
    {  0,30, 0,29, 0, 0 }, /* 31 */
};

/* Current location */
number currentLocation;

/* Number of turns played in game */
int turnsPlayed;

/* Set when game is over */
number gameOver;

const char *introText = 
"     Abandoned Farmhouse Adventure\n"
"           By Jeff Tranter\n\n"
"Your great-great-grandfather built a\n"
"castle, but the family fell on hard\n"
"times and it has been vacant for 80\n"
"years. Occasionally, family members\n"
"visit the castle, although it is old\n"
"and dusty and possibly not safe. Today\n"
"your three-year-old granddaughter went\n"
"to visit the castle with her aunt, but\n"
"they did not return in the evening.\n"
"Maybe you should have called the police,\n"
"but instead you decide to go over\n"
"there and find them on your own. It\n"
"looks like a bad storm is brewing, and\n"
"the castle has no electricity, so you\n"
"had better find them before it gets\n"
"too dark.\n";

const char *helpString = "Valid commands:\ngo east/west/north/south/up/down \nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";

/* Line of user input */
char buffer[40];

/* Clear the screen */
void clearScreen()
{
#if defined(__APPLE2__)
    clrscr();
#else
    number i;
    for (i = 0; i < 24; ++i)
        printf("\n");
#endif
}

/* Return 1 if carrying an item */
number carryingItem(char *item)
{
    number i;

    for (i = 0; i < MAXITEMS; i++) {
        if ((Inventory[i] != 0) && (!strcasecmp(DescriptionOfItem[Inventory[i]], item)))
            return 1;
    }
    return 0;
}

/* Return 1 if item it at current location (not carried) */
number itemIsHere(char *item)
{
    number i;

    /* Find number of the item. */
    for (i = 1; i <= LastItem; i++) {
        if (!strcasecmp(item, DescriptionOfItem[i])) {
            /* Found it, but is it here? */
            if (locationOfItem[i] == currentLocation) {
                return 1;
            } else {
                return 0;
            }
        }
    }
    return 0;
}

/* Inventory command */
void doInventory()
{
    number i;
    int found = 0;

    printf("%s", "You are carrying:\n");
    for (i = 0; i < MAXITEMS; i++) {
        if (Inventory[i] != 0) {
            printf("  %s\n", DescriptionOfItem[Inventory[i]]);
            found = 1;
        }
    }
    if (!found)
        printf("  nothing\n");
}

/* Help command */
void doHelp()
{
    printf("%s", helpString);
}

/* Look command */
void doLook()
{
    number i, loc, seen;

    printf("You are %s.\n", DescriptionOfLocation[currentLocation]);

    seen = 0;
    printf("You see:\n");
    for (i = 1; i <= LastItem; i++) {
        if (locationOfItem[i] == currentLocation) {
            printf("  %s\n", DescriptionOfItem[i]);
            seen = 1;
        }
    }
    if (!seen)
        printf("  nothing special\n");

    printf("You can go:");

    for (i = North; i <= Down; i++) {
        loc = Move[currentLocation][i];
        if (loc != 0) {
            printf(" %s", DescriptionOfDirection[i]);
        }
    }
    printf("\n");
}

/* Quit command */
void doQuit()
{
    printf("%s", "Are you sure you want to quit (y/n)? ");
    fgets(buffer, sizeof(buffer)-1, stdin);
    if (tolower(buffer[0]) == 'y') {
        gameOver = 1;
    }
}

/* Drop command */
void doDrop()
{
    number i;
    char *sp;
    char *item;

    /* Command line should be like "D[ROP] ITEM" Item name will be after after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Drop what?\n");
        return;
    }

    item = sp + 1;

    /* See if we have this item */
    for (i = 0; i < MAXITEMS; i++) {
        if ((Inventory[i] != 0) && (!strcasecmp(DescriptionOfItem[Inventory[i]], item))) {
            /* We have it. Add to location. */
            locationOfItem[Inventory[i]] = currentLocation;
            /* And remove from inventory */
            Inventory[i] = 0;
            printf("Dropped %s.\n", item);
            ++turnsPlayed;
            return;
        }
    }
    /* If here, don't have it. */
    printf("Not carrying %s.\n", item);
}

/* Take command */
void doTake()
{
    number i, j;
    char *sp;
    char *item;

    /* Command line should be like "T[AKE] ITEM" Item name will be after after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Take what?\n");
        return;
    }

    item = sp + 1;

    if (carryingItem(item)) {
        printf("Already carrying it.\n");
        return;
    }

    /* Find number of the item. */
    for (i = 1; i <= LastItem; i++) {
        if (!strcasecmp(item, DescriptionOfItem[i])) {
            /* Found it, but is it here? */
            if (locationOfItem[i] == currentLocation) {
            /* It is here. Add to inventory. */
            for (j = 0; j < MAXITEMS; j++) {
                if (Inventory[j] == 0) {
                    Inventory[j] = i;
                    /* And remove from location. */
                    locationOfItem[i] = 0;
                    printf("Took %s.\n", item);
                    ++turnsPlayed;
                    return;
                }
            }

            /* Reached maximum number of items to carry */ 
            printf("You can't carry any more. Drop something.\n");
            return;
            }
        }
    }

    /* If here, don't see it. */
    printf("I see no %s here.\n", item);
}

/* Go command */
void doGo()
{
    char *sp;
    char dirChar;
    Direction_t dir;

    /* Command line should be like "G[O] N[ORTH]" Direction will be
       the first letter after a space. Or just a single letter
       direction N S E W U D or full directon NORTH etc. */

    sp = strrchr(buffer, ' ');
    if (sp != NULL) {
        dirChar = *(sp+1);
    } else {
        dirChar = buffer[0];
    }
    dirChar = tolower(dirChar);

    if (dirChar == 'n') {
        dir = North;
    } else if (dirChar == 's') {
        dir = South;
    } else if (dirChar == 'e') {
        dir = East;
    } else if (dirChar == 'w') {
        dir = West;
    } else if (dirChar == 'u') {
        dir = Up;
    } else if (dirChar == 'd') {
        dir = Down;
    } else {
        printf("Go where?\n");
        return;
    }

    if (Move[currentLocation][dir] == 0) {
        printf("You can't go %s from here.\n", DescriptionOfDirection[dir]);
        return;
    }

    /* We can move */
    currentLocation = Move[currentLocation][dir];
    printf("You are %s.\n", DescriptionOfLocation[currentLocation]);
    ++turnsPlayed;
}

/* Examine command */
void doExamine()
{
    char *sp;
    char *item;

    /* Command line should be like "E[XAMINE] ITEM" Item name will be after after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Examine what?\n");
        return;
    }

    item = sp + 1;
    ++turnsPlayed;

    /* Examine bookcase - not an object */
    if (!strcasecmp(item, "bookcase")) {
        printf("You pull back a book and the bookcase\nopens up to reveal a secret room.\n");
        Move[17][North] = 18;
        return;
    }

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I don't see it here.\n");
        return;
    }

    /* Examine Book */
    if (!strcasecmp(item, "book")) {
        printf("It is a very old book entitled\n\"Apple 1 operation manual\".\n");
        return;
    }

    /* Examine Flashlight */
    if (!strcasecmp(item, "flashlight")) {
        printf("It doesn't have any batteries.\n");
        return;
    }

    /* Examine toy car */
    if (!strcasecmp(item, "toy car")) {
        printf("It is a nice toy car.\nYour grandson Matthew would like it.\n");
        return;
    }

    /* Examine old radio */
    if (!strcasecmp(item, "old radio")) {
        printf("It is a 1940 Zenith 8-S-563 console\nwith an 8A02 chassis. You'd turn it on\nbut the electricity is off.\n");
        return;
    }

   /* Nothing special about this item */
   printf("You see nothing special about it.\n");
}

/* Use command */
void doUse()
{
    char *sp;
    char *item;

    /* Command line should be like "U[SE] ITEM" Item name will be after after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Use what?\n");
        return;
    }

    item = sp + 1;

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I don't see it here.\n");
        return;
    }

    ++turnsPlayed;

    /* Use key */
    if (!strcasecmp(item, "key") && (currentLocation == 0)) {
        printf("You insert the key in the door and it\nopens, revealing a tunnel.\n");
        Move[21][North] = 23;
        return;
    }

    /* Default */
    printf("Nothing happens\n");
}

/* Prompt user and get a line of input */
void prompt()
{
    printf("? ");        
    fgets(buffer, sizeof(buffer)-1, stdin);

    /* Remove trailing newline */
    buffer[strlen(buffer)-1] = '\0';
}

/* Do special things unrelated to command typed. */
void doActions()
{

}

/* Set variables to values for start of game */
void initialize()
{
    currentLocation = FrontEntrance;
    turnsPlayed = 0;
    gameOver= 0;

    /* These doors can get changed during game and may need to be reset */
    //Move[17][North] = 0;
    //Move[21][North] = 0;

    /* Set inventory to default */
    memset(Inventory, 0, sizeof(Inventory[0])*MAXITEMS);
    Inventory[0] = Key;

    /* Put items in their default locations */
    //locationOfItem[0]  = 0;                /* NoItem */
    //locationOfItem[1]  = Driveway1;        /* Key */
}

/* Main program (obviously) */
int main(void)
{
    while (1) {
        initialize();
        clearScreen();
        printf("%s", introText);

        while (!gameOver) {
            prompt();
            if (buffer[0] == '\0') {
            } else if (tolower(buffer[0]) == 'h') {
                doHelp();
            } else if (tolower(buffer[0]) == 'i') {
                doInventory();
            } else if ((tolower(buffer[0]) == 'g')
                       || !strcasecmp(buffer, "n") || !strcasecmp(buffer, "s")
                       || !strcasecmp(buffer, "e") || !strcasecmp(buffer, "w")
                       || !strcasecmp(buffer, "u") || !strcasecmp(buffer, "d")
                       || !strcasecmp(buffer, "north") || !strcasecmp(buffer, "south")
                       || !strcasecmp(buffer, "east") || !strcasecmp(buffer, "west")
                       || !strcasecmp(buffer, "up") || !strcasecmp(buffer, "down")) {
                doGo();
            } else if (tolower(buffer[0]) == 'l') {
                doLook();
            } else if (tolower(buffer[0]) == 't') {
                doTake();
            } else if (tolower(buffer[0]) == 'e') {
                doExamine();
            } else if (tolower(buffer[0]) == 'u') {
                doUse();
            } else if (tolower(buffer[0]) == 'd') {
                doDrop();
            } else if (tolower(buffer[0]) == 'q') {
                doQuit();
            } else if (!strcasecmp(buffer, "xyzzy")) {
                printf("Nice try, but that won't work here.\n");
            } else {
                printf("I don't understand. Try 'help'.\n");
            }

            /* Handle special actions. */
            doActions();
        }

        printf("Game over after %d turns.\n", turnsPlayed);
        printf("%s", "Do you want to play again (y/n)? ");
        fgets(buffer, sizeof(buffer)-1, stdin);
        if (tolower(buffer[0]) == 'n') {
            break;
        }
    }
    return 0;
}
