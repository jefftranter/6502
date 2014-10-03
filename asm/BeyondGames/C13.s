;  APPENDIX C13: ASSEMBLER LISTING OF
;          SYSTEM DATA BLOCK
;      FOR THE OHIO SCIENTIFIC C-1P
;
;
;
;
;     SEE APPENDIX B1 OF BEYOND GAMES: SYSTEM
; SOFTWARE FOR YOUR 6502 PERSONAL COMPUTER
;
;
;                   BY KEN SKIER
;
;
;
;
;
;
;
;
;
;
;
;
; *********************************************
;
;           SCREEN PARAMETERS
;
; *********************************************
;
;
;
;
;
        *=$1000
;
;
;
;
;
HOME    .WORD   $D065   ; THIS IS THE ADDRESS OF THE
                        ; CHARACTER IN THE UPPER LEFT
                        ; CORNER OF THE SCREEN.  THE
                        ; ADDRESS OF HOME WILL VARY AS
                        ; A FUNCTION OF YOUR VIDEO MONITOR
                        ; I SET MINE TO $D065.  IF YOU
                        ; CAN'T SEE THE VISIBLE MONITOR
                        ; DISPLAY, ADJUST THE LOW BYTE.
;
;
;
ROWINC  .BYTE   32      ; ADDRESS DIFFERENCE FROM ONE
                        ; ROW TO THE NEXT
TVCOLS  .BYTE   $18     ; NUMBER OF COLUMNS ON SCREEN,
                        ; STARTING FROM ZERO.
TVROWS  .BYTE   $18     ; NUMBER OF ROWS ON SCREEN,
                        ; STARTING FROM ZERO.
HIPAGE  .BYTE   $D3     ; HIGHEST PAGE IN SCREEN MEMORY.
BLANK   .BYTE   $20     ; OSI DISPLAY CODE FOR A BLANK.
ARROW   .BYTE   $10     ; OSI DISPLAY CODE FOR AN UP-ARROW.
;
;
;
;
;
;
;
;
;
; *********************************************
;
;           INPUT/OUTPUT VECTORS
;
; *********************************************
;
;
;
;
;
;
ROMKEY  .WORD   $FEED   ; POINTER TO ROUTINE THAT GETS
                        ; AS ASCII CHARACTER FROM THE
                        ; KEYBOARD.  (NOTE $FFEB IS
                        ; THE GENERAL CHARACTER-INPUT
                        ; ROUTINE FOR OSI BASIC-IN-ROM
                        ; COMPUTERS.
;
;
ROMTVT  .WORD   $BF2D   ; POINTER TO ROUTINE TO PRINT
                        ; AN ASCII CHARACTER ON THE SCREEN
                        ; (NOTE: $FFEE IS THE
                        ; CHARACTER-OUTPUT ROUTINE FOR
                        ; OSI BASIC-IN-ROM COMPUTERS.)
;
;
ROMPRT  .WORD   $FCB1   ; POINTER TO ROUTINE TO SEND AN
                        ; ASCII CHARACTER TO THE PRINTER
                        ; (ACTUALLY, TO THE CASSETTE PORT.)
;
;
USROUT  .WORD   DUMMY   ; POINTER TO USER-WRITTEN OUTPUT
                        ; ROUTINE.  (SET HERE TO DUMMY
                        ; UNTIL YOU SET IT TO POINT
                        ; TO YOUR OWN CHARACTER-OUTPUT
                        ; ROUTINE.)
;
;
DUMMY   RTS             ; THIS IS A DUMMY SUBROUTINE.
                        ; IT DOES NOTHING BUT RETURN.
;
;
;
;
;
; *********************************************
;
;      CONVERT ASCII CHARACTER TO DISPLAY CODE
;
; *********************************************
;
;
;
;
;
FIXCHR  RTS             ; SINCE OSI DISPLAY CODES ARE
                        ; THE SAME AS THE CORRESPONDING
                        ; ASCII CHARACTERS, NO CONVERSION
                        ; IS NECESSARY. FIXCHR IS A DUMMY.
