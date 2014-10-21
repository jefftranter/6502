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
;                       POSITION ON THE ROW.

      BPL CLRPOS      ; IF NOT DONE WITH ROW,
;                       CLEAR NEXT POSITION...
;
      JSR TVDOWN      ; IF DONE WITH ROW. MOVE
;                       CURRENT SCREEN LOCATION
;                       DOWN BY ONE ROW.
      DEX             ; DONE LAST ROW YET?
      BPL CLRROW      ; IF NOT, CLEAR NEXT ROW...
      RTS             ; IF SO, RETURN TO CALLER.
;
COLS .BYTE 0          ; DATA CELL: HOLDS NUMBER OF
;                       COLUMNS TO BE CLEARED.
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
; ********************************************
;
;          TVHOME
;
; ********************************************
;
;
;
;
;
TVHOME LDX #0       ; SET TV.PTR TO UPPER LEFT
       LDY #0       ; CORNER OF SCREEN, BY
;                     ZEROING X AND Y AND THEN
       CLC          ; GOING TO X,Y COORDINATES:
       BCC TVTOXY
;
;
;
;
; ********************************************
;
;          CENTER
;
; ********************************************
;
;
;
;
;                      SET TV.PTR TO SCREEN'S
;                      CENTER:
;
;
;
;
CENTER LDA TVROWS    ; LOAD A WITH TOTAL ROWS.
       LSR A         ; DIVIDE IT BY TWO.
       TAY           ; Y NOW HOLDS THE NUMBER OF
;                      THE SCREEN'S CENTRAL ROW.
;
       LDA TVCOLS    ; LOAD A WITH TOTAL COLUMNS.
       LSR A         ; DIVIDE IT BY TWO.
       TAX           ; X NOW HOLDS THE NUMBER OF
;                    THE SCREEN'S CENTRAL COLUMN.
;
;
;                    X AND Y REGISTERS NOW HOLD
;                    X,Y COORDINATES OF CENTER
;                    OF SCREEN.
;
;                    SO NOW LET'S SET THE SCREEN
;                    LOCATION TO THOSE X,Y
;                    COORDINATES:
;
;
;
;
;
;
;
;
;
; ********************************************
;
;          TVTOXY
;
; ********************************************
;
;
;
;
;
TVTOXY SEC          ; SET CURRENT SCREEN LOCATION
;                     TO COORDINATES GIVEN BY
;                     THE X AND Y REGISTERS.
;
       CPX TVCOLS   ; IS X OUT OF RANGE?
       BCC XOK      ; IF NOT, LEAVE IT ALONE.
;                     IF X IS OUT OF RANGE, GIVE
       LDX TVCOLS   ; IT ITS HIGHEST LEGAL VALUE.
;                     NOW X IS LEGAL.
;
XOK    SEC          ; IS Y OUT OF RANGE?
       CPY TVROWS
       BCC YOK      ; IF NOT, LEAVE IT ALONE.
;
;                     IF Y IS OUT OF RANGE, GIVE
       LDY TVROWS   ; Y ITS HIGHEST LEGAL VALUE.
;                     NOW Y IS LEGAL.
;
;
YOK    LDA HOME     ; SET TV.PTR = LOWEST SCREEN
       STA TVPTR    ; ADDRESS.
       LDA HOME+1
       STA TVPTR+1
;
       PHP          ; SAVE CALLER'S DECIMAL FLAG.
       CLD          ; CLEAR DECIMAL FOR BINARY
;                     ADDITION.
;
       TXA          ; ADD X TO TV.PTR
       CLC
       ADC TVPTR
       BCC COLSET
       INC TVPTR+1
       CLC
;
;
COLSET CPY #0       ; ADD Y*ROWINC TO TV.PTR:
       BEQ TVSET
ADDROW CLC
       ADC ROWINC
       BCC *+4
       INC TVPTR+1
       DEY
       BNE ADDROW
;
;
TVSET  STA TVPTR
       PLP          ; RESTORE CALLER'S DECIMAL FLAG
       RTS          ; RETURN TO CALLER
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
; ********************************************
;
;          TVDOWN, TVSKIP, and TVPLUS
;
; ********************************************
;
;
;
;
;
TVDOWN LDA ROWINC   ; MOVE TV.PTR DOWN BY ONE ROW.
       CLC
       BCC TVPLUS
;
VUCHAR JSR TVPUT    ; PUT CHARACTER ON SCREEN
;                     AND THEN
;
TVKIP  LDA #1       ; SKIP ONE SCREEN LOCATION
;                     BY INCREMENTING TV.PTR
;
;
TVPLUS PHP          ; TVPLUS ADDS ACCUMULATOR
       CLD          ; TO TV.PTR, KEEPING TV.PRT
       CLC          ; WITHIN SCREEN MEMORY.
       ADC TVPTR
       BCC *+4
       INC TVPTR+1
       STA TVPTR
       SEC          ; IS CURRENT SCREEN LOCATION
       LDA HIPAGE   ; OUTSIDE OF SCREEN MEMORY?
       CMP TVPTR+1
       BCS TVOK
;
       LDA HOME+1    ; IF SO, WRAP AROUND FROM
       STA TVPTR+1   ; BOTTOM TO TOP OF SCREEN
;
TVOK   PLP           ; RESTORE ORIGINAL DECIMAL
       RTS           ; FLAG AND RETURN TO CALLER
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
; ********************************************
;
;       TV.PUT
;
; ********************************************
;
;
;
;
;
;
TVPUT  JSR FIXCHR    ; CONVERT ASCII CHARACTER
;                      TO YOUR SYSTEMS DISPLAY
;                      CODE
;
       LDY #0        ; PUT CHARACTER AT CURRENT
       STA (TVPTR),Y ; SCREEN LOCATION.
       RTS           ; THEN RETURN.
;
;
;
;
;
;
;
;
;
; ********************************************
;
; DISPLAY A BYTE IN HEX FORMAT
;
; ********************************************
;
;
;
;
;
VUBYTE PHA      ; SAVE BYTE TO BE DISPLAYED.
       LSR A    ; MOVE 4 MOST SIGNIFICANT
       LSR A    ; BITS INTO POSITIONS
       LSR A    ; FORMERLY OCCUPIED BY 4
       LSR A    ; LEAST SIGNIFICANT BITS.
;
       JSR ASCII ; DETERMINE ASCII CHAR FOR
;                  HEX DIGIT IN A'S 4 LSB.
;
       JSR VUCHAR ; DISPLAY THAT ASCII CHAR ON
;                   SCREEN AND ADVANCE TO NEXT
;                   SCREEN LOCATION.
;
       PLA        ; RESTORE ORIGINAL BYTE TO A.
       JSR ASCII  ; DETERMINE ASCII CHAR FOR
;                   A'S 4 LSB.
;
       JSR VUCHAR ; STORE THIS ASCII CHAR JUST
;                    TO THE RIGHT OF THE OTHER
;                    ASCII CHAR, AND ADVANCE TO
;                    NEXT SCREEN POSITION.
;
;
       RTS        ; RETURN TO CALLER.
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
; ********************************************
;
;   HEX-TO-ASCII
;
; ********************************************
;
;
;
;
;
ASCII PHP        ; THIS ROUTINE RETURNS ASCII
      CLD        ; FOR 4 LSB IN ACCUMULATOR,
      AND #$0F   ; CLEAR HIGH 4 BITS IN A.
      CMP #$0A   ; IS ACCUMULATOR GREATER
;                  THAN S?
      BMI DECIML ; IF NOT, IT MUST BE 0-9.
;
      ADC #6     ; IF SO, IT MUST BE A-F.
;                  ADD 36 HEX TO CONVERT IT.
;                  TO CORRESPONDING ASCII CHAR.
DECIML ADC #$30  ; IF A IS 0-9, ADD 30 HEX
;                  TO CONVERT IT TO
;                  CORRESPONDING ASCII CHAR.
;
       PLP       ; RESTORE ORIGINAL DECIMAL
;                  FLAG, AND
       RTS       ; RETURN TO CALLER
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
; ********************************************
;
;     TVPUSH
;
; ********************************************
;
;
;
;                  SAVE CURRENT SCREEN LOCATION
;                  ON STACK, FOR CALLER.
;
;
;
;
;
TVPUSH PLA       ; PULL RETURN ADDRESS FROM
       TAX       ; STACK AND SAVE IT IN X AND
       PLA       ; Y REGISTERS.
       TAY
;
;
       LDA TVPTR+1  ; GET TV.PTR AND
       PHA
       LDA TVPTR    ; PUSH IT ONTO THE STACK.
       PHA
;
;
       TYA          ; PLACE RETURN ADDRESS
       PHA
       TXA          ; BACK ON STACK.
       PHA
;
;
       RTS          ; THEN RETURN TO CALLER.
;                     CALLER WILL FIND TV.PTR ON
;                     STACK, LOW BYTE ON TOP.
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
; ********************************************
;
;    TV.POP
;
; ********************************************
;
;
;
;                         RESTORE SCREEN LOCATION
;                         PREVIOUSLY SAVED ON STACK.
;
;
;
;
TVPOP PLA   ; PULL RETURN ADDRESS FROM
      TAX   ; STACK, SAVING IT IN X...
      PLA
      TAY   ; ...AND IN Y
;
;
      PLA         ; RESTORE...
      STA TVPTR   ; ...TV.PTR
      PLA         ;    ...FROM
      STA TVPTR+1 ;       ...STACK.
;
;
      TYA         ; PLACE RETURN ADDRESS
      PHA         ; BACK...
      TXA
      PHA         ; ...ON STACK.
;
;
      RTS        ; RETURN TO CALLER.
