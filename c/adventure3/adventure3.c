/*
 *
 * James' The Prisoner Adventure
 *
 * A sequel to The Abandoned Farmhouse and Sky's Castle Adventures.
 *
 * Dedicated to my grandson James Tranter who was 19 months old when I
 * wrote this.
 *
 * Jeff Tranter <tranter@pobox.com>
 *
 * Written in standard C but designed to run on the Apple II or other
 * platforms using the CC65 6502 assembler.
 *
 * Copyright 2012-2023 Jeff Tranter
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
 * 0.0      30 Dec 2022  Started development.
 * 0.1      01 Jan 2023  First working version.
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

/* Define FILEIO if you want backup and restore commands to use files.
 * Otherwise uses memory. Requires platform support for file i/o
 * (known to work on Apple 2 and Commodore 64 with cc65 as well as
 * Linux.
 */

#if defined(__linux__) || defined(__APPLE2ENH__) || defined(__C64__)
#define FILEIO 1
#endif

/* CONSTANTS */

/* Maximum number of items user can carry */
#define MAXITEMS 5

/* Number of locations */
#define NUMLOCATIONS 56

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
    No2Badge,
    No6Badge,
    RemoteControl,
    Pass,
    Seal,
    Transmitter,
    Helicopter,
    Diary,
    Dispenser,
    Telephone,
    Newspaper,
    Tapes,
    Can,
    Wristwatch,
    Map,
    Breakfast,
    Raft,
    Cookies,
    Cigarettes,
    Bike,
    Umbrella,
    LavaLamp,
    Teacup,
    Cards,
    ChessSet,
    Record,
    Note,
    MiniMoke,
    Bust,
    Credits,
    LastItem=Credits
} Item_t;

/* Locations */
typedef enum {
    NoLocation,
    BandStand,
    Cafe,
    Caves,
    ChessLawn,
    CitizensAdviceBureau,
    Cliffs,
    ControlRoom,
    FreeSea,
    GeneralStores,
    Graveyard,
    Hospital,
    LabourExchange,
    Lawn,
    Lighthouse,
    No6Private,
    OldPeoplesHome,
    PalaceOfFun,
    PhoneBox,
    RecreationHall,
    Shop,
    StoneShip,
    TaxiRank,
    TheBeach1,
    TheBeach2,
    TheBeach3,
    TheGreenDome,
    TheMountains1,
    TheMountains2,
    TheMountains3,
    TheMountains4,
    TheMountains5,
    TheMountains6,
    TheMountains7,
    TheMountains8,
    TheMountains9,
    TheMountains10,
    TheMountains11,
    TheMountains12,
    TheMountains13,
    TheMountains14,
    TheMountains15,
    TheMountains16,
    TheSea1,
    TheSea2,
    TheSea3,
    TheSea4,
    TheSea5,
    TheSea6,
    TheWoods1,
    TheWoods2,
    TheWoods3,
    TheWoods4,
    TopOfTower,
    Tower,
    TownHall,
} Location_t;

/* Structure to hold entire game state */
typedef struct {
    number valid;
    Item_t Inventory[MAXITEMS];
    Location_t locationOfItem[LastItem+1];
    Direction_t Move[NUMLOCATIONS][6];
    number currentLocation;
    int turnsPlayed;
    number doorOpen;
    number bombExploded;
    number helicopterHere;
} GameState_t;

/* TABLES */

/* Names of directions */
const char *DescriptionOfDirection[] = {
    "north", "south", "east", "west", "up", "down"
};

/* Names of items */
const char *DescriptionOfItem[LastItem+1] = {
    "",
    "#2 badge",
    "#6 badge",
    "remote control",
    "pass",
    "seal",
    "transmitter",
    "helicopter",
    "diary",
    "dispenser",
    "telephone",
    "newspaper",
    "tapes",
    "can",
    "wristwatch",
    "map",
    "breakfast",
    "raft",
    "cookies",
    "cigarettes",
    "bike",
    "umbrella",
    "lava lamp",
    "teacup",
    "cards",
    "chess set",
    "record",
    "note",
    "mini moke",
    "bust",
    "credits",
};

/* Names of locations */
const char *DescriptionOfLocation[NUMLOCATIONS] = {
    "",
    "at the band stand",
    "at the cafe",
    "at the caves",
    "on the chess lawn",
    "in the Citizen's Advice Bureau",
    "at the cliffs",
    "in the control room",
    "at the free sea",
    "in the general stores",
    "at the graveyard",
    "in the hospital",
    "at the labour exchange",
    "on the lawn next to the helicopter pad",
    "at the lighthouse",
    "at No. 6 Private",
    "at the old peoples's home",
    "at the palace of fun",
    "at the phone box",
    "in the recreation hall",
    "in the shop",
    "at the stone ship",
    "at the taxi rank",
    "at the beach",
    "at the beach",
    "at the beach",
    "in the green dome",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "in the mountains",
    "at the sea",
    "at the sea",
    "at the sea",
    "at the sea",
    "at the sea",
    "at the sea",
    "in the woods",
    "in the woods",
    "in the woods",
    "in the woods",
    "at the top of the tower",
    "at the tower",
    "in the town hall"
};

/* DATA */

/* Inventory of what player is carrying */
Item_t Inventory[MAXITEMS];

/* Location of each item. Index is the item number, returns the location. 0 if item is gone */
Location_t locationOfItem[LastItem+1];

/* Map. Given a location and a direction to move, returns the location it connects to, or 0 if not a valid move. Map can change during game play. */
Location_t Move[NUMLOCATIONS][6] = {
    /* N  S  E  W  U  D */
    { NoLocation,           NoLocation,           NoLocation,           NoLocation,           NoLocation, NoLocation }, /*  0  NoLocation */
    { TheGreenDome,         GeneralStores,        CitizensAdviceBureau, ChessLawn,            NoLocation, NoLocation }, /*  1  BandStand */
    { TheMountains4,        FreeSea,              LabourExchange,       Shop,                 NoLocation, NoLocation }, /*  2  Cafe */
    { Cliffs,               TheSea5,              Graveyard,            TheMountains16,       NoLocation, NoLocation }, /*  3  Caves */
    { FreeSea,              No6Private,           BandStand,            TownHall,             NoLocation, NoLocation }, /*  4  ChessLawn */
    { RecreationHall,       TheWoods3,            Hospital,             BandStand,            NoLocation, NoLocation }, /*  5  CitizensAdvicebureau */
    { TheMountains14,       Caves,                Lighthouse,           TheMountains15,       NoLocation, NoLocation }, /*  6  Cliffs */
    { NoLocation,           NoLocation,           NoLocation,           NoLocation,           TownHall,   NoLocation }, /*  7  ControlRoom */
    { Cafe,                 ChessLawn,            TheGreenDome,         TaxiRank,             NoLocation, NoLocation }, /*  8  FreeSea */
    { BandStand,            TheBeach1,            TheWoods3,            No6Private,           NoLocation, NoLocation }, /*  9  GeneralStores */
    { Lighthouse,           TheSea6,              TheSea1,              Caves,                NoLocation, NoLocation }, /*  10 Graveyard */
    { TheMountains11,       NoLocation,           TheMountains13,       CitizensAdviceBureau, NoLocation, NoLocation }, /*  11 Hospital */
    { TheMountains5,        TheGreenDome,         TheWoods2,            Cafe,                 NoLocation, NoLocation }, /*  12 LabourExchange */
    { TownHall,             StoneShip,            No6Private,           OldPeoplesHome,       NoLocation, NoLocation }, /*  13 Lawn */
    { TheWoods4,            Graveyard,            TheBeach2,            Cliffs,               NoLocation, NoLocation }, /*  14 Lighthouse */
    { NoLocation,           NoLocation,           NoLocation,           NoLocation,           NoLocation, NoLocation }, /*  15 No6Private */
    { TheMountains12,       TheWoods4,            Lawn,                 TheMountains12,       NoLocation, NoLocation }, /*  16 OldPeoplesHome */
    { PhoneBox,             TheMountains12,       TaxiRank,             TheMountains10,       NoLocation, NoLocation }, /*  17 PalaceOfFun */
    { TheMountains2,        PalaceOfFun,          Shop,                 TheWoods1,            NoLocation, NoLocation }, /*  18 PhoneBox */
    { TheWoods2,            CitizensAdviceBureau, TheMountains11,       TheGreenDome,         NoLocation, NoLocation }, /*  19 RecreationHall */
    { TheMountains3,        TaxiRank,             Cafe,                 PhoneBox,             NoLocation, NoLocation }, /*  20 Shop */
    { Lawn,                 TheBeach2,            Tower,                TheWoods4,            NoLocation, NoLocation }, /*  21 StoneShip */
    { Shop,                 TownHall,             FreeSea,              PalaceOfFun,          NoLocation, NoLocation }, /*  22 TaxiRank */
    { GeneralStores,        TheSea3,              NoLocation,           Tower,                NoLocation, NoLocation }, /*  23 TheBeach1 */
    { StoneShip,            TheSea1,              TheBeach3,            Lighthouse,           NoLocation, NoLocation }, /*  24 TheBeach2 */
    { Tower,                TheSea2,              TheSea3,              TheBeach2,            NoLocation, NoLocation }, /*  25 TheBeach3 */
    { LabourExchange,       BandStand,            RecreationHall,       FreeSea,              NoLocation, NoLocation }, /*  26 TheGreenDome */
    { NoLocation,           TheWoods1,            TheMountains2,        NoLocation,           NoLocation, NoLocation }, /*  27 TheMountains1 */
    { NoLocation,           PhoneBox,             TheMountains3,        TheMountains1,        NoLocation, NoLocation }, /*  28 TheMountains2 */
    { NoLocation,           Shop,                 TheMountains4,        TheMountains2,        NoLocation, NoLocation }, /*  29 TheMountains3 */
    { NoLocation,           Cafe,                 TheMountains5,        TheMountains3,        NoLocation, NoLocation }, /*  30 TheMountains4 */
    { NoLocation,           LabourExchange,       TheMountains6,        TheMountains4,        NoLocation, NoLocation }, /*  31 TheMountains5 */
    { NoLocation,           TheWoods2,            TheMountains7,        TheMountains5,        NoLocation, NoLocation }, /*  32 TheMountains6 */
    { NoLocation,           TheMountains9,        NoLocation,           TheMountains6,        NoLocation, NoLocation }, /*  33 TheMountains7 */
    { NoLocation,           NoLocation,           TheWoods1,            NoLocation,           NoLocation, NoLocation }, /*  34 TheMountains8 */
    { TheMountains7,        TheMountains11,       NoLocation,           TheWoods2,            NoLocation, NoLocation }, /*  35 TheMountains9 */
    { TheWoods1,            NoLocation,           PalaceOfFun,          NoLocation,           NoLocation, NoLocation }, /*  36 TheMountains10 */
    { TheMountains9,        Hospital,             NoLocation,           RecreationHall,       NoLocation, NoLocation }, /*  37 TheMountains11 */
    { NoLocation,           TheMountains14,       OldPeoplesHome,       NoLocation,           NoLocation, NoLocation }, /*  38 TheMountains12 */
    { NoLocation,           NoLocation,           NoLocation,           Hospital,             NoLocation, NoLocation }, /*  39 TheMountains13 */
    { TheMountains12,       Cliffs,               TheWoods4,            NoLocation,           NoLocation, NoLocation }, /*  40 TheMountains14 */
    { NoLocation,           TheMountains16,       Cliffs,               NoLocation,           NoLocation, NoLocation }, /*  41 TheMountains15 */
    { TheMountains15,       NoLocation,           Caves,                NoLocation,           NoLocation, NoLocation }, /*  42 TheMountains16 */
    { TheBeach2,            NoLocation,           TheSea2,              Graveyard,            NoLocation, NoLocation }, /*  43 TheSea1 */
    { TheBeach3,            NoLocation,           NoLocation,           TheSea1,              NoLocation, NoLocation }, /*  44 TheSea2 */
    { TheBeach1,            NoLocation,           TheSea4,              TheBeach3,            NoLocation, NoLocation }, /*  45 TheSea3 */
    { NoLocation,           NoLocation,           NoLocation,           TheSea3,              NoLocation, NoLocation }, /*  46 TheSea4 */
    { Caves,                NoLocation,           TheSea6,              NoLocation,           NoLocation, NoLocation }, /*  47 TheSea5 */
    { Graveyard,            NoLocation,           NoLocation,           TheSea5,              NoLocation, NoLocation }, /*  48 TheSea6 */
    { TheMountains1,        TheMountains10,       PhoneBox,             TheMountains8,        NoLocation, NoLocation }, /*  49 TheWoods1 */
    { TheMountains6,        RecreationHall,       TheMountains9,        LabourExchange,       NoLocation, NoLocation }, /*  50 TheWoods2 */
    { CitizensAdviceBureau, NoLocation,           NoLocation,           GeneralStores,        NoLocation, NoLocation }, /*  51 TheWoods3 */
    { OldPeoplesHome,       Lighthouse,           StoneShip,            TheMountains14,       NoLocation, NoLocation }, /*  52 TheWoods4 */
    { NoLocation,           NoLocation,           NoLocation,           NoLocation,           NoLocation, Tower      }, /*  53 TopOfTower */
    { No6Private,           TheBeach3,            TheBeach1,            StoneShip,            TopOfTower, NoLocation }, /*  54 Tower */
    { TaxiRank,             Lawn,                 ChessLawn,            TheMountains12,       NoLocation, NoLocation }, /*  55 TownHall */
};

/* Current location */
Location_t currentLocation;

/* Number of turns played in game */
int turnsPlayed;

/* Set when door in No.6 Private will open */
number doorOpen;

/* Set when bomb exploded and control room is accessible. */
number bombExploded;

/* Set when helicopter has been summoned and is at landing pad. */
number helicopterHere;

/* Set when game is over */
number gameOver;

#ifndef FILEIO
/* Memory-resident saved games */
GameState_t savedGame[SAVEGAMES];
#endif

const char *introText =
    "        The Prisoner Adventure\n"
    "           By Jeff Tranter\n\n"
    "A trained spy, you wake up in what\n"
    "initially appears to be your flat in\n"
    "London, but looking out the window you\n"
    "find yourself alone in a strange place\n"
    "simply known as \"the Village\".\n"
    "Can you figure out how to escape?\n";

#ifdef FILEIO
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down \nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <file>\nrestore <file>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#else
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down \nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <number>\nrestore <number>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#endif

/* Line of user input */
char buffer[80];

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

/* Check for an abbreviated item name. Return full name of item if it
   uniquely matches. Otherwise returns the orignal name. Only check
   for items being carried or at current location. */
char *getMatch(char *name)
{
    int matches = 0;
    int index = 0;
    int i;

    for (i = 1; i <= LastItem; i++) {
        if (carryingItem(DescriptionOfItem[i]) || itemIsHere(DescriptionOfItem[i])) {
            if (!strncasecmp(DescriptionOfItem[i], name, strlen(name))) {
                index = i;
                matches++;
            }
        }
    }

    if (matches == 1) {
        strcpy(name, DescriptionOfItem[index]);
    }
    return name;
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

    item = getMatch(item);

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

    item = getMatch(item);

    /* Special case - take helicopter */
    if (!strcasecmp(item, "helicopter")) {
        if (carryingItem("#2 badge")) {
            printf("The helicopter picks you up and takes\n");
            printf("you away from The Village.\n");
            printf("You have escaped!\n");
            gameOver = 1;
            return;
        } else {
            printf("The helicopter refuses to pick you up.\n");
            printf("It was summoned for #2.\n");
            return;
        }
    }

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
       direction N S E W U D or full direction NORTH etc. */

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

    /* Handle special case - can't enter town hall without a pass. */
    if (Move[currentLocation][dir] == TownHall) {
        if (carryingItem("pass")) {
            printf("You show your pass and enter Town Hall.\n");
        } else {
            printf("You can't enter Town Hall without a pass.\n");
            return;
        }
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

    item = getMatch(item);

    ++turnsPlayed;

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I don't see it here.\n");
        return;
    }

    /* Examine Note */
    if (!strcasecmp(item, "note")) {
        printf("A note which reads: \"There is a secret\n");
        printf("room under the town hall.\"\n");
        return;
    }

    /* Examine #2 badge */
    if (!strcasecmp(item, "#2 badge")) {
        printf("A badge that says \"#2.\"\n");
        return;
    }

    /* Examine #6 badge */
    if (!strcasecmp(item, "#6 badge")) {
        printf("A badge that says \"#6.\n");
        return;
    }

    /* Examine remote control */
    if (!strcasecmp(item, "remote control")) {
        printf("A remote control transmitter.\n");
        return;
    }

    /* Examine pass */
    if (!strcasecmp(item, "pass")) {
        printf("An entry pass to the town hall.\n");
        return;
    }

    /* Examine seal */
    if (!strcasecmp(item, "seal")) {
        printf("The Great Seal of Office.\n");
        printf("There is a bomb hidden inside.\n");
        return;
    }

    /* Examine transmitter */
    if (!strcasecmp(item, "transmitter")) {
        printf("A radio transmitter.");
        return;
    }

    /* Examine helicopter */
    if (!strcasecmp(item, "helicopter")) {
        printf("A helicopter ready to take off.\n");
        return;
    }

    /* Examine diary */
    if (!strcasecmp(item, "diary")) {
        printf("A daily appointment diary.\n");
        return;
    }

    /* Examine dispenser */
    if (!strcasecmp(item, "dispenser")) {
        printf("A water dispenser.\n");
        return;
    }

    /* Examine telephone */
    if (!strcasecmp(item, "telephone")) {
        printf("A recorded voice answers and says\n");
        printf("\"Number please?\"\n");
        return;
    }

    /* Examine newspaper */
    if (!strcasecmp(item, "newspaper")) {
        printf("A copy of of the daily newspaper \"The Tally Ho.\"\n");
        return;
    }

    /* Examine tapes */
    if (!strcasecmp(item, "tapes")) {
        printf("Three tape spools marked \"A\", \"B\", and \"C.\"\n");
        return;
    }

    /* Examine can */
    if (!strcasecmp(item, "can")) {
        printf("A can of vegetables marked \"Village Foods.\"\n");
        return;
    }

    /* Examine  wristwatch */
    if (!strcasecmp(item, "wristwatch")) {
        printf("A wristwatch, damaged by salt water and not running.\n");
        return;
    }

    /* Examine " ap */
    if (!strcasecmp(item, "map")) {
        printf("A colour map of the village.\n");
        return;
    }

    /* Examine breakfast */
    if (!strcasecmp(item, "breakfast")) {
        printf("A breakfast of flapjacks on a tray.\n");
        return;
    }

    /* Examine raft */
    if (!strcasecmp(item, "raft")) {
        printf("A inflatable rubber raft, deflated with bullet holes in it.\n");
        return;
    }

    /* Examine cookies */
    if (!strcasecmp(item, "cookies")) {
        printf("A box of Mrs. Butterworth's cookies.\n");
        return;
    }

    /* Examine cigarettes */
    if (!strcasecmp(item, "cigarettes")) {
        printf("A pack of black cigarettes.\n");
        return;
    }

    /*  Examine bike */
    if (!strcasecmp(item, "bike")) {
        printf("A pennyfarthing bicycle.\n");
        return;
    }

    /* Examine teacup */
    if (!strcasecmp(item, "teacup")) {
        printf("It says \"Portmeirion Pottery.\"\n");
        return;
    }

    /* Examine cards */
    if (!strcasecmp(item, "cards")) {
        printf("A pack of Zener cards marked with symbols.\n");
        return;
    }

    /* Examine  chess set */
    if (!strcasecmp(item, "chess set")) {
        printf("The rook is missing.\n");
        return;
    }

    /* Examine record */
    if (!strcasecmp(item, "record")) {
        printf("A recording of Bizet's L'Arlesienne.\n");
        return;
    }

    /* Examine mini moke */
    if (!strcasecmp(item, "mini moke")) {
        printf("A small Mini Moke car with no keys.\n");
        return;
    }

    /* Examine bust */
    if (!strcasecmp(item, "bust")) {
        printf("A carved bust of Number 2.\n");
        return;
    }

    /* Examine credits */
    if (!strcasecmp(item, "credits")) {
        printf("One hundred village credits.\n");
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

    item = getMatch(item);

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I don't see it here.\n");
        return;
    }

    ++turnsPlayed;

    /* Use water dispenser */
    if (!strcasecmp(item, "dispenser")) {
        printf("You receive a painful shock but are\n");
        printf("otherwise unharmed.\n");
        return;
    }

    /* Use remote control */
    if (!strcasecmp(item, "remote control")) {
        if (!bombExploded && currentLocation == TownHall && ((carryingItem("seal") || itemIsHere("seal")))) {
            /* if location is town hall and seal is there, produce an explosion and gain access to control room. */
            printf("There is a huge explosion! An opening\n");
            printf("in the floor leads to the control room.\n");
            Move[TownHall][Down] = ControlRoom;
            bombExploded = 1;
            return;
        } else if (!bombExploded && currentLocation != TownHall && ((carryingItem("seal") || itemIsHere("seal")))) {
            /* If location is somewhere else, give clue that player has the right idea but this is not the time and place. */
            printf("You have the right idea, but this is\n");
            printf("not the right place.\n");
            return;
        } else if (!bombExploded && currentLocation != TownHall && !(carryingItem("seal") && !itemIsHere("seal"))) {
            /* If only remote is here, make a click but nothing happens. Give clue that something is missing. */
            printf("You hear a click, but something\n");
            printf("more is missing.\n");
            return;
        }
    }

    /* Use radio */
    if (!strcasecmp(item, "transmitter") && !helicopterHere) {
        /* Put helicopter at lawn. */
        locationOfItem[Helicopter] = Lawn;
        helicopterHere = 1;
        /* Tell user you hear a helicopter in the distance (or here if at lawn). */
        if (currentLocation == Lawn) {
            printf("There is a helicopter here.\n");
        } else {
            printf("In the distance you hear the sound\n");
            printf("of a helicopter landing.\n");
        }
        return;
    }

    /* Use helicopter */
    if (!strcasecmp(item, "helicopter")) {
        if (carryingItem("#2 badge")) {
            printf("The helicopter picks you up and takes\n");
            printf("you away from The Village.\n");
            printf("You have escaped!\n");
            gameOver = 1;
            return;
        } else {
            printf("The helicopter refuses to pick you up.\n");
            printf("It was summoned for #2.\n");
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

    fprintf(fp, "%s\n", "#Adventure3 Save File");

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

    fprintf(fp, "Variables: %d %d %d %d %d\n",
            currentLocation,
            turnsPlayed,
            doorOpen,
            bombExploded,
            helicopterHere
            );

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
    savedGame[n-1].doorOpen = doorOpen;
    savedGame[n-1].bombExploded = bombExploded;
    savedGame[n-1].helicopterHere = helicopterHere;
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
    if (strcmp(buffer, "#Adventure3 Save File\n")) {
        printf("File is not a valid game file (1).\n");
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
        printf("File is not a valid game file (2).\n");
        fclose(fp);
        return;
    }

    /* Items: 0 1 8 0 7 6 9 2 16 15 18 25 29 10 12 19 */
    i = fscanf(fp, "Items: %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
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
               (int*) &locationOfItem[22],
               (int*) &locationOfItem[23],
               (int*) &locationOfItem[24],
               (int*) &locationOfItem[25],
               (int*) &locationOfItem[26],
               (int*) &locationOfItem[27],
               (int*) &locationOfItem[28],
               (int*) &locationOfItem[29],
               (int*) &locationOfItem[30],
               (int*) &locationOfItem[31]);

    if (i != 31) {
        printf("File is not a valid game file (3).\n");
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
            printf("File is not a valid game file (4).\n");
            fclose(fp);
            return;
        }
    }

    /* Variables: 1 0 0 0 1 */
    i = fscanf(fp, "Variables: %d %d %d %d %d\n",
               (int *) &currentLocation,
               &turnsPlayed,
               &doorOpen,
               &bombExploded,
               &helicopterHere
               );

    if (i != 5) {
        printf("File is not a valid game file (5).\n");
        fclose(fp);
        return;
    }

    if (doorOpen) {
        Move[No6Private][North] = ChessLawn;
        Move[No6Private][South] = Tower;
        Move[No6Private][East]  = GeneralStores;
        Move[No6Private][West]  = Lawn;
    } else {
        Move[No6Private][North] = NoLocation;
        Move[No6Private][South] = NoLocation;
        Move[No6Private][East]  = NoLocation;
        Move[No6Private][West]  = NoLocation;
    }

    if (bombExploded) {
        Move[TownHall][Down] = ControlRoom;
    }

    if (helicopterHere) {
        locationOfItem[Helicopter] = Lawn;
    } else {
        locationOfItem[Helicopter] = NoLocation;
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
    doorOpen = savedGame[n-1].doorOpen;
    bombExploded = savedGame[n-1].bombExploded;
    helicopterHere = savedGame[n-1].helicopterHere;
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
    /* Can only leave No.6 Private if you have the No.6 badge. */
    if (!doorOpen && carryingItem("#6 badge") && (currentLocation == No6Private)) {
        doorOpen = 1;
        Move[No6Private][North] = ChessLawn;
        Move[No6Private][South] = Tower;
        Move[No6Private][East]  = GeneralStores;
        Move[No6Private][West]  = Lawn;
    }
}

/* Set variables to values for start of game */
void initialize()
{
    currentLocation = No6Private;
    turnsPlayed = 0;
    doorOpen = 0;
    bombExploded = 0;
    helicopterHere = 0;
    gameOver = 0;

    /* These doors can get changed during game and may need to be reset */
    Move[TownHall][Down] = NoLocation;
    Move[No6Private][North] = NoLocation;
    Move[No6Private][South] = NoLocation;
    Move[No6Private][East]  = NoLocation;
    Move[No6Private][West]  = NoLocation;

    /* Set inventory to default */
    memset(Inventory, 0, sizeof(Inventory[0])*MAXITEMS);
    Inventory[0] = Cigarettes;

    /* Put items in their default locations */
    locationOfItem[0]             = NoLocation;
    locationOfItem[No6Badge]      = No6Private;
    locationOfItem[No2Badge]      = TheGreenDome;
    locationOfItem[RemoteControl] = TownHall;
    locationOfItem[Pass]          = StoneShip;
    locationOfItem[Seal]          = GeneralStores;
    locationOfItem[Transmitter]   = ControlRoom;
    locationOfItem[Diary]         = No6Private;
    locationOfItem[Dispenser]     = Hospital;
    locationOfItem[Telephone]     = No6Private;
    locationOfItem[Newspaper]     = Cafe;
    locationOfItem[Tapes]         = ControlRoom;
    locationOfItem[Can]           = No6Private;
    locationOfItem[Wristwatch]    = RecreationHall;
    locationOfItem[Map]           = Shop;
    locationOfItem[Breakfast]     = TheGreenDome;
    locationOfItem[Raft]          = TheBeach2;
    locationOfItem[Cookies]       = OldPeoplesHome;
    locationOfItem[Bike]          = TheGreenDome;
    locationOfItem[Umbrella]      = TheSea1;
    locationOfItem[LavaLamp]      = PalaceOfFun;
    locationOfItem[Teacup]        = No6Private;
    locationOfItem[Cards]         = BandStand;
    locationOfItem[ChessSet]      = ChessLawn;
    locationOfItem[Record]        = GeneralStores;
    locationOfItem[Note]          = Caves;
    locationOfItem[MiniMoke]      = FreeSea;
    locationOfItem[Bust]          = RecreationHall;
    locationOfItem[Credits]       = TopOfTower;
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
