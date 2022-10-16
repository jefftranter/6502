/*
 *
 * Skye's Castle Adventure
 *
 * A sequel to The Abandoned Farmhouse Adventure.
 *
 * Jeff Tranter <tranter@pobox.com>
 *
 * Written in standard C but designed to run on the Apple II or other
 * platforms using the CC65 6502 assembler.
 *
 * Copyright 2012-2022 Jeff Tranter
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
 * To Do:
 *
 * Revision History:
 *
 * Version  Date         Comments
 * -------  ----         --------
 * 0.0      07 Sep 2015  Started development.
 * 0.1      16 Feb 2019  Most game logic implemented.
 * 0.9      17 Feb 2019  Seems to be fully working.
 * 0.95     18 Feb 2019  Added joystick support, better parsing of commands.
 * 0.96     28 Apr 2019  Conditionally compile joystick support.
 * 1.0      29 Jul 2022  Added backup/restore commands.
 */


/* Uncomment the next line to define JOYSTICK if you want to enable
 *  support for moving using a joystick. You need to be on a platform
 *  with joystick support in cc65.
 */
//#define JOYSTICK 1


#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __CC65__
#include <conio.h>
#ifdef JOYSTICK
#include <joystick.h>
#endif /* JOYSTICK */
#endif /* __CC65__ */

/* Uncomment the next line to define this if you want backup and
   restore commands to use files. Otherwise uses memory. Requires
   platform support for file i/o. */
//#define FILEIO 1

/* CONSTANTS */

/* Maximum number of items user can carry */
#define MAXITEMS 5

/* Number of locations */
#define NUMLOCATIONS 60

/* Number of (memory-resident) saved games */
#define SAVEGAMES 10

/* TYPES */

/* To optimize for code size and speed, most numbers are 8-bit chars when compiling for CC65. */
#ifdef __CC65__
typedef char number;
#else
typedef int number;
#endif /* __CC65__ */

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
    PoolCue,
    Umbrella,
    Newspaper,
    Sandwich,
    Cat,
    Wine,
    Knife,
    Candle,
    Matches,
    Auntie,
    Doll,
    Skye,
    SteelBar,
    Book,
    Hairbrush,
    Note,
    Perfume,
    BusinessCard,
    Soap,
    Menu,
    LightBulb,
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
    NarrowHallway,
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

/* Structure to hold entire game state */
typedef struct {
    number valid;
    Item_t Inventory[MAXITEMS];
    Location_t locationOfItem[LastItem+1];
    Direction_t Move[NUMLOCATIONS][6];
    number currentLocation;
    int turnsPlayed;
    number candleLit;
    number auntieTied;
} GameState_t;

/* TABLES */

/* Names of directions */
const char *DescriptionOfDirection[] = {
    "north", "south", "east", "west", "up", "down"
};

/* Names of items */
const char *DescriptionOfItem[LastItem+1] = {
    "",
    "pool cue",
    "umbrella",
    "newspaper",
    "sandwich",
    "cat",
    "wine",
    "knife",
    "candle",
    "matches",
    "Auntie",
    "doll",
    "Skye",
    "steel bar",
    "book",
    "hairbrush",
    "note",
    "perfume",
    "business card",
    "soap",
    "menu",
    "light bulb",
    "key"
};

/* Names of locations */
const char *DescriptionOfLocation[NUMLOCATIONS] = {
    "",
    "at the front door of the castle",
    "in the vestibule",
    "in the entry hall",
    "in Peacock Alley",
    "in Peacock Alley",
    "in Peacock Alley",
    "in Peacock Alley",
    "in Peacock Alley",
    "in the large formal dining room",
    "in a large conservatory with a stained glass dome sky light",
    "in the breakfast room",
    "in the serving room",
    "in the kitchen",
    "in a hallway",
    "in a hallway",
    "in the elevator on the main floor",
    "in a study, with a large desk and fireplace",
    "in the library",
    "in the Great Hall",
    "on the lower staircase",
    "on the landing",
    "in the oak drawing room",
    "in the smoking room",
    "on the covered porch",
    "in the billiards room",
    "at the west end of a hallway",
    "in a hallway",
    "in a hallway",
    "in a hallway",
    "at the east end of a hallway",
    "in a corridor",
    "in a corridor",
    "in a narrow hallway",
    "in the Round Room",
    "in the pipe organ loft",
    "in a large bedroom",
    "in the lady's sitting room",
    "in a small bedroom",
    "in Sir Henry's bedroom",
    "in a sitting room",
    "in Lady Pellatt's bedroom",
    "in Sir Henry's sitting room",
    "in the guest bedroom",
    "in the elevator on the second floor",
    "in the children's bedroom",
    "in the servant's bedroom",
    "in the corner bedroom",
    "in the linen room",
    "in a bedroom",
    "in the bath room",
    "on the upper staircase",
    "on a narrow staircase",
    "in the wine cellar",
    "in a damp underground tunnel",
    "in a damp underground tunnel",
    "in a damp underground tunnel",
    "in the steam plant",
    "in a damp underground tunnel",
    "in the stables",
};

/* DATA */

/* Inventory of what player is carrying */
Item_t Inventory[MAXITEMS];

/* Location of each item. Index is the item number, returns the location. 0 if item is gone */
Location_t locationOfItem[LastItem+1];

/* Map. Given a location and a direction to move, returns the location it connects to, or 0 if not a valid move. Map can change during game play. */
Location_t Move[NUMLOCATIONS][6] = {
    /* N  S  E  W  U  D */
    { NoLocation, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },           /*  0 NoLocation */
    { NoLocation, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },           /*  1 FrontEntrance */
    { Entry, FrontEntrance, NoLocation, NoLocation, NoLocation, NoLocation },             /*  2 Vestibule */
    { PeacockAlley3, Vestibule, NoLocation, NoLocation, NoLocation, NoLocation },         /*  3 Entry */
    { DiningRoom, Hallway1, PeacockAlley2, Conservatory, NoLocation, NoLocation },        /*  4 PeacockAlley1 */
    { Library, Study, PeacockAlley3, PeacockAlley1, NoLocation, NoLocation },             /*  5 PeacockAlley2 */
    { NoLocation, Entry, PeacockAlley4, PeacockAlley2, NoLocation, NoLocation },          /*  6 PeacockAlley3 */
    { GreatHall, NoLocation, PeacockAlley5, PeacockAlley3, Stairs1, NoLocation },         /*  7 PeacockAlley4 */
    { OakDrawingRoom, SmokingRoom, NoLocation, PeacockAlley4, NoLocation, NoLocation },   /*  8 PeacockAlley5 */
    { NoLocation, PeacockAlley1, NoLocation, NoLocation, NoLocation, NoLocation },        /*  9 DiningRoom */
    { NoLocation, NoLocation, PeacockAlley1, NoLocation, NoLocation, NoLocation },        /* 10 Conservatory */
    { NoLocation, ServingRoom, Hallway1, NoLocation, NoLocation, NoLocation },            /* 11 BreakfastRoom */
    { BreakfastRoom, Kitchen, Hallway2, NoLocation, NoLocation, NoLocation },             /* 12 ServingRoom */
    { ServingRoom, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },          /* 13 Kitchen */
    { PeacockAlley1, Hallway2, Elevator1, BreakfastRoom, NoLocation, NoLocation },        /* 14 Hallway1 */
    { Hallway1, NoLocation, NoLocation, ServingRoom, NoLocation, NoLocation },            /* 15 Hallway2 */
    { NoLocation, NoLocation, NoLocation, Hallway1, Elevator2, NoLocation },              /* 16 Elevator1 */
    { PeacockAlley2, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },        /* 17 Study */
    { CoveredPorch, PeacockAlley2, GreatHall, NoLocation, NoLocation, NoLocation },       /* 18 Library */
    { NoLocation, PeacockAlley4, OakDrawingRoom, Library, NoLocation, NoLocation },       /* 19 GreatHall */
    { PeacockAlley4, NoLocation, NoLocation, NoLocation, Landing, NoLocation },           /* 20 Stairs1 */
    { NoLocation, NoLocation, NoLocation, NoLocation, Stairs2, Stairs1 },                 /* 21 Landing */
    { NoLocation, PeacockAlley5, NoLocation, GreatHall, NoLocation, NoLocation },         /* 22 OakDrawingRoom */
    { PeacockAlley5, BilliardsRoom, NoLocation, NoLocation, NoLocation, NoLocation },     /* 23 SmokingRoom */
    { NoLocation, Library, NoLocation, NoLocation, NoLocation, NoLocation },              /* 24 CoveredPorch */
    { SmokingRoom, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },          /* 25 BilliardsRoom */
    { LadysBedroom, Corridor1, Hallway1, NoLocation, NoLocation, NoLocation },            /* 26 Hallway10 */
    { SittingRoom2, LinenRoom, Hallway12, Hallway10, NoLocation, NoLocation },            /* 27 Hallway11 */
    { SirHenrysBedroom, Bedroom1, Hallway13, Hallway11, NoLocation, NoLocation },         /* 28 Hallway12 */
    { NoLocation, NoLocation, Hallway14, Hallway12, NoLocation, Stairs2 },                /* 29 Hallway13 */
    { NarrowHallway, Bedroom2, NoLocation, Hallway13, NoLocation, NoLocation },           /* 30 Hallway14 */
    { Hallway10, Corridor2, Bedroom3, GuestBedroom, NoLocation, NoLocation },             /* 31 Corridor1 */
    { Corridor1, NoLocation, ServantsBedroom, ChildrensBedroom, NoLocation, NoLocation }, /* 32 Corridor2 */
    { Bedroom4, Hallway14, RoundRoom, PipeOrganLoft, NoLocation, NoLocation },            /* 33 NarrowHallway */
    { NoLocation, NoLocation, NoLocation, NarrowHallway, NoLocation, NoLocation },        /* 34 RoundRoom */
    { NoLocation, NoLocation, NarrowHallway, NoLocation, NoLocation, NoLocation },        /* 35 PipeOrganLoft */
    { Hallway12, Bath, NoLocation, NoLocation, NoLocation, NoLocation },                  /* 36 Bedroom1 */
    { NoLocation, LadysBedroom, NoLocation, NoLocation, NoLocation, NoLocation },         /* 37 SittingRoom1 */
    { NoLocation, NoLocation, NoLocation, Corridor1, NoLocation, NoLocation },            /* 38 Bedroom3 */
    { NoLocation, Hallway12, NoLocation, SittingRoom2, NoLocation, NoLocation },          /* 39 SirHenrysBedroom */
    { NoLocation, NoLocation, Bedroom4, NoLocation, NoLocation, NoLocation },             /* 40 SittingRoom3 */
    { SittingRoom1, Hallway10, NoLocation, NoLocation, NoLocation, NoLocation },          /* 41 LadysBedroom */
    { NoLocation, Hallway11, SirHenrysBedroom, NoLocation, NoLocation, NoLocation },      /* 42 SittingRoom2 */
    { NoLocation, NoLocation, Corridor1, NoLocation, NoLocation, NoLocation },            /* 43 GuestBedroom */
    { NoLocation, NoLocation, LinenRoom, NoLocation, NoLocation, Elevator1 },             /* 44 Elevator2 */
    { NoLocation, NoLocation, Corridor2, NoLocation, NoLocation, NoLocation },            /* 45 ChildrensBedroom */
    { NoLocation, NoLocation, NoLocation, Corridor2, NoLocation, NoLocation },            /* 46 ServantsBedroom */
    { NoLocation, NarrowHallway, NoLocation, SittingRoom3, NoLocation, NoLocation },      /* 47 Bedroom4 */
    { Hallway11, NoLocation, NoLocation, Elevator2, NoLocation, NoLocation },             /* 48 LinenRoom */
    { Hallway14, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },            /* 49 Bedroom2 */
    { Bedroom1,  NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },            /* 50 Bath */
    { NoLocation, NoLocation, NoLocation, NoLocation, Hallway13, Landing },               /* 51 Stairs2 */
    { NoLocation, NoLocation, NoLocation, NoLocation, Study, Tunnel1 },                   /* 52 Stairs3 */
    { Tunnel1, NoLocation, NoLocation, NoLocation, NoLocation, NoLocation },              /* 53 WineCellar */
    { NoLocation, WineCellar, Tunnel2, NoLocation, Stairs3, NoLocation },                 /* 54 Tunnel1 */
    { NoLocation, NoLocation, Tunnel3, Tunnel1, NoLocation, NoLocation },                 /* 55 Tunnel2 */
    { SteamPlant, NoLocation, Tunnel4, Tunnel2, NoLocation, NoLocation },                 /* 56 Tunnel3 */
    { NoLocation, Tunnel3, NoLocation, NoLocation, NoLocation, NoLocation },              /* 57 SteamPlant */
    { NoLocation, NoLocation, NoLocation, Tunnel3, Stables, NoLocation },                 /* 58 Tunnel4 */
    { NoLocation, NoLocation, NoLocation, NoLocation, NoLocation, Tunnel4 },              /* 59 Stables */

};

/* Current location */
Location_t currentLocation;

/* Number of turns played in game */
int turnsPlayed;

/* True if player has lit the candle. */
number candleLit;

/* True if Auntie is tied up. */
number auntieTied;

/* Set when game is over */
number gameOver;

#ifndef FILEIO
/* Memory-resident saved games */
GameState_t savedGame[SAVEGAMES];
#endif

const char *introText =
"       Skye's Castle Adventure\n"
"           By Jeff Tranter\n\n"
"Your great-great-grandfather built a\n"
"castle, but the family fell on hard\n"
"times and it has been vacant for 80\n"
"years. Occasionally, family members\n"
"visit the castle, although it is old\n"
"and dusty and possibly not safe. Today\n"
"your young granddaughter went to\n"
"visit the castle with her aunt, but\n"
"they did not return in the evening.\n"
"Maybe you should have called the\n"
"police, but instead you decide to go\n"
"over there and find them on your own.\n"
"It looks like a bad storm is brewing,\n"
"and the castle has no electricity, so\n"
"you had better find them before it gets\n"
"too dark.\n";

#ifdef FILEIO
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down \nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <file>\nrestore <file>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#else
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down \nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <number>\nrestore <number>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#endif

/* Line of user input */
char buffer[40];

/*
 * Check if string str starts with command or abbreviated command cmd, e.g
 * "h", "he", "hel", or "help" matches "help". Not case sensitive. Ends
 * comparison when str contains space, end of string, or end of cmd reached.
 * Return 1 for match, 0 for non-match.
 */
number matchesCommand(const char *cmd, const char *str)
{
    unsigned int i;

    /* Make sure that at least the first character matches. */
    if (cmd[0] == '\0' || str[0] == '\0' || cmd[0] == ' ' || str[0] == ' ' || tolower(str[0]) != tolower(cmd[0])) {
        return 0; /* no match */
    }

    /* Now check rest of strings. */
    for (i = 1; i < strlen(cmd); i++) {
        if (cmd[i] == '\0' || str[i] == '\0' || cmd[i] == ' ' || str[i] == ' ') {
            return 1; /* A match */
        }
        if (tolower(str[i]) != tolower(cmd[i])) {
            return 0; /* Not a match */
        }
    }

    return 1; /* A match */
}

/* Clear the screen */
void clearScreen()
{
#if defined(__CC65__)
    clrscr();
#else
    number i;
    for (i = 0; i < 24; ++i)
        printf("\n");
#endif /* __CC65__ */
}

/* Return 1 if carrying an item */
number carryingItem(const char *item)
{
    number i;

    for (i = 0; i < MAXITEMS; i++) {
        if ((Inventory[i] != 0) && (!strcasecmp(DescriptionOfItem[Inventory[i]], item)))
            return 1;
    }
    return 0;
}

/* Return 1 if item is at current location (not carried) */
number itemIsHere(const char *item)
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

    if ((turnsPlayed > 20) && !candleLit) {
        printf("It is dark. You can't see.\n");
    } else {
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
    }

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
    fflush(NULL);
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

    /* Command line should be like "D[ROP] ITEM" Item name will be after first space. */
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
            Inventory[i] = (Item_t)0;
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

    /* Command line should be like "T[AKE] ITEM" Item name will be after first space. */
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
                    Inventory[j] = (Item_t)i;
                    /* And remove from location. */
                    locationOfItem[i] = NoLocation;
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

    /* Special case: can't leave castle until you have Auntie, Skye,
       cat, and doll. */
    if ((currentLocation == Vestibule) && (dir == South)) {
        if (!carryingItem("Skye") && !itemIsHere("Skye")) {
            printf("You can't leave without Skye!\n");
            return;
        }
        if (!carryingItem("Auntie") && !itemIsHere("Auntie")) {
            printf("You can't leave without Auntie!\n");
            return;
        }
        if (!carryingItem("cat") && !itemIsHere("cat")) {
            printf("Skye won't leave without her cat, Bailey!\n");
            return;
        }
        if (!carryingItem("doll") && !itemIsHere("doll")) {
            printf("Skye won't leave without her doll!\n");
            return;
        }
        /* You won! */
        printf("Congratulations, you won the game!\nI hope you had as much fun playing\nthe game as I did creating it.\nJeff Tranter <tranter@pobox.com>\n");
        gameOver = 1;
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

    /* Command line should be like "E[XAMINE] ITEM" Item name will be after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Examine what?\n");
        return;
    }

    item = sp + 1;
    ++turnsPlayed;

    /* Examine fireplace - not an object */
    if (!strcasecmp(item, "fireplace") && (currentLocation == Study)) {
        printf("On either side of the fireplace are\nsecret panels, which now open and\nreveal staircases.\n");
        Move[Study][Up] = Hallway11;
        Move[Study][Down] = Stairs3;
        return;
    }

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I don't see it here.\n");
        return;
    }

    /* Examine Newspaper */
    if (!strcasecmp(item, "newspaper")) {
        printf("It reads:\n"
               "\"Pellatt's Folly? Five million dollar \"house on the hill\" took\n"
               "three years to build. Sole occupants of 98 room castle are Toronto\n"
               "financier and invalid wife.\"\n");
        return;
    }

    /* Examine Sandwich */
    if (!strcasecmp(item, "sandwich")) {
        printf("A peanut butter sandwich. It looks\nfresh, so someone must have been here\nrecently.\n");
        return;
    }

    /* Examine Cat */
    if (!strcasecmp(item, "cat")) {
        printf("It is Skye's cat, Bailey. How did he get here?\n");
        return;
    }

    /* Examine Wine */
    if (!strcasecmp(item, "wine")) {
        printf("An old bottle of wine. It looks very dusty and dirty.\n");
        return;
    }

    /* Examine Auntie */
    if (!strcasecmp(item, "auntie")) {
        if (auntieTied) {
            printf("She is tied up and gagged and can't speak.\nBut where is Skye?\n");
        } else {
            printf("Auntie says: Someone attacked me and\ntied me up! Skye went back into the\ntunnel to get help.\n");
        }
        return;
    }

    /* Examine doll */
    if (!strcasecmp(item, "doll")) {
        printf("It is a doll. It looks like one that belongs to Skye.\n");
        return;
    }

    /* Examine book */
    if (!strcasecmp(item, "book")) {
        printf("It is titled \"The Curse of the Pharaohs\"\nby George Crabtree.\n");
        return;
    }

    /* Examine note */
    if (!strcasecmp(item, "note")) {
        printf("It says: \"Reginald was here.\"\n");
        return;
    }

    /* Examine business card */
    if (!strcasecmp(item, "business card")) {
        printf("It reads: \"Thomas Ridgway - chauffeur\"\n");
        return;
    }

    /* Examine menu */
    if (!strcasecmp(item, "menu")) {
        printf("It reads:\n"
               "First Course\n"
               "Hors D'Oeuvres\n"
               "Oysters\n"
               "\n"
               "Second Course\n"
               "Consomme Olga\n"
               "Cream of Barley\n"
               "\n"
               "Third Course\n"
               "Poached Salmon with Mousseline Sauce, Cucumbers\n"
               "\n"
               "Fourth Course\n"
               "Filet Mignons Lili\n"
               "Saute of Chicken, Lyonnaise\n"
               "Vegetable Marrow Farci\n"
               "\n"
               "Fifth Course\n"
               "Lamb, Mint Sauce\n"
               "Roast Duckling, Apple Sauce\n"
               "Sirloin of Beef, Chateau Potatoes\n"
               "Green Pea\n"
               "Creamed Carrots\n"
               "Boiled Rice\n"
               "Parmentier & Boiled New Potatoes\n"
               "\n"
               "Sixth Course\n"
               "Punch Romaine\n"
               "\n"
               "Seventh Course\n"
               "Roast Squab & Cress\n"
               "\n"
               "Eighth Course\n"
               "Cold Asparagus Vinaigrette\n"
               "\n"
               "Ninth Course\n"
               "Pate de Foie Gras\n"
               "Celery\n"
               "\n"
               "Tenth Course\n"
               "Waldorf Pudding\n"
               "Peaches in Chartreuse Jelly\n"
               "Chocolate & Vanilla Eclairs\n"
               "French Ice Cream\n");
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

    /* Command line should be like "U[SE] ITEM" Item name will be after first space. */
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
    if (!strcasecmp(item, "key") && (currentLocation == FrontEntrance)) {
        printf("You insert the key and unlock the door.\n");
        Move[FrontEntrance][North] = Vestibule;
        return;
    }

    /* Use (drink) wine. */
    if (!strcasecmp(item, "wine")) {
        printf("It looks and smells bad, but you drink some anyway.\n");
        printf("You feel very sick and pass out.\n");
        gameOver = 1;
        return;
    }

    /* Use knife */
    if (!strcasecmp(item, "knife")) {
        if ((carryingItem("auntie") || itemIsHere("auntie")) && (auntieTied == 1)) {
            printf("You cut the ropes with the knife.\n");
            printf("Auntie says: Someone attacked me and tied me up!\nSkye went back into the tunnel to get help.\n");
            auntieTied = 0;
            return;
        }
    }

    /* Use matches to light candle */
    if (!strcasecmp(item, "matches")) {
        if (carryingItem("candle") || itemIsHere("candle")) {
            printf("You light the candle. You can see!\n");
            candleLit = 1;
            return;
        } else {
            printf("Nothing here to light\n");
        }
    }

    /* Use steel bar to get Skye out of steam boiler */
    if (!strcasecmp(item, "steel bar") && (currentLocation == SteamPlant)) {
        if (locationOfItem[Skye] == 0) {
            printf("You pry the boiler open with the steel bar.\nSkye was trapped inside! She is safe now.\n");
            /* Skye is now in steam plant. */
            locationOfItem[Skye] = SteamPlant;
            return;
        }
    }

    /* Default */
    printf("Nothing happens\n");
}

#ifdef FILEIO
/* Backup command - file version */
void doBackup()
{
    char *sp;
    char *name;
    number i, j;
    FILE *fp;

    /* Command line should be like "B[ACKUP] NAME" */
    /* Save file name will be after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Backup under what name?\n");
        return;
    }

    name = sp + 1;

    printf("Backing up game state under name '%s'.\n", name);

    fp = fopen(name, "w");
    if (fp == NULL) {
        printf("Unable to open file '%s'.\n", name);
        return;
    }

    fprintf(fp, "%s\n", "#Adventure2 Save File");

    fprintf(fp, "Inventory:");
    for (i = 0; i < MAXITEMS; i++) {
        fprintf(fp, " %d", Inventory[i]);
    }
    fprintf(fp, "\n");

    fprintf(fp, "Items:");
    for (i = 0; i <= LastItem; i++) {
        fprintf(fp, " %d", locationOfItem[i]);
    }
    fprintf(fp, "\n");

    fprintf(fp, "Map:\n");
    for (i = 0; i < NUMLOCATIONS; i++) {
        for (j = 0; j < 6; j++) {
            fprintf(fp, " %d", Move[i][j]);
        }
        fprintf(fp, "\n");
    }

    fprintf(fp, "Variables: %d %d %d %d\n",
           currentLocation,
           turnsPlayed,
           candleLit,
           auntieTied);

    i = fclose(fp);
    if (i != 0) {
        printf("Unable to close file, error code %d.\n", i);
    }
}
#else
/* Backup command - memory-resident version */
void doBackup()
{
    char *sp;
    number i, j, n;

    /* Command line should be like "B[ACKUP] <NUMBER>" */
    /* Number will be after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Backup under what number?\n");
        return;
    }

    n = strtol(sp + 1, NULL, 10);
    if  (n <= 0 || n > SAVEGAMES) {
        printf("Invalid backup number. Specify %d through %d.\n", 1, SAVEGAMES);
        return;
    }

    printf("Backing up game state under number %d.\n", n);

    savedGame[n-1].valid = 1;
    for (i = 0; i < MAXITEMS; i++) {
        savedGame[n-1].Inventory[i] = Inventory[i];
    }
    for (i = 0; i < LastItem+1; i++) {
        savedGame[n-1].locationOfItem[i] = locationOfItem[i];
    }
    for (i = 0; i < NUMLOCATIONS; i++) {
        for (j = 0; j < 6; j++) {
            savedGame[n-1].Move[i][j] = Move[i][j];
        }
    }
    savedGame[n-1].currentLocation = currentLocation;
    savedGame[n-1].turnsPlayed = turnsPlayed;
    savedGame[n-1].candleLit = candleLit;
    savedGame[n-1].auntieTied = auntieTied;
}

#endif /* FILEIO */

#ifdef FILEIO
/* Restore command - file version */
void doRestore()
{
    char *sp;
    char *name;
    number i, j;
    FILE *fp;

    /* Command line should be like "R[ESTORE] NAME" */
    /* Save file name will be after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Restore from what file?\n");
        return;
    }

    name = sp + 1;

    printf("Restoring game state from file '%s'.\n", name);

    fp = fopen(name, "r");
    if (fp == NULL) {
        printf("Unable to open file '%s'.\n", name);
        return;
    }

    /* Check for header line */
    fgets(buffer, sizeof(buffer) - 1, fp);
    if (strcmp(buffer, "#Adventure2 Save File\n")) {
        printf("File is not a valid game file.\n");
        fclose(fp);
        return;
    }

    /* Inventory: 3 0 0 0 0 */
    i = fscanf(fp, "Inventory: %d %d %d %d %d\n",
           (int*) &Inventory[0],
           (int*) &Inventory[1],
           (int*) &Inventory[2],
           (int*) &Inventory[3],
           (int*) &Inventory[4]);
    if (i != 5) {
        printf("File is not a valid game file.\n");
        fclose(fp);
        return;
    }

    /* Items: 0 1 8 0 7 6 9 2 16 15 18 25 29 10 12 19 */
    i = fscanf(fp, "Items: %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
           (int*) &locationOfItem[0],
           (int*) &locationOfItem[1],
           (int*) &locationOfItem[2],
           (int*) &locationOfItem[3],
           (int*) &locationOfItem[4],
           (int*) &locationOfItem[5],
           (int*) &locationOfItem[6],
           (int*) &locationOfItem[7],
           (int*) &locationOfItem[8],
           (int*) &locationOfItem[9],
           (int*) &locationOfItem[10],
           (int*) &locationOfItem[11],
           (int*) &locationOfItem[12],
           (int*) &locationOfItem[13],
           (int*) &locationOfItem[14],
           (int*) &locationOfItem[15],
           (int*) &locationOfItem[16],
           (int*) &locationOfItem[17],
           (int*) &locationOfItem[18],
           (int*) &locationOfItem[19],
           (int*) &locationOfItem[20],
           (int*) &locationOfItem[21],
           (int*) &locationOfItem[22]);

    if (i != 23) {
        printf("File is not a valid game file.\n");
        fclose(fp);
        return;
    }

    fscanf(fp, "Map:\n");

    for (i = 0; i < NUMLOCATIONS; i++) {
        j = fscanf(fp, " %d %d %d %d %d %d\n",
               (int*) &Move[i][0],
               (int*) &Move[i][1],
               (int*) &Move[i][2],
               (int*) &Move[i][3],
               (int*) &Move[i][4],
               (int*) &Move[i][5]);
        if (j != 6) {
            printf("File is not a valid game file.\n");
            fclose(fp);
            return;
        }
    }

    /* Variables: 1 0 0 0 */
    i = fscanf(fp, "Variables: %d %d %d %d\n",
               (int *) &currentLocation,
               &turnsPlayed,
               &candleLit,
               &auntieTied);

    if (i != 4) {
        printf("File is not a valid game file.\n");
        fclose(fp);
        return;
    }

    i = fclose(fp);
    if (i != 0) {
        printf("Unable to close file, error code %d.\n", i);
    }
}
#else
/* Restore command - memory-resident version */
void doRestore()
{
    char *sp;
    number i, j, n;

    /* Command line should be like "R[ESTORE] <NUMBER>" */
    /* Number will be after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("Restore from what number?\n");
        return;
    }

    n = strtol(sp + 1, NULL, 10);
    if  (n <= 0 || n > SAVEGAMES) {
        printf("Invalid restore number. Specify %d through %d.\n", 1, SAVEGAMES);
        return;
    }

    if (savedGame[n-1].valid != 1) {
        printf("No game has been stored for number %d.\n", n);
        printf("Stored games:");
        for (i = 0; i < SAVEGAMES; i++) {
            if (savedGame[i].valid == 1) {
                printf(" %d", i+1);
            }
        }
        printf("\n");
        return;
    }

    printf("Restoring game state from number %d.\n", n);

    savedGame[n-1].valid = 1;
    for (i = 0; i < MAXITEMS; i++) {
        Inventory[i] = savedGame[n-1].Inventory[i];
    }
    for (i = 0; i < LastItem+1; i++) {
        locationOfItem[i] = savedGame[n-1].locationOfItem[i];
    }
    for (i = 0; i < NUMLOCATIONS; i++) {
        for (j = 0; j < 6; j++) {
            Move[i][j] = savedGame[n-1].Move[i][j];
        }
    }
    currentLocation = savedGame[n-1].currentLocation;
    turnsPlayed = savedGame[n-1].turnsPlayed;
    candleLit = savedGame[n-1].candleLit;
    auntieTied = savedGame[n-1].auntieTied;
}
#endif /* FILEIO */

/* Prompt user and get a line of input */
void prompt()
{
#ifdef __CC65__
#ifdef JOYSTICK
    unsigned char joy;
#endif /* JOYSTICK */
#endif /* __CC65__ */

    printf("\n? ");

#ifdef __CC65__
    while (1) {
        if (kbhit()) {
            fgets(buffer, sizeof(buffer)-1, stdin); /* Get keyboard input */
            buffer[strlen(buffer)-1] = '\0'; /* Remove trailing newline */
            break;
#ifdef JOYSTICK
        } else {
            /* Check for joystick input */
            joy = joy_read(1);
            if (joy == JOY_UP_MASK) {
                strcpy(buffer, "n");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            } else if (joy == JOY_DOWN_MASK) {
                strcpy(buffer, "s");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            } else if (joy == JOY_RIGHT_MASK) {
                strcpy(buffer, "e");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            } else if (joy == JOY_LEFT_MASK) {
                strcpy(buffer, "w");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            } else if (joy == (JOY_UP_MASK|JOY_BTN_1_MASK)) {
                strcpy(buffer, "u");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            } else if (joy == (JOY_DOWN_MASK|JOY_BTN_1_MASK)) {
                strcpy(buffer, "d");
                while (joy_read(1) != 0)
                    ; /* Wait for joystick to be released */
                break;
            }
#endif /* JOYSTICK */
        }
    }
#else
    /* Get keyboard input */
    fflush(NULL);
    fgets(buffer, sizeof(buffer)-1, stdin);

    /* Remove trailing newline */
    buffer[strlen(buffer)-1] = '\0';
#endif /* __CC65__ */
}

/* Do special things unrelated to command typed. */
void doActions()
{
    /* Check for getting dark. */
    if ((turnsPlayed == 10) && !candleLit) {
        printf("It will be getting dark soon. You need\nsome kind of light or soon you won't\nbe able to see.\n");
    }

    /* Check if it got dark before you lit the candle. */
    if ((turnsPlayed == 20) && !candleLit) {
        printf("It is dark out and you have no light.\nYou stumble around for a while and\nthen fall, hit your head, and pass out.\n");
        gameOver = 1;
        return;
    }

    /* Once lit, blow out candle every 15 turns. */
    if ((turnsPlayed % 15 == 0) && candleLit) {
        printf("The candle blows out!\n");
        candleLit = 0;
    }

    /* Give hint if in steam plant */
    if ((currentLocation == SteamPlant) && (auntieTied == 0) && (locationOfItem[Skye] == 0) && !carryingItem("Skye")) {
        printf("You see a steam boiler here. You can hear someone crying inside.\n");
    }
}

/* Set variables to values for start of game */
void initialize()
{
    currentLocation = FrontEntrance;
    turnsPlayed = 0;
    gameOver = 0;
    candleLit = 0;
    auntieTied = 1;

    /* These doors can get changed during game and may need to be reset */
    Move[FrontEntrance][North] = NoLocation;
    Move[Study][Up] = NoLocation;
    Move[Study][Down] = NoLocation;

    /* Set inventory to default */
    memset(Inventory, 0, sizeof(Inventory[0])*MAXITEMS);
    Inventory[0] = Key;

    /* Put items in their default locations */
    locationOfItem[0]            = NoLocation;
    locationOfItem[PoolCue]      = BilliardsRoom;
    locationOfItem[Umbrella]     = Vestibule;
    locationOfItem[Newspaper]    = Library;
    locationOfItem[Sandwich]     = Study;
    locationOfItem[Cat]          = PipeOrganLoft;
    locationOfItem[Wine]         = WineCellar;
    locationOfItem[Knife]        = Kitchen;
    locationOfItem[Candle]       = GreatHall;
    locationOfItem[Matches]      = SmokingRoom;
    locationOfItem[Auntie]       = Stables;
    locationOfItem[Doll]         = ChildrensBedroom;
    locationOfItem[SteelBar]     = Conservatory;
    locationOfItem[Skye]         = NoLocation; /* Added later */
    locationOfItem[Book]         = SirHenrysBedroom;
    locationOfItem[Hairbrush]    = SittingRoom3;
    locationOfItem[Note]         = Bedroom2;
    locationOfItem[Perfume]      = LadysBedroom;
    locationOfItem[BusinessCard] = ServantsBedroom;
    locationOfItem[Soap]         = Bath;
    locationOfItem[Menu]         = DiningRoom;
    locationOfItem[LightBulb]    = OakDrawingRoom;
}

/* Main program (obviously) */
int main(void)
{

#ifdef __CC65__
#ifdef JOYSTICK
    unsigned char Res;
    Res = joy_load_driver(joy_stddrv);
    Res = joy_install(joy_static_stddrv);
#endif /* JOYSTICK */
#endif /* __CC65__ */

#ifndef FILEIO
    /* Mark all saved games as initially invalid */
    int i;
    for (i = 0; i < SAVEGAMES; i++) {
        savedGame[i].valid = 0;
    }
#endif

    while (1) {
        initialize();
        clearScreen();
        printf("%s", introText);
        while (!gameOver) {
            prompt();
            if (buffer[0] == '\0') {
                /* Ignore empty line */
            } else if (matchesCommand("help", buffer)) {
                doHelp();
            } else if (matchesCommand("inventory", buffer)) {
                doInventory();
            } else if (matchesCommand("go", buffer)
                       || !strcasecmp(buffer, "n") || !strcasecmp(buffer, "s")
                       || !strcasecmp(buffer, "e") || !strcasecmp(buffer, "w")
                       || !strcasecmp(buffer, "u") || !strcasecmp(buffer, "d")
                       || !strcasecmp(buffer, "north") || !strcasecmp(buffer, "south")
                       || !strcasecmp(buffer, "east") || !strcasecmp(buffer, "west")
                       || !strcasecmp(buffer, "up") || !strcasecmp(buffer, "down")) {
                doGo();
            } else if (matchesCommand("look", buffer)) {
                doLook();
            } else if (matchesCommand("take", buffer)) {
                doTake();
            } else if (matchesCommand("examine", buffer)) {
                doExamine();
            } else if (matchesCommand("use", buffer)) {
                doUse();
            } else if (matchesCommand("drop", buffer)) {
                doDrop();
            } else if (tolower(buffer[0]) == 'b') {
                doBackup();
            } else if (tolower(buffer[0]) == 'r') {
                doRestore();
            } else if (matchesCommand("quit", buffer)) {
                doQuit();
            } else {
                printf("I don't understand. Try 'help'.\n");
            }

            /* Handle special actions. */
            doActions();
        }

        printf("Game over after %d turns.\n", turnsPlayed);
        printf("%s", "Do you want to play again (y/n)? ");
        fflush(NULL);
        fgets(buffer, sizeof(buffer)-1, stdin);
        if (tolower(buffer[0]) == 'n') {
            break;
        }
    }
    return 0;
}
