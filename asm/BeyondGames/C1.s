;     APPENDIX C1: ASSEMBLER LISTING OF
;                   SCREEN UTILITIES
;
;
;
;       SEE CHAPTER 5 OF BEYOND GAMES: SYSTEMS
; SOFTWARE FOR YOUR 6502 PERSONAL COMPUTER
;
;
;                     BY KEN SKIER
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
;          ZERO PAGE BYTES
;
; *********************************************
;
;
;
;
;
TVPTR=0         ; THIS POINTER HOLDS THE
;                 ADDRESS OF THE CURRENT
;                 SCREEN LOCATION.
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
;          SCREEN PARAMETERS
;
; *********************************************
;
;
;
PARAMS=$1000    ; THE FOLLOWING ADDRESSES
;                 MUST BE INITIALIZED TO HOLD
;                 DATA DESCRIBING THE SCREEN
;                 ON YOUR SYSTEM
;
;
;
;
HOME=PARAMS     ; HOME IS A POINTER TO CHARACTER
;                 POSITION IN UPPER LEFT CORNER.
;
ROWINC=PARAMS+2
;                 ROWINC IS A BYTE GIVING
;                 ADDRESS DIFFERENCE FROM ONE
;                 ROW TO THE NEXT.
;
TVCOLS=PARAMS+3
;                 TVCOLS IS A BYTE GIVING
;                 NUMBER OF COLUMNS ON SCREEN.
;                 (COUNTING FROM ZERO.)
;
TVROWS=PARAMS+4
;                 TVROWS IS A BYE GIVING
;                 NUMBER OF ROWS ON SCREEN.
;                 (COUNTING FROM ZERO.)
;
HIPAGE=PARAMS+5
;                 HIPAGE IS THE HIGH BYTE OF
;                 THE HIGHEST ADDRESS ON SCREEN.
;
BLANK=PARAMS+6  ; YOUR SYSTEM'S CHARACTER CODE
;                 FOR A BLANK
;
ARROW=PARAMS+7  ; YOUR SYSTEM'S CHARACTER
;                 FOR AN UP-ARROW.
;
FIXCHR=PARAMS+$11
;                 FIXCHR IS A SUBROUTINE THAT
;                 RETURNS YOUR SYSTEM'S
;                 DISPLAY CODE FOR ASCII.
;                 CODE.
;
;
;
;
;
*=$1100
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
;          CLEAR SCREEN
;
; *********************************************
;
;
;
;
;
;
;        CLEAR SCREEN, PRESERVING THE ZERO PAGE
;
;
;
;
CLRTV JSR TVPUSH        ; SAVE ZERO PAGE BYTES THAT
;                         WILL BE CHANGED.
      JSR TVHOME        ; SET SCREEN LOCATION TO UPPER
;                         LEFT CORNER OF THE SCREEN.
      LDX TVCOLS        ; LOAD X,Y REGISTERS WITH
      LDY TVROWS        ; X,Y DIMENSIONS OF SCREEN.
      JSR CLRXY         ; CLEAR X COLUMNS, Y ROWS
;                         FROM CURRENT SCREEN LOCATION.
      JSR TVPOP         ; RESTORE ZERO PAGE BYTES THAT
;                         WERE CHANGED.
      RTS               ; RETURN TO CALLER, WITH ZERO
;                         PAGE PRESERVED.
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
;          CLEAR PORTION OF SCREEN
;
; *********************************************
;
;
;
;
;                     CLEAR X COLUMNS, Y ROWS
;                     FROM CURRENT SCREEN LOCATION.
;                     MOVES TCPTR DOWN BY Y ROWS.
;
;
;
CLRXY STX COLS        ; SET THE NUMBER OF COLUMNS
;                       TO BE CLEARED.
      TYA
      TAX             ; NOW X HOLDS NUMBER OF ROWS
;                       TO BE CLEARED.
;
CLRROW LDA BLANK      ; WE'LL CLEAR THEM BY
;                       WRITING BLANKS TO THE
;                       SCREEN.
      LDY COLS        ; LOAD Y WITH NUMBER OF
;                       COLUMNS TO BE CLEARED.
CLRPOS STA (TVPTR),Y  ; CLEAR A POSITION BY
;                       WRITING A BLANK INTO IT.
;
      DEY             ; ADJUST INDEX FOR NEXT





COLS
TVPOP
TVHOME
TVPUSH
