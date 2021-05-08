; TABLE IV
;
; 16 line X 64 character per line TVT6 Raster Scan:
;
; uP - 6502       Start - JMP 17AA  Displayed 0000-03FF
; System - KIM-1  End - Interrupt   Program Space 1780-17be
;
; +--+--+--+--+--+-+--+--+  +--+--+---+---+--+--+--+--+
; |HS|VS|L4|L2|L1|0|V8|V4|  |V2|V1|H32|H16|H8|H4|H2|H1|
; +--+--+--+--+--+-+--+--+  +--+--+---+---+--+--+--+--+
;       Upper Address            Lower Address

        SCAN = $8000            ; Start address of SCAN PROM

        .org    $1780

l1780:  LDA     #$80            ; Initialize Upper Address
l1782:  STA     l1785+2         ; Store Upper Address
l1785:  JSR     SCAN            ; ////Character Scans 1-8////
        ADC     #$08            ; Increment character scan counter  

        CMP     #$C0            ; is VS = 1?
        BCC     l1782           ; No, Do next character scan
        TAX                     ; Save Upper Address
        LDA     l1785+1         ; Get lower address

        BCS     l1794           ; Equalize 3 cycles
l1794:  JSR     SCAN+4          ; ////Character Scan 9////
        BCS     l1799           ; Equalize 3 cycles
l1799:  ADC     #$3F            ; Increment lower; Set C on V2 overflow

        STA     l1785+1         ; Restore Lower Address; save carry
        TXA                     ; Get upper address
        JSR     SCAN            ; ////Character Scan 10////
        ADC     #$C0            ; Add Carry; Reset VS

        CMP     #$84            ; It is "Line 17"?
l17a6:  BCC     l1782           ; No, continue character scans
        BCS     START           ; Yes, go to vertical blanking scans
START:  CLD                     ; Equalize 2 cycles

        JSR     SCAN+$4000      ; ////Vertical Sync Scan////
        LDX     #$22            ; Load #V Blank Scans -2
        LDA     #$00            ; Initialize Lower Address
        STA     l1785+1         ; Continued

l17b5:  CLC                     ; Equalize 2 cycles
        BCS     l17b8           ; Equalize 2 cycles again
l17b8:  JSR     SCAN            ; ////Vertial Blanking Scans////
        DEX                     ; One less scan

        BMI     l1780           ; Start Character Scan
        BPL     l17b5           ; Repeat Vertical Blanking scans

; NOTES:  TVT6 must be connected and scan microprogram PROM (IC1)
;         must be in circuit for program to run.
;
;         Steps 1785 goes to where the upper address stored in 1787
;         and the lower address stored in 176 tells it to.  Values
;         in these slots continuously change through the program.
;
;         Normal program horizontal frequency is 11,764,605 Hz.
;         Vertical frequency is 60.024 Hz.  85 us per line;
;         192 lines.  Character time 1 us.  160 active lines,
;         36 retrace.  Needs TV set adjustment and possible modification
;         (hold and width).
;
;         * Denotes a relative branch that is program length
;         sensitive.
;
;         ( ) Denotes an absolute address that is program location sensitive.
;
;         TVT6 length jumper must be in the "64" position.
