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
                ; ADDRESS OF THE CURRENT
                ; SCREEN LOCATION.
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
                ; MUST BE INITIALIZED TO HOLD
                ; DATA DESCRIBING THE SCREEN
                ; ON YOUR SYSTEM
;
;
;
;
HOME=PARAMS     ; HOME IS A POINTER TO CHARACTER
                ; POSITION IN UPPER LEFT CORNER.
;
ROWINC=PARAMS+2
                ; ROWINC IS A BYTE GIVING
                ; ADDRESS DIFFERENCE FROM ONE
                ; ROW TO THE NEXT.
;
