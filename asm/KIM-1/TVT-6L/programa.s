; A.Program for a 16 line, 32 character per line interlaced
; TVT-6L Raster Scan:
;
; uP - 6502       Start - JMP 17A6  Displayed 0200-03FF
; System - KIM-1  End - Interrupt   Program Space 1780-17d4
;
; Upper Address (178A)     Lower Address (1789)
;  |*|*|*|*|0|0|1|V8|   |V4|V2|V1|H16|H8|H4|H2|H1|

        SCAN = $2000            ; SCAN PROM

        .org    $1780

l1780:  CLC                     ; Clear Carry
l1781:  STA     $178A           ; Store Upper Address
        PHA                     ; Equalize 10 microseconds
        PLA                     ;   continued

        BNE     l1788           ;   continued
l1788:  JSR     SCAN            ; ///Character Scans 0-11///
        ADC     #$10            ; Increment Character Scan Counter
        CMP     #$E0            ; Character Scan Counter Overflow?

        BCC     l1781           ; No, Scan next row of character
        TAX                     ; Save Upper Address
        LDA     l1788+1         ; Get Lower Address
        ADC     #$1F            ; Increment Lower Address; Save carry

        STA     l1788+1         ; Restore Lower Address; Save carry
        TXA                     ; Get Upper Address
        ADC     #$40            ; Reset Upper Address; add carry
        BNE     l179f           ; Equalize 3 microseconds

l179f:  JSR     SCAN+4          ; ///Blank Character Scan 12///
        CMP     #$24            ; Is it the "17th" row of characters?
        BCC     l1780           ; No, start a new row of characters
START:  LDA     $EC             ; Get Interlace Word

        ADC     #$7F            ; Change Field via Carry bit
        BCS     l17b1           ; Jump if Even Field
        STA     $E0EC           ; Odd Field V Sync; Restore Interlace
        LDX     #$36            ; Load Off (Short) # of blank scans

l17b1:  LDY     #$05            ; Equalize 31 microseconds
l17b3:  DEY                     ;  continued
        BPL     l17b3           ;  continued
        BCC     l17bd           ; Jump if odd field

        STA     $E0EC           ; Even Field V Sync; Restore Interlace
        LDX     #$37            ; load Even (long) # of blank scans
l17bd:  JSR     SCAN+$1E        ; ///1st V Blanking scan///
        PHA                     ; Equalize 9 microseconds

        PLA                     ;  continued
l17c2:  CLD                     ;  continued
        LDA     #$00            ; Initialize Lower Address
        STA     l1788+1         ;  continued

        LDA     #$22            ; Initialize Upper Address
        STA     l1788+2         ;  continued
        JSR     SCAN            ; ///Rest of V Blanking scans///
        DEX                     ; One less scan

        BMI     l1780           ; Start Character Scan
        BPL     l17c2           ; Repeat V Blanking Scan

; NOTES:  TVT-6L must be connected and both the SCAN and DECODE
;         PROMS must be in circuit for program to run.
;
;         Both 17AC and 17b8 require that page 00 be enabled when
;         page E0 is addressed. This is done automatically in
;         the KIM-1 decode circuitry.
;
;         Location 00EC on page zero is reserved as an interlace storage
;         bit.
;
;         Step 1788 goes to where the upper address stored in 178A and
;         the lower address stored in 1789 tells it to. Values in
;         these slots continuously change throughout the program.
;
;         For a 525 line system, use 17b0 34 and 17bC 35 and a KIM-1
;         crystal of 992.250 kHz. This is ONLY needed for a video
;         superposition or titling applications; the stock 1 MHz
;         crystal is used for ALL OTHER uses.
;
;         Normal program horizontal frequency is 15,783.015 kHz;
;          Vertical 60.0114. 63 microseconds per line, 264.5 lines
;          per field; 2 fields per frame 529 lines total.
;
;         TVT-6L switch must be i the "32" position.
;
;         ( ) Denotes an absolute address that is program location
;              sensitive.
;
;         * Denotes a relative branch that is program length sensitive.
;
;         TO DISPLAY OTHER PAGES, USE:
;
;         PAGES                   TVT
;         DISPLAYED   17A3  17C9  CONNECTION
;         0000-01FF   22    20    KIM-1
;         0200-03FF   24    22    KIM-1
;         0400-05FF   26    24    KIM-2
;         0600-07FF   28    26    KIM-2
;
;         0800-09FF   2A    28    KIM-2
;         0A00-0BFF   2C    2A    KIM-2
;         0C00-0DFF   2E    2C    KIM-2
;         0E00-0FFF   30    2E    KIM-2
;
;         FOR HIGHER PAGES, MOVE CONTENTS TO 0200-03FF
;         or 0400-05FF
