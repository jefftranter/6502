 /*
 *
 * Daniel's Diefenbunker Adventure
 *
 * A sequel to The Abandoned Farmhouse, Skye's Castle, and Prisoner
 * adventures.
 *
 * Dedicated to my grandson Daniel Tranter who was seven months old
 * when I wrote this.
 *
 * Jeff Tranter <tranter@pobox.com>
 *
 * Written in standard C, with some adaptions to work on various
 * embedded assemblers for retrocomputers like the Apple II, Commodore
 * 64, CP/M, HDOS, and some of my single-board computers.
 *
 * Copyright 2012-2026 Jeff Tranter
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
 * 0.0      12 Mar 2026  Started development.
 * 0.1      14 Mar 2026  Working version.
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
#if defined(__CC65__) || defined(CPM) || defined(HDOS)
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

#if defined(__linux__) || defined(__APPLE2ENH__) || defined(__C64__) || defined(CPM) || defined(HDOS)
#define FILEIO 1
#endif

/* CONSTANTS */

/* Maximum number of items user can carry */
#define MAXITEMS 5

/* Number of locations */
#define NUMLOCATIONS 37

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
    Key,
    Map,
    Gum,
    Flashlight,
    CellPhone,
    Pamphlet,
    GeigerCounter,
    Computer,
    Bomb,
    LastItem=Bomb
} Item_t;

/* Locations */
typedef enum {
    NoLocation,
    Decontamination,
    MedicalCentre,
    Confinement,
    DentalOffice,
    MessageControlCentre,
    TeletypeRepairRoom,
    EscapeHatch,
    EmergencyRadioRoom,
    EmergencyTransmitter,
    TelephoneBooths,
    FederalComms,
    FederalWarningCentre,
    WarCabinetRoom,
    Secretariat,
    EmergencySituation,
    EmergencyPreparedness,
    WeatherOffice,
    GovernmentMinistry,
    OnlineCryptography,
    OSAX,
    WomensQuarters,
    CBCRadioStudio,
    PrimeMinistersSuite,
    ExternalAffairs,
    CanadianForces,
    MachineRoom,
    BankOfCanadaVault,
    ColdStorageAndMorgue,
    Cafeteria,
    SeniorOfficersMess,
    CANEX,
    Stairs100Level,
    Stairs200Level,
    Stairs300Level,
    Stairs400Level,
    Surface,
} Location_t;

/* Structure to hold entire game state */
typedef struct {
    number valid;
    Item_t Inventory[MAXITEMS];
    Location_t locationOfItem[LastItem+1];
    Direction_t Move[NUMLOCATIONS][6];
    number currentLocation;
    int turnsPlayed;
    number doorUnlocked;
} GameState_t;

/* TABLES */

/* Names of directions */
const char *DescriptionOfDirection[] = {
    "north", "south", "east", "west", "up", "down"
};

/* Names of items */
const char *DescriptionOfItem[LastItem+1] = {
    "",
    "key",
    "map",
    "gum",
    "flashlight",
    "cellphone",
    "pamphlet",
    "Geiger counter",
    "computer",
    "bomb"
};

/* Strings for using items. */
const char *UseItem[LastItem+1] = {
    "",
    "It is a a key marked \"master key\".",
    "A map of the Diefenbunker. It shows an escape hatch on level 400 near\nthe Message Control Centre and Teletype Repair Room.",
    "A pack of \"Thrills\" chewing gum.",
    "A flashlight marked Big Beam no. 287EX, for use in hazardous\nlocations, Class I Group D. It has no battery.",
    "A working cellphone, but there is no service here.",
    "A cold war survival booklet entitled \"11 Steps to Survival\".",
    "A model CD V-715 Ion Chamber Survey Meter.",
    "A NORAD STRAD supercomputer.",
    "A BDU-8/B H-Bomb trainer.",
};

/* Names of locations */
const char *DescriptionOfLocation[NUMLOCATIONS] = {
    "",
    "in Decontamination",
    "in the Medical Centre",
    "in Confinement and Hospital Overflow",
    "in the Dental Office",
    "in the Message Control Centre",
    "in the Teletype Repair Room",
    "at the Emergency Escape Hatch",
    "in the Emergency Radio Room",
    "in the Emergency Transmitter Room",
    "in the Private Telephone Booths",
    "in the Federal Warning Communications Centre",
    "in the Federal Warning Centre",
    "in the War Cabinet Room",
    "in the Secretariat",
    "in the Emergency Government Situation Centre (EMGOVSITCEN)",
    "in Emergency Preparedness Canada",
    "in the Weather Office",
    "in the Government Ministry Office",
    "in Online Cryptography (OLC)",
    "in the Ottawa Semi-Automatic Exchange (OSAX)",
    "in the Women's Quarters",
    "in the CBC Radio Broadcasting Studio",
    "in the Prime Minister's Suite",
    "in External Affairs",
    "in the Canadian Forces Offices",
    "in the Machine Room",
    "in the Bank of Canada Vault",
    "in Cold Storage and Morgue",
    "in the Cafeteria and Recreation Area",
    "in the Senior Officers' Mess",
    "in the Canada Forces Exchange System (CANEX)",
    "on the 100 level stairs",
    "on the 200 level stairs",
    "on the 300 level stairs",
    "on the 400 level stairs",
    "on the surface at ground level"
};

/* DATA */

/* Inventory of what player is carrying */
Item_t Inventory[MAXITEMS];

/* Location of each item. Index is the item number, returns the location. 0 if item is gone */
Location_t locationOfItem[LastItem+1];

/* Map. Given a location and a direction to move, returns the location it connects to, or 0 if not a valid move. Map can change during game play. */
Location_t Move[NUMLOCATIONS][6] = {
    /* N  S  E  W  U  D */
    { NoLocation,           NoLocation,           NoLocation,            NoLocation,            NoLocation,     NoLocation },     /*  0 NoLocation */
    { NoLocation,           NoLocation,           Stairs400Level,        MedicalCentre,         NoLocation,     NoLocation },     /*  1 Decontamination */
    { Confinement,          NoLocation,           Decontamination,       NoLocation,            NoLocation,     NoLocation },     /*  2 Medical Centre */
    { DentalOffice,         MedicalCentre,        NoLocation,            NoLocation,            NoLocation,     NoLocation },     /*  3 Confinement and Hospital Overflow */
    { MessageControlCentre, Decontamination,      NoLocation,            NoLocation,            NoLocation,     NoLocation },     /*  4 Dental Office */
    { EscapeHatch,          DentalOffice,         TeletypeRepairRoom,    NoLocation,            NoLocation,     NoLocation },     /*  5 Message Control Centre */
    { NoLocation,           NoLocation,           EmergencyRadioRoom,    MessageControlCentre,  NoLocation,     NoLocation },     /*  6 Teletype Repair Room */
    { NoLocation,           MessageControlCentre, NoLocation,            NoLocation,            NoLocation,     NoLocation },     /*  7 Emergency Escape Hatch */
    { NoLocation,           EmergencyTransmitter, NoLocation,            TeletypeRepairRoom,    NoLocation,     NoLocation },     /*  8 Emergency Radio Room */
    { EmergencyRadioRoom,   NoLocation,           NoLocation,            NoLocation,            NoLocation,     NoLocation },     /*  9 Emergency Transmitter Room */
    { FederalComms,         Stairs300Level,       ExternalAffairs,       Secretariat,           NoLocation,     NoLocation },     /* 10 Private Telephone Booths */
    { OSAX,                 TelephoneBooths,      PrimeMinistersSuite,   FederalWarningCentre,  NoLocation,     NoLocation },     /* 11 Federal Warning Communications Centre */
    { NoLocation,           NoLocation,           FederalComms,          WarCabinetRoom,        NoLocation,     NoLocation },     /* 12 Federal Warning Centre */
    { NoLocation,           NoLocation,           FederalWarningCentre,  NoLocation,            NoLocation,     NoLocation },     /* 13 War Cabinet Room */
    { NoLocation,           NoLocation,           TelephoneBooths,       EmergencyPreparedness, NoLocation,     NoLocation },     /* 14 Secretariat */
    { NoLocation,           NoLocation,           Stairs300Level,        WeatherOffice,         NoLocation,     NoLocation },     /* 15 Emergency Government Situation Centre */
    { NoLocation,           NoLocation,           Secretariat,           GovernmentMinistry,    NoLocation,     NoLocation },     /* 16 Emergency Preparedness Canada */
    { NoLocation,           NoLocation,           EmergencySituation,    NoLocation,            NoLocation,     NoLocation },     /* 17 Weather Office */
    { NoLocation,           NoLocation,           EmergencyPreparedness, NoLocation,            NoLocation,     NoLocation },     /* 18 Government Ministry Office */
    { NoLocation,           NoLocation,           OSAX,                  NoLocation,            NoLocation,     NoLocation },     /* 19 Online Cryptography (OLC) */
    { NoLocation,           FederalComms,         WomensQuarters,        OnlineCryptography,    NoLocation,     NoLocation },     /* 20 Ottawa Semi-Automatic Exchange (OSAX) */
    { NoLocation,           NoLocation,           NoLocation,            OSAX,                  NoLocation,     NoLocation },     /* 21 Women's Quarters */
    { NoLocation,           PrimeMinistersSuite,  NoLocation,            NoLocation,            NoLocation,     NoLocation },     /* 22 CBC Radio Broadcasting Studio */
    { CBCRadioStudio,       ExternalAffairs,      NoLocation,            FederalComms,          NoLocation,     NoLocation },     /* 23 Prime Minister's Suite */
    { PrimeMinistersSuite,  CanadianForces,       NoLocation,            TelephoneBooths,       NoLocation,     NoLocation },     /* 24 External Affairs */
    { ExternalAffairs,      NoLocation,           NoLocation,            Stairs300Level,        NoLocation,     NoLocation },     /* 25 Canadian Forces Offices */
    { NoLocation,           NoLocation,           Stairs100Level,        NoLocation,            NoLocation,     NoLocation },     /* 26 Machine Room */
    { Stairs100Level,       NoLocation,           NoLocation,            NoLocation,            NoLocation,     NoLocation },     /* 27 Bank of Canada Vault */
    { NoLocation,           NoLocation,           NoLocation,            Stairs100Level,        NoLocation,     NoLocation },     /* 28 Cold Storage and Morgue */
    { NoLocation,           NoLocation,           NoLocation,            Stairs200Level,        NoLocation,     NoLocation },     /* 29 Cafeteria and Recreation Area */
    { NoLocation,           Stairs200Level,       NoLocation,            NoLocation,            NoLocation,     NoLocation },     /* 30 Senior Officers' Mess */
    { NoLocation,           NoLocation,           Stairs300Level,        NoLocation,            NoLocation,     NoLocation },     /* 31 Canada Forces Exchange System (CANEX) */
    { NoLocation,           BankOfCanadaVault,    ColdStorageAndMorgue,  MachineRoom,           Stairs200Level, NoLocation },     /* 32 Stairs - 100 level (bottom) */
    { SeniorOfficersMess,   NoLocation,           Cafeteria,             CANEX,                 Stairs300Level, Stairs100Level }, /* 33 Stairs - 200 level */
    { TelephoneBooths,      NoLocation,           CanadianForces,        EmergencySituation,    Stairs400Level, Stairs200Level }, /* 34 Stairs - 300 level */
    { NoLocation,           NoLocation,           NoLocation,            Decontamination,       NoLocation,     Stairs300Level }, /* 35 Stairs - 400 level (top) */
    { NoLocation,           NoLocation,           NoLocation,            NoLocation,            NoLocation,     EscapeHatch},     /* 36 Surface at ground level */
};

/* Current location */
Location_t currentLocation;

/* Number of turns played in game */
int turnsPlayed;

/* Set when door to emergency exit is unlocked and will open */
number doorUnlocked;

/* Set when game is over */
number gameOver;

#ifndef FILEIO
/* Memory-resident saved games */
GameState_t savedGame[SAVEGAMES];
#endif

const char *introText =
    "                   Diefenbunker Adventure\n"
    "                      By Jeff Tranter\n\n"
    "You and your grandson Daniel are visiting the Diefenbunker Cold\n"
    "War Museum, but get lost and locked in after the bunker closes. Can\n"
    "you find your way out?\n";

#ifdef FILEIO
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down\nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <file>\nrestore <file>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#else
const char *helpString = "Valid commands:\ngo east/west/north/south/up/down\nlook\nuse <object>\nexamine <object>\ntake <object>\ndrop <object>\ninventory\nbackup <number>\nrestore <number>\nhelp\nquit\nYou can abbreviate commands and\ndirections to the first letter.\nType just the first letter of\na direction to move.\n";
#endif

/* Line of user input */
char buffer[80];

#if defined(__OSIC1P__)

/* Have to implement fgets() ourselves as it is not available. */
char* _fgets(char* buf, size_t size, FILE*)
{
    int c;
    char *p;

    /* get max bytes or upto a newline */
    for (p = buf, size--; size > 0; size--) {
        if ((c = cgetc()) == EOF)
            break;
        cputc(c); /* echo back */
        *p++ = c;
        if (c == '\n' || c == '\r')
            break;
    }
    *p = 0;
    if (p == buf || c == EOF)
        return NULL;
    return (p);
}

#define fgets _fgets
#define printf cprintf
#endif

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
#if (defined(__CC65__) && !defined(__KIM1__))
    clrscr();
#elif defined(HDOS) || defined(CPM)
    /* Heathkit H89/H19 screen clear */
    printf("\eE");
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
   uniquely matches. Otherwise returns the original name. Only check
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
#ifdef __Z88DK
    fflush(stdout);
#else
    fflush(NULL);
#endif
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

    if (carryingItem(item)) {
        printf("Already carrying it.\n");
        return;
    }

    /* Find number of the item. */
    for (i = 1; i <= LastItem; i++) {
        if (!strcasecmp(item, DescriptionOfItem[i])) {
            /* Found it, but is it here? */
            if (locationOfItem[i] == currentLocation) {

                /* Check for item that can't be taken */
                if (i == Computer) {
                    printf("It is too heavy and bolted to the floor.\n");
                    ++turnsPlayed;
                    return;
                }

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
    int i;

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

    for (i = 1; i <= LastItem; i++) {
        if (!strcasecmp(item, DescriptionOfItem[i])) {
            /* Found it, but is it here? */
            if (locationOfItem[i] == currentLocation) {
                printf("%s\n", UseItem[i]);
                return;
            }
        }
    }

    // Allow some aliases for item names

    if (!strcasecmp(item, "cell") || !strcasecmp(item, "phone") || strcasecmp(item, "cell phone")) {
        printf("%s\n", UseItem[CellPhone]);
        return;
    }

    if (!strcasecmp(item, "geiger") || !strcasecmp(item, "counter")) {
        printf("%s\n", UseItem[CellPhone]);
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

    /* Use key */
    if (!strcasecmp(item, "key") && currentLocation == EscapeHatch) {
        printf("The door to the escape hatch unlocks. You open it, and pull the lever\n");
        printf("which releases 13 metric tonnes of pea gravel. A ladder now leads nine\n");
        printf("meters up to the surface.\n");
        Move[EscapeHatch][Up] = Surface;
        doorUnlocked = 1;
        return;
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

    fprintf(fp, "%s\n", "#Adventure4 Save File");

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

    fprintf(fp, "Variables: %d %d %d\n",
            currentLocation,
            turnsPlayed,
            doorUnlocked
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
    savedGame[n-1].doorUnlocked = doorUnlocked;
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
    if (strcmp(buffer, "#Adventure4 Save File\n")) {
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
    i = fscanf(fp, "Items: %d %d %d %d %d %d %d %d %d %d\n",
               (int*) &locationOfItem[0],
               (int*) &locationOfItem[1],
               (int*) &locationOfItem[2],
               (int*) &locationOfItem[3],
               (int*) &locationOfItem[4],
               (int*) &locationOfItem[5],
               (int*) &locationOfItem[6],
               (int*) &locationOfItem[7],
               (int*) &locationOfItem[8],
               (int*) &locationOfItem[9]);

    if (i != 10) {
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

    /* Variables: 1 0 0 */
    i = fscanf(fp, "Variables: %d %d %d\n",
               (int *) &currentLocation,
               &turnsPlayed,
               &doorUnlocked
               );

    if (i != 3) {
        printf("File is not a valid game file (5).\n");
        fclose(fp);
        return;
    }

    if (doorUnlocked) {
        Move[EscapeHatch][Up] = Surface;
    } else {
        Move[EscapeHatch][Up] = NoLocation;
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
    doorUnlocked = savedGame[n-1].doorUnlocked;
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

#if defined(__CC65__) && !defined(__KIM1__)
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
#ifdef __Z88DK
    fflush(stdout);
#else
    fflush(NULL);
#endif
    fgets(buffer, sizeof(buffer)-1, stdin);

    /* Remove trailing newline */
    buffer[strlen(buffer)-1] = '\0';
#endif /* __CC65__ */
}

/* Do special things unrelated to command typed. */
void doActions()
{
    if (currentLocation == EscapeHatch && !doorUnlocked) {
        printf("There is a closet with a locked door here.\n");
    }

    if (currentLocation == Surface) {
        printf("Congratulations! You and Daniel successfuly found your way out.\n");
        printf("You won the game!\n");
        gameOver = 1;
    }
}

/* Set variables to values for start of game */
void initialize()
{
    currentLocation = Decontamination;
    turnsPlayed = 0;
    doorUnlocked = 0;
    gameOver = 0;

    /* These doors can get changed during game and may need to be reset */
    Move[EscapeHatch][Up] = NoLocation;

    /* Set inventory to default */
    memset(Inventory, 0, sizeof(Inventory[0])*MAXITEMS);
    Inventory[0] = CellPhone;

    /* Put items in their default locations */
    locationOfItem[0]             = NoLocation;
    locationOfItem[Key]           = BankOfCanadaVault;
    locationOfItem[Gum]           = CANEX;
    locationOfItem[Flashlight]    = SeniorOfficersMess;
    locationOfItem[Pamphlet]      = EmergencyPreparedness;
    locationOfItem[GeigerCounter] = MedicalCentre;
    locationOfItem[Computer]      = MachineRoom;
    locationOfItem[Bomb]          = PrimeMinistersSuite;
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
#ifdef __Z88DK
    fflush(stdout);
#else
    fflush(NULL);
#endif
        fgets(buffer, sizeof(buffer)-1, stdin);
        if (tolower(buffer[0]) == 'n') {
            break;
        }
    }
    return 0;
}
