/*
 * 
 * The Abandoned Farm House Adventure
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
 * Revision History:
 *
 * Version  Date         Comments
 * -------  ----         --------
 * 0.0      13 Mar 2012  First alpha version
 * 0.1      18 Mar 2012  First beta version
 * 0.9      19 Mar 2012  First public release
 *
 */

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 

/* CONSTANTS */

/* Maximum number of items user can carry */
#define MAXITEMS 5

/* Number of locations */
#define NUMLOCATIONS 32

/* TYPES */

/* To optimize for code size and speed, must numbers are 8-bit chars when compiling for the Replica 1. */
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
    Pitchfork,
    Flashlight,
    Lamp,
    Oil,
    Candybar,
    Bottle,
    Doll,
    ToyCar,
    Matches,
    GoldCoin,
    SilverCoin,
    StaleMeat,
    Book,
    Cheese,
    OldRadio,
    LastItem=OldRadio
} Item_t;

/* Locations */
typedef enum {
    NoLocation,
    Driveway1,
    Driveway2,
    Driveway3,
    Driveway4,
    Driveway5,
    Garage,
    WorkRoom,
    Hayloft,
    Kitchen,
    DiningRoom,
    BottomStairs,
    DrawingRoom,
    Study,
    TopStairs,
    BoysBedroom,
    GirlsBedroom,
    MasterBedroom,
    ServantsQuarters,
    LaundryRoom,
    FurnaceRoom,
    VacantRoom,
    Cistern,
    Tunnel,
    Woods24,
    Woods25,
    Woods26,
    WolfTree,
    Woods28,
    Woods29,
    Woods30,
    Woods31,
} Location_t;

/* TABLES */

/* Names of directions */
char *DescriptionOfDirection[] = {
    "NORTH", "SOUTH", "EAST", "WEST", "UP", "DOWN"
};

/* Names of items */
char *DescriptionOfItem[LastItem+1] = {
    "",
    "KEY",
    "PITCHFORK",
    "FLASHLIGHT",
    "LAMP",
    "OIL",
    "CANDYBAR",
    "BOTTLE",
    "DOLL",
    "TOY CAR",
    "MATCHES",
    "GOLD COIN",
    "SILVER COIN",
    "STALE MEAT",
    "BOOK",
    "CHEESE",
    "OLD RADIO",
};

/* Names of locations */
char *DescriptionOfLocation[NUMLOCATIONS] = {
    "",
    "IN THE DRIVEWAY NEAR YOUR CAR",
    "IN THE DRIVEWAY",
    "IN FRONT OF THE GARAGE",
    "IN FRONT OF THE BARN",
    "AT THE DOOR TO THE HOUSE",
    "IN THE GARAGE",
    "IN THE WORKROOM OF THE BARN",
    "IN THE HAYLOFT OF THE BARN",
    "IN THE KITCHEN",
    "IN THE DINING ROOM",
    "AT THE BOTTOM OF THE STAIRS",
    "IN THE DRAWING ROOM",
    "IN THE STUDY",
    "AT THE TOP OF THE STAIRS",
    "IN A BOY'S BEDROOM",
    "IN A GIRL'S BEDROOM",
    "IN THE MASTER BEDROOM NEXT TO\nA BOOKCASE",
    "IN THE SERVANT'S QUARTERS",
    "IN THE BASEMENT LAUNDRY ROOM",
    "IN THE FURNACE ROOM",
    "IN A VACANT ROOM NEXT TO A\nLOCKED DOOR",
    "IN THE CISTERN",
    "IN AN UNDERGROUND TUNNEL. THERE ARE RATS HERE",
    "IN THE WOODS NEAR A TRAPDOOR",
    "IN THE WOODS",
    "IN THE WOODS",
    "IN THE WOODS NEXT TO A TREE",
    "IN THE WOODS",
    "IN THE WOODS",
    "IN THE WOODS",
    "IN THE WOODS",
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

/* True if player has lit the lamp. */
number lampLit;

/* True if lamp filled with oil. */
number lampFilled;

/* True if player ate food. */
number ateFood;

/* True if player drank water. */
number drankWater;

/* Incremented each turn you are in the tunnel. */
number ratAttack;

/* Tracks state of wolf attack */
number wolfState;

/* Set when game is over */
number gameOver;

const char *introText = "     ABANDONED FARMHOUSE ADVENTURE\n           BY JEFF TRANTER\n\nYOUR THREE-YEAR-OLD GRANDSON HAS GONE\nMISSING AND WAS LAST SEEN HEADED IN THE\nDIRECTION OF THE ABANDONED FAMILY FARM.\nIT'S A DANGEROUS PLACE TO PLAY. YOU\nHAVE TO FIND HIM BEFORE HE GETS HURT,\nAND IT WILL BE GETTING DARK SOON...\n";

const char *helpString = "VALID COMMANDS:\nGO EAST/WEST/NORTH/SOUTH/UP/DOWN \nLOOK\nUSE <OBJECT>\nEXAMINE <OBJECT>\nTAKE <OBJECT>\nDROP <OBJECT>\nINVENTORY\nHELP\nQUIT\nYOU CAN ABBREVIATE COMMANDS AND\nDIRECTIONS TO THE FIRST LETTER.\nTYPE JUST THE FIRST LETTER OF\nA DIRECTION TO MOVE.\n";

/* Line of user input */
char buffer[40];

/* Clear the screen */
void clearScreen()
{
    number i;
    for (i = 0; i < 24; ++i)
        printf("\n");
}

/* Return 1 if carrying an item */
number carryingItem(char *item)
{
    number i;

    for (i = 0; i < MAXITEMS; i++) {
        if ((Inventory[i] != 0) && (!strcmp(DescriptionOfItem[Inventory[i]], item)))
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
        if (!strcmp(item, DescriptionOfItem[i])) {
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

    printf("%s", "YOU ARE CARRYING:\n");
    for (i = 0; i < MAXITEMS; i++) {
        if (Inventory[i] != 0) {
            printf("  %s\n", DescriptionOfItem[Inventory[i]]);
            found = 1;
        }
    }
    if (!found)
        printf("  NOTHING\n");
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

    printf("YOU ARE %s.\n", DescriptionOfLocation[currentLocation]);

    seen = 0;
    printf("YOU SEE:\n");
    for (i = 1; i <= LastItem; i++) {
        if (locationOfItem[i] == currentLocation) {
            printf("  %s\n", DescriptionOfItem[i]);
            seen = 1;
        }
    }
    if (!seen)
        printf("  NOTHING SPECIAL\n");

    printf("YOU CAN GO:");

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
    printf("%s", "ARE YOU SURE YOU WANT TO QUIT (Y/N)? ");
    fgets(buffer, sizeof(buffer)-1, stdin);
    if (toupper(buffer[0]) == 'Y') {
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
        printf("DROP WHAT?\n");
        return;
    }

    item = sp + 1;

    /* See if we have this item */
    for (i = 0; i < MAXITEMS; i++) {
        if ((Inventory[i] != 0) && (!strcmp(DescriptionOfItem[Inventory[i]], item))) {
            /* We have it. Add to location. */
            locationOfItem[Inventory[i]] = currentLocation;
            /* And remove from inventory */
            Inventory[i] = 0;
            printf("DROPPED %s.\n", item);
            ++turnsPlayed;
            return;
        }
    }
    /* If here, don't have it. */
    printf("NOT CARRYING %s.\n", item);
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
        printf("TAKE WHAT?\n");
        return;
    }

    item = sp + 1;

    /* Find number of the item. */
    for (i = 1; i <= LastItem; i++) {
        if (!strcmp(item, DescriptionOfItem[i])) {
            /* Found it, but is it here? */
            if (locationOfItem[i] == currentLocation) {
            /* It is here. Add to inventory. */
            for (j = 0; j < MAXITEMS; j++) {
                if (Inventory[j] == 0) {
                    Inventory[j] = i;
                    /* And remove from location. */
                    locationOfItem[i] = 0;
                    printf("TOOK %s.\n", item);
                    ++turnsPlayed;
                    return;
                }
            }

            /* Reached maximum number of items to carry */ 
            printf("YOU CAN'T CARRY ANY MORE. DROP SOMETHING.\n");
            return;
            }
        }
    }

    /* If here, don't see it. */
    printf("I SEE NO %s HERE.\n", item);
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

    if (dirChar == 'N') {
        dir = North;
    } else if (dirChar == 'S') {
        dir = South;
    } else if (dirChar == 'E') {
        dir = East;
    } else if (dirChar == 'W') {
        dir = West;
    } else if (dirChar == 'U') {
        dir = Up;
    } else if (dirChar == 'D') {
        dir = Down;
    } else {
        printf("GO WHERE?\n");
        return;
    }

    if (Move[currentLocation][dir] == 0) {
        printf("YOU CAN'T GO %s FROM HERE.\n", DescriptionOfDirection[dir]);
        return;
    }

    /* We can move */
    currentLocation = Move[currentLocation][dir];
    printf("YOU ARE %s.\n", DescriptionOfLocation[currentLocation]);
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
        printf("EXAMINE WHAT?\n");
        return;
    }

    item = sp + 1;
    ++turnsPlayed;

    /* Examine bookcase - not an object */
    if (!strcmp(item, "BOOKCASE")) {
        printf("YOU PULL BACK A BOOK AND THE BOOKCASE\nOPENS UP TO REVEAL A SECRET ROOM.\n");
        Move[17][North] = 18;
        return;
    }

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I DON'T SEE IT HERE.\n");
        return;
    }

    /* Examine Book */
    if (!strcmp(item, "BOOK")) {
        printf("IT IS A VERY OLD BOOK ENTITLED\n\"APPLE 1 OPERATION MANUAL\".\n");
        return;
    }

    /* Examine Flashlight */
    if (!strcmp(item, "FLASHLIGHT")) {
        printf("IT DOESN'T HAVE ANY BATTERIES.\n");
        return;
    }

    /* Examine toy car */
    if (!strcmp(item, "TOY CAR")) {
        printf("IT IS A NICE TOY CAR.\nYOUR GRANDSON MATTHEW WOULD LIKE IT.\n");
        return;
    }

    /* Examine old radio */
    if (!strcmp(item, "OLD RADIO")) {
        printf("IT IS A 1940 ZENITH 8-S-563 CONSOLE\nWITH AN 8A02 CHASSIS. YOU'D TURN IT ON\nBUT THE ELECTRICITY IS OFF.\n");
        return;
    }

   /* Nothing special about this item */
   printf("YOU SEE NOTHING SPECIAL ABOUT IT.\n");
}

/* Use command */
void doUse()
{
    char *sp;
    char *item;

    /* Command line should be like "U[SE] ITEM" Item name will be after after first space. */
    sp = strchr(buffer, ' ');
    if (sp == NULL) {
        printf("USE WHAT?\n");
        return;
    }

    item = sp + 1;

    /* Make sure item is being carried or is in the current location */
    if (!carryingItem(item) && !itemIsHere(item)) {
        printf("I DON'T SEE IT HERE.\n");
        return;
    }

    ++turnsPlayed;

    /* Use key */
    if (!strcmp(item, "KEY") && (currentLocation == VacantRoom)) {
        printf("YOU INSERT THE KEY IN THE DOOR AND IT\nOPENS, REVEALING A TUNNEL.\n");
        Move[21][North] = 23;
        return;
    }

    /* Use pitchfork */
    if (!strcmp(item, "PITCHFORK") && (currentLocation == WolfTree) && (wolfState == 0)) {
        printf("YOU JAB THE WOLF WITH THE PITCHFORK.\nIT HOWLS AND RUNS AWAY.\n");
        wolfState = 1;
        return;
    }

    /* Use toy car */
    if (!strcmp(item, "TOY CAR") && (currentLocation == WolfTree && wolfState == 1)) {
        printf("YOU SHOW MATTHEW THE TOY CAR AND HE\nCOMES DOWN TO TAKE IT. YOU TAKE MATTHEW\nIN YOUR ARMS AND CARRY HIM HOME.\n");
        wolfState = 2;
        return;
    }

    /* Use oil */
    if (!strcmp(item, "OIL")) {
        if (carryingItem("LAMP")) {
            printf("YOU FILL THE LAMP WITH OIL.\n");
            lampFilled = 1;
            return;
        } else {
            printf("YOU DON'T HAVE ANYTHING TO USE IT WITH.\n");
            return;
        }
    }

    /* Use matches */
    if (!strcmp(item, "MATCHES")) {
        if (carryingItem("LAMP")) {
            if (lampFilled) {
                printf("YOU LIGHT THE LAMP. YOU CAN SEE!\n");
                lampLit = 1;
                return;
            } else {
                printf("YOU CAN'T LIGHT THE LAMP. IT NEEDS OIL.\n");
                return;
            }
        } else {
            printf("NOTHING HERE TO LIGHT\n");
        }
    }
                
    /* Use candybar */
    if (!strcmp(item, "CANDYBAR")) {
        printf("THAT HIT THE SPOT. YOU NO LONGER FEEL\nHUNGRY.\n");
        ateFood = 1;
        return;
    }

    /* Use bottle */
    if (!strcmp(item, "BOTTLE")) {
        if (currentLocation == Cistern) {
            printf("YOU FILL THE BOTTLE WITH WATER FROM THE\nCISTERN AND TAKE A DRINK. YOU NO LONGER\nFEEL THIRSTY.\n");
            drankWater = 1;
            return;
        } else {
            printf("THE BOTTLE IS EMPTY. IF ONLY YOU HAD\nSOME WATER TO FILL IT!\n");
            return;
        }
    }

    /* Use stale meat */
    if (!strcmp(item, "STALE MEAT")) {
        printf("THE MEAT LOOKED AND TASTED BAD. YOU\nFEEL VERY SICK AND PASS OUT.\n");
        gameOver = 1;
        return;
    }

    /* Default */
    printf("NOTHING HAPPENS\n");
}

/* Prompt user and get a line of input */
void prompt()
{
    number i;

    printf("? ");        
    fgets(buffer, sizeof(buffer)-1, stdin);

    /* Remove trailing newline */
    buffer[strlen(buffer)-1] = '\0';

    /* Convert buffer to uppercase */
    for (i = 0; i < strlen(buffer); i++) 
        buffer[i] = toupper(buffer[i]);
}

/* Do special things unrelated to command typed. */
void doActions()
{
    if ((turnsPlayed == 10) && !lampLit) {
        printf("IT WILL BE GETTING DARK SOON. YOU NEED\nSOME KIND OF LIGHT OR SOON YOU WON'T\nBE ABLE TO SEE.\n");
    }

    if ((turnsPlayed >= 60) && (!lampLit || (!itemIsHere("LAMP") && !carryingItem("LAMP")))) {
        printf("IT IS DARK OUT AND YOU HAVE NO LIGHT.\nYOU STUMBLE AROUND FOR A WHILE AND\nTHEN FALL, HIT YOUR HEAD, AND PASS OUT.\n");
        gameOver = 1;
        return;
    }

    if ((turnsPlayed == 20) && !drankWater) {
        printf("YOU ARE GETTING VERY THIRSTY.\nYOU NEED TO GET A DRINK SOON.\n");
    }

    if ((turnsPlayed == 30) && !ateFood) {
        printf("YOU ARE GETTING VERY HUNGRY.\nYOU NEED TO FIND SOMETHING TO EAT.\n");
    }

    if ((turnsPlayed == 50) && !drankWater) {
        printf("YOU PASS OUT DUE TO THIRST.\n");
        gameOver = 1;
        return;
    }

    if ((turnsPlayed == 40) && !ateFood) {
        printf("YOU PASS OUT FROM HUNGER.\n");
        gameOver = 1;
        return;
    }

    if (currentLocation == Tunnel) {
        if (itemIsHere("CHEESE")) {
            printf("THE RATS GO AFTER THE CHEESE.\n");
        } else {
            if (ratAttack < 3) {
                printf("THE RATS ARE COMING TOWARDS YOU!\n");
                ++ratAttack;
            } else {
                printf("THE RATS ATTACK AND YOU PASS OUT.\n");
                gameOver = 1;
                return;
            }
        }
    }

    /* wolfState values:  0 - wolf attacking 1 - wolf gone, Matthew in tree. 2 - Matthew safe, you won. Game over. */
    if (currentLocation == WolfTree) {
        switch (wolfState) {
            case 0:
                printf("A WOLF IS CIRCLING AROUND THE TREE.\nMATTHEW IS UP IN THE TREE. YOU HAVE TO\nSAVE HIM! IF ONLY YOU HAD SOME KIND OF\nWEAPON!\n");
                break;
            case 1:
                printf("MATTHEW IS AFRAID TO COME\nDOWN FROM THE TREE. IF ONLY YOU HAD\nSOMETHING TO COAX HIM WITH.\n");
                break;
            case 2:
                printf("CONGRATULATIONS! YOU SUCCEEDED AND WON\nTHE GAME. I HOPE YOU HAD AS MUCH FUN\nPLAYING THE GAME AS I DID CREATING IT.\n- JEFF TRANTER <TRANTER@POBOX.COM>\n");
                gameOver = 1;
                return;
                break;
            }
    }
}

/* Set variables to values for start of game */
void initialize()
{
    currentLocation = Driveway1;
    lampFilled = 0;
    lampLit = 0;
    ateFood = 0;
    drankWater = 0;
    ratAttack = 0;
    wolfState = 0;
    turnsPlayed = 0;
    gameOver= 0;

    /* These doors can get changed during game and may need to be reset O*/
    Move[17][North] = 0;
    Move[21][North] = 0;

    /* Set inventory to default */
    memset(Inventory, 0, sizeof(Inventory[0])*MAXITEMS);
    Inventory[0] = Flashlight;

    /* Put items in their default locations */
    locationOfItem[0]  = 0;                /* NoItem */
    locationOfItem[1]  = Driveway1;        /* Key */
    locationOfItem[2]  = Hayloft;          /* Pitchfork */
    locationOfItem[3]  = 0;                /* Flashlight */
    locationOfItem[4]  = WorkRoom;         /* Lamp */
    locationOfItem[5]  = Garage;           /* Oil */
    locationOfItem[6]  = Kitchen;          /* Candybar */
    locationOfItem[7]  = Driveway2;        /* Bottle */
    locationOfItem[8]  = GirlsBedroom;     /* Doll */
    locationOfItem[9]  = BoysBedroom;      /* ToyCar */
    locationOfItem[10] = ServantsQuarters; /* Matches */
    locationOfItem[11] = Woods25;          /* GoldCoin */
    locationOfItem[12] = Woods29;          /* SilverCoin */
    locationOfItem[13] = DiningRoom;       /* StaleMeat */
    locationOfItem[14] = DrawingRoom;      /* Book */
    locationOfItem[15] = LaundryRoom;      /* Cheese */
    locationOfItem[16] = MasterBedroom;    /* OldRadio */
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
            } else if (buffer[0] == 'H') {
                doHelp();
            } else if (buffer[0] == 'I') {
                doInventory();
            } else if ((buffer[0] == 'G')
                       || !strcmp(buffer, "N") || !strcmp(buffer, "S")
                       || !strcmp(buffer, "E") || !strcmp(buffer, "W")
                       || !strcmp(buffer, "U") || !strcmp(buffer, "D")
                       || !strcmp(buffer, "NORTH") || !strcmp(buffer, "SOUTH")
                       || !strcmp(buffer, "EAST") || !strcmp(buffer, "WEST")
                       || !strcmp(buffer, "UP") || !strcmp(buffer, "DOWN")) {
                doGo();
            } else if (buffer[0] == 'L') {
                doLook();
            } else if (buffer[0] == 'T') {
                doTake();
            } else if (buffer[0] == 'E') {
                doExamine();
            } else if (buffer[0] == 'U') {
                doUse();
            } else if (buffer[0] == 'D') {
                doDrop();
            } else if (buffer[0] == 'Q') {
                doQuit();
            } else if (!strcmp(buffer, "XYZZY")) {
                printf("NICE TRY, BUT THAT WON'T WORK HERE.\n");
            } else {
                printf("I DON'T UNDERSTAND. TRY 'HELP'.\n");
            }

            /* Handle special actons. */
            doActions();
        }

        printf("GAME OVER AFTER %d TURNS.\n", turnsPlayed);
        printf("%s", "DO YOU WANT TO PLAY AGAIN (Y/N)? ");
        fgets(buffer, sizeof(buffer)-1, stdin);
        if (toupper(buffer[0]) == 'N') {
            break;
        }
    }
    return 0;
}
