;  APPENDIX C15: ASSEMBLER LISTING OF
;          SYSTEM DATA BLOCK
;      FOR THE APPLE II
;
;
;
;
;     SEE APPENDIX B3 OF BEYOND GAMES: SYSTEM
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
HOME    .WORD   $0400   ; THIS IS THE ADDRESS OF THE
                        ; CHARACTER IN THE UPPER LEFT
                        ; CORNER OF THE SCREEN.
                        ; (WHEN YOU ARE DISPLAYING
                        ; LOW-RESOLUTION GRAPHICS AND
                        ; TEXT PAGE 1.)
ROWINC  .BYTE   $80     ; ADDRESS DIFFERENCE FROM ONE
                        ; ROW TO THE NEXT
TVCOLS  .BYTE   39      ; NUMBER OF COLUMNS ON SCREEN,
                        ; STARTING FROM ZERO.
TVROWS  .BYTE   7       ; NUMBER OF ROWS ON SCREEN,
                        ; STARTING FROM ZERO.
HIPAGE  .BYTE   $07     ; HIGHEST PAGE IN SCREEN MEMORY.
                        ; (WITH LOW-RES PAGE 1 SELECTED.)
BLANK   .BYTE   $A0     ; APPLE II DISPLAY CODE FOR
                        ; A BLANK: A DARK BOX, USED AS
                        ; AS SPACE WHEN APPLE II IS IN
                        ; NORMAL DISPLAY MODE (WHITE
                        ; CHARACTERS ON A DRAK BACKGROUND.)
ARROW   .BYTE   $DE     ; APPLE II DISPLAY CODE FOR
                        ; A CARET (USED BECAUSE APPLE
                        ; II HAS NO UP-ARROW.)
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
;           INPUT/OUTPUT VECTORS
;
; *********************************************
;
;
;
;
;
;
ROMKEY  .WORD   APLKEY ; POINTER TO ROUTINE THAT GETS
                        ; AS ASCII CHARACTER FROM THE
                        ; KEYBOARD.  (NOTE APLKEY
                        ; CALLS A ROM SUBROUTINE, BUT
                        ; APLKEY IS NOT AN APPLE ROM
                        ; SUBROUTINE.
;
;
ROMTVT  .WORD   APLTVT  ; POINTER TO ROUTINE TO PRINT
                        ; AN ASCII CHARACTER ON THE SCREEN
;
;
ROMPRT  .WORD   DUMMY   ; POINTER TO ROUTINE TO SEND AN
                        ; ASCII CHARACTER TO THE PRINTER
                        ; (SET TO DUMMY UNTIL YOU MAKE
                        ; IT POINT TO THE CHARACTER-
                        ; OUTPUT ROUTINE THAT DRIVES
                        ; YOUR PRINTER.)
                        ;      YOU MAY WISH TO
                        ; SET ROMPRT SO IT POINTS TO
                        ; $FDED. THE APPLE II'S
                        ; GENERAL CHARACTER OUTPUT
                        ; ROUTINE. $FDED WILL PRINT TO
                        ; A PRINTER IF YOU TELL
                        ; YOUR APPLE II ROM SOFTWARE
                        ; TO SELECT  YOUR PRINTER AS
                        ; AN OUTPUT DEVICE.  DO THAT
                        ; IN BASIC BY TYPING "PR #N",
                        ; WHERE N IS THE NUMBER OF THE
                        ; SLOT HOLDING THE CIRCUIT CARD
                        ; THAT DRIVES YOUR PRINTER.
;
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
FIXCHR  ORA #$80        ; SET BIT 7, SO CHARACTER
                        ; WILL DISPLAY IN NORMAL MODE.
        RTS             ; RETURN.
;
;
;
;
;
; *********************************************
;
;    GET AN ASCII CHARACTER FROM THE KEYBOARD
;
; *********************************************
;
;
;
;
APLKEY   JSR $FD35      ; GET KEYBOARD CHARACTER WITH
                        ; BIT 7 SET.
         AND #$7F       ; CLEAR BIT 7.
;
         RTS            ; RETURN WITH ASCII CHARACTER
                        ; FROM THE KEYBOARD
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
;    PRINT AN ASCII CHARACTER ON THE SCREEN
;
; *********************************************
;
;
;
;
;
APLTVT   ORA #$80       ; SET BIT 7 SO CHARACTER WILL
                        ; PRINT IN NORMAL MODE.
         JSR $FBFD      ; CALL APPLE II ROM ROUTINE TO
                        ; PRINT A CHARACTER TO SCREEN.
         RTS            ; RETURN TO CALLER.
