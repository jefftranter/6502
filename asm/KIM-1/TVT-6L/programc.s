; C.Program for a Four-in-One full performance Scrolling Cursor:
;
; uP - 6502          Start - IRQ  Program Space 0100-01dF
; System - Kim 1,2   End - RTI       + Two words page zero (ED,EF)
;
; Input to parallel Word A
; |0|A7|A6|A5|A4|A3|A3|A1| -|_|- IRQ
;                         ->| |<- 10 usec.
;
; Clear - CAN (18)           Cursor Right - HT (09)
; Carriage Return - CR (0d)  Cursor Home - SOH (0A)
; Cursor Up - VT (0b)        Scroll Up - DC1 (11)
; Cursor Down - LD (0A       Erase To End - ETX (03)
; Cursor Left - BS (08)      Enter - all characters and all unused CTRL commands
;

        CURSOR = $ED

        .org    $0100

; Enter via IRQ

        PHA                     ; Save A
        LDY     #$00            ; Reset Y index
        LDA     CURSOR+1        ; Get Cursor and test for range
        CMP     #$04            ; Is cursor below maximum?

        BCS     l0147           ; No, Home Cursor
        CMP     #$02            ; Is cursor above maximum?
        BCC     l0147           ; No, Home cursor
        LDA     (CURSOR),Y      ; Get old Cursed character

        AND     #$7F            ; Erase Old Cursor
        STA     (CURSOR),Y      ; Replace character without cursor
        LDA     $1700           ; Get New character from A parallel Int.
        CMP     #$20            ; Is it a character to be entered?

        BCS     l013e           ; Yes, go and enter character
        CMP     #$18            ; Clear Screen?
        BEQ     l015e           ; Yes, go clear screen
        CMP     #$0D            ; Return carriage?

        BEQ     l0152           ; Yes, go return carriage
        CMP     #$0B            ; Move cursor up?
        BEQ     l0194           ; Yes, move cursor up
        CMP     #$0A            ; Move Cursor down?

        BEQ     l0166           ; Yes, move cursor down
        CMP     #$09            ; Move cursor right?
        BEQ     l0158           ; Yes, move cursor right
        CMP     #$08            ; Move Cursor left?

        BEQ     l01a7           ; Yes, Move cursor to left
        CMP     #$01            ; Home Cursor?
        BEQ     l0147           ; Yes, Home cursor
        CMP     #$11            ; Scroll Up?

        BEQ     l0175           ; Yes, Scroll Up
        CMP     #$03            ; Erase to End of Screen?
        BEQ     l01b1           ; Yes, Erase to End of Screen
l013e:  CLD                     ; Assure Hex arithmetic mode

        JSR     l01d3           ; ////Enter Character via Sub////
l0142:  BNE     l014a           ; Did Screen Overflow?
        JMP     l0175           ; Select Scroll or Wraparound
l0147:  JSR     l01c2           ; ////Home cursor via sub////

l014a:  LDA     (CURSOR),Y      ; ////Restore Cursor////
        ORA     #$80            ; Add Cursor to cursed character
        STA     (CURSOR),Y      ; Restore cursed character
        PLA                     ; Restore Accumulator

        RTI                     ; Return to Scan
l0152:  LDA     CURSOR          ; ////Carriage Return///(get cursor)
        ORA     #$1F            ; Move cursor all the way right
        STA     CURSOR          ; Restore cursor

l0158:  JSR     l01d5           ; Increment cursor
        JMP     l0142           ; Scroll or wraparound if needed; finish
l015e:  JSR     l01c2           ; ////Clear/////(home cursor)
        JSR     l01cb           ; clear screen via subroutine

        BEQ     l0147           ; Finish
l0166:  LDA     CURSOR          ; ////Cursor Down////(get cursor)
        CLC                     ; Clear Carry
        ADC     #$20            ; Move cursor down one line

        STA     CURSOR          ; Restore Cursor
l016d:  BCC     l0172           ; Overflow of page?
        JSR     l01d9           ; Yes, increment next higher page
l0172:  JMP     l0142           ; Scroll or wraparound if needed; finish

l0175:  JSR     l01c2           ; /////Scroll Up////(home cursor)
l0178:  LDY     #$20            ; Add offset to index
        LDA     (CURSOR),Y      ; Get offset indexed character
        LDY     #$00            ; Remove offset from index

        JSR     l01d3           ; Enter moved characters and increment
        BNE     l0178           ; Repeat?
        CLC                     ; Clear Carry
l0184:  LDA     #$03            ; Set A to page of last line

        STA     CURSOR+1        ; Set Cursor to page of last line
        LDA     #$E0            ; Load A to start of last line
        STA     CURSOR          ; Set Cursor to start of last line
        BCS     l014a           ; Finish if carry set

        JSR     l01cb           ; Clear last line
        SEC                     ; Set Carry
        BCS     l0184           ; Restore cursor to start of last line
l0194:  LDA     CURSOR          ; /////Cursor Up///(get cursor)

        SEC                     ; Set Carry
        SBC     #$20            ; Move Up one line
        STA     CURSOR          ; Restore Cursor
        BCS     l014a           ; Underflow of page?

l019d:  DEC     CURSOR+1        ; Yes, Decrement page
        LDA     #$01            ; Set A to page below home page
        CMP     CURSOR+1        ; Did screen underflow?
        BNE     l014a           ; No, Finish

        BEQ     l0147           ; Yes, Home cursor
l01a7:  DEC     CURSOR          ; ///Cursor Left///(decrement cursor)
        LDA     #$FF            ; Set A to page underflow
        CMP     CURSOR          ; Test for page underflow

        BEQ     l019d           ; Change page if off page
        BNE     l014a           ; Finish if on page
l01b1:  LDA     CURSOR+1        ; /////Erase to EOS///(get cursor)
        PHA                     ; Save Upper Cursor location on stack

        LDA     CURSOR          ; Get Lower Cursor location
        PHA                     ; Save Lower Cursor location on stack
        JSR     l01cb           ; Clear to End of Screen
        PLA                     ; Get lower cursor location off stack

        STA     CURSOR          ; Restore lower cursor
        PLA                     ; Get upper cursor location off stack
        STA     CURSOR+1        ; Restore upper cursor
        BNE     l014a           ; Finish

l01c2:  LDA     #$00            ; ///Subroutine-HOME CURSOR////
        STA     CURSOR          ; Set lower cursor home value
        LDA     #$02            ; Load A with home page value
        STA     CURSOR+1        ; Set upper cursor to home page

        RTS                     ; Return to main cursor program
l01cb:  LDA     #$20            ; ///Subroutine-ENTER SPACES////
        JSR     l01d3           ; Enter space via character entry sub
        BNE     l01cb           ; Repeat of not to end of screen

        RTS                     ; Return to main cursor program
l01d3:  STA     (CURSOR),Y      ; ///Subroutine-ENTER AND INCREMENT///
l01d5:  INC     CURSOR          ; Enter character and increment
        BNE     l01df           ; Overflow of page?

l01d9:  INC     CURSOR+1        ; Yes, increment cursor page
        LDA     #$04            ; Load A with page above display
        CMP     CURSOR+1        ; Test for Overflow
l01df:  RTS                     ; Return to main cursor program

; NOTES: For auto-scrolling use 0145 75. For wraparound, use 0145 47.
;
;        IRQ vector must be stored in 17FE 00 and 17FF 01.
;
;        Total available stack length is 32 words. Approximately
;         16 are used by operating system, cursor, and scan program.
;         Stack must be initialized to 01FF as is done in KIM
;         operating system. For 30 additional stack locations,
;         relocate subroutine starting at 01C2 elsewhere. For
;         total stack availability, relocate entire program elsewhere.
;
;        To protect page, load 00F1 04. To enable entry, load 00F1 00
;
;        Cursor address is stored at 00ED low and 00EE high on
;         page zero.
;
;        To display cursor, load 014D 80. To not display cursor, load
;         014D 00
;
;        * Denotes a relative branch that is program length sensitive.
;
;        ( ) Denotes an absolute address that is program location
;            sensitive.
;
;        To match this program to the scan program, change the following
;         slots:
;
;     16 x 32     16 x 32     13 x 64     25 x 64
;      KIM1        KIM2        KIM2        KIM2
;    0200-03FF   0400-05FF   04C0-07FF    04C0-0AFF
;
; 0106  04          06          08           0B
; 010A  02          04          04           04
; 0155  1F          1F          3F           3F
; 016A  20          20          40           40
;
; 0179  20          20          40           40
; 0185  03          05          07           0A
; 0189  E0          E0          C0           C0
; 0198  20          20          40           40
;
; 01A0  01          03          03           03
; 01C3  00          00          C0           C0
; 01C7  02          04          04           04
; 01DC  04          06          08           0B
