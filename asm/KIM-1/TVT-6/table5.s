; Table V
;
; CRUNCHER THE BEAR Program for a 32 line X 64 character per
; line TVT6 raster Scan:
;
; uP - 6502       Start - JMP 17C0  Displayed 0000-07FF
; System - KIM-1  End - Interrupt   Program Space 1780-17dA
;
; +--+--+--+--+--+-+-+--+--+  +--+--+---+---+--+--+--+--+
; |HS|VS|L4|L2|L1|V16|V8|V4|  |V2|V1|H32|H16|H8|H4|H2|H1|
; +--+--+--+--+--+-+-+--++--  +--+--+---+---+--+--+--+--+
;       Upper Address            Lower Address

        SCAN = $8000    ; Start address of SCAN PROM

        .org    $1780

l1780:  LDA     #$80            ; Initialize Upper Address
l1782:  STA     l1785+2         ; Store Upper Address
l1785:  JSR     SCAN            ; ////Character Scans 0-7////
        ADC     #$10            ; Increment Character Gen by 2

        CMP     #$C0            ; Is S= 1?
        BCC     l1782           ; No, Do next character scan
        PHA                     ; Save Upper Address
        LDA     l1785+1         ; Get Lower address

        ADC     #$3F            ; Increment L; Set Carry on V2 overflow
        STA     l1785+1         ; Restore L; Save carry
        PLA                     ; Get Upper Word
        JSR     SCAN+$0C        ; ////Character Scans 8,9 ////

        ADC     #$C0            ; Add Carry; Reset Upper Address
l179d:  CMP     #$88            ; Is it "Line 33"?
        BCC     l1782           ; No, repeat Character Scans
        LDA     l1780+1         ; Get Interlace word

        ADC     #$78            ; Set Carry if Odd Field finished
        BCC     l17b4           ; Start Even Field if Carry Clear
        LDX     #$22            ; Load Even number of V Scans -2
        LDA     #$80            ; Load Even Field Upper Start

        STA     $5781           ; Even Field V Sync + Restore Interlace
        LDA     #$88            ; Even Field Line 33 CMP Value
        STA     l179d+1         ; Store Even 33 CMP value
l17b4:  LDA     #$00            ; Clear Accumulator

        STA     l1785+1         ; Initialize Lower Address
        LDY     #$06            ; Equalize 31 cycles
l17bb:  DEY                     ; continued
        BPL     l17bb           ; continued

        BCS     l17cc           ; Jump if even field
START:  LDA     #$88            ; Load Odd Field Upper Start
        STA     $5781           ; Odd Field V Sync + Restore Interlace
        LDA     #$90            ; Odd Field line 33 CMP Value

        STA     l179d+1         ; Store Odd 33 CMP Value
        LDX     #$23            ; Load Odd number of V Scans
l17cc:  JSR     SCAN+$3F        ; //// 1st V Blanking Scan ////
        PHA                     ; Equalize 7

        PLA                     ; continued
l17d1:  CLD                     ; Equalize 4
        CLC                     ; continued
        JSR     SCAN            ; //// Other V Blanking Scans ////

        DEX                     ; One Less scan
        BMI     l1780           ; Start Character Scans
        BPL     l17d1           ; Repeat V Blanking Scan

; NOTES:  TVT6 must be connected and scan microprogram PROM IC1
;         must be in circuit for program to run.  TVT5 length
;         jumper must be in the "64" position.
;
;         Step 1785 goes to where the upper address stored in 1787
;         and the lower address in 1789 tells it to.  Values
;         in these slots continuously change throughout the program.
;
;         Step 1781 is 80 for even fields and 88 for odd fields.
;         Step 179E is 88 for even fields and 90 for odd fields.
;
;         Both 17AC and 17C2 require that page 17 be enabled when
;         page 57 is addressed.  This is done automatically with
;         KIM-1 circuitry.
;
;         Note that 2K worth of contiguous memory from 0000 to 07FF
;         is needed. This takes a KIM-1 modification. Both sets of
;         1k words must share a common upstream tap but be
;         separately enabled.
;
;         Normal program horizontal frequency is 11,764,705 Hz.
;         Vertical Frequency is 59.8712 Hz. For 60 Hz vertical
;         use 1.002150 MHz crystal.  85 us per line; 196.5
;         interlaced lines per field; two fields per frame.  One us
;         character time, 160 active lines per field.  Needs TV
;         set adjustment and possible modification (hold and width).
;
;         * Denotes a relative branch that is program length sensitive.
;
;         ( ) Denotes an absolute address that is program location
;         sensitive.
