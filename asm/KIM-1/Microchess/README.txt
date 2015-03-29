This is a port of the source code for Microchess for the KIM-1 to the
CC65 assembler.

Microchess for the Kim-1, written by Peter Jennings, was the first
game program sold for home computers: a chess program that ran in 1K
of RAM. It was released in 1976.

For details, see: http://www.benlo.com/microchess/index.html

--------

MICROCHESS QUICK REFERENCE

Start address: $0000

       Computer
+--+--+--+--+--+--+--+--+
|00|01|02|03|04|05|06|07|       Keys:
+--+--+--+--+--+--+--+--+
|10|11|12|13|14|15|16|17|  [GO] Start program or restart after exit
+--+--+--+--+--+--+--+--+
|20|21|22|23|24|25|02|02|  [ST] Enter KIM monitor to change board.
+--+--+--+--+--+--+--+--+
|30|31|32|33|34|35|36|37|  [C] Clear board to begin a new game.
+--+--+--+--+--+--+--+--+
|40|41|42|43|44|45|46|47|  [E] Exchange computer and player's pieces.
+--+--+--+--+--+--+--+--+
|50|51|52|53|54|55|56|57|  [F] Move piece from FROM to TO square.
+--+--+--+--+--+--+--+--+
|60|61|62|63|64|65|66|67|  [PC] Instruct computer to play a move.
+--+--+--+--+--+--+--+--+
|70|71|72|73|74|75|76|77|
+--+--+--+--+--+--+--+--+
        PLAYER

Computer's Move Display:

0P FF TT

P - piece (see below)  FF - from square  TT - to square

0 - King        4 - King Bishop   8 - K R Pawn  C - K B Pawn     
1 - Queen       5 - Queen Bishop  9 - Q R Pawn  D - Q B Pawn
2 - King Rook   6 - King Knight   A - K N Pawn  E - Q Pawn
3 - Queen Rook  7 - Queen Knight  B - Q N Pawn  F - K Pawn

Entering Player's Move: FF (from square) TT (to square)

Displays: XP FF TT

X - (see below)  P - piece  FF - from square  TT - to square

0 - computer's piece
1 - player's piece
F - empty square
