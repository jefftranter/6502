; B.Program for a 13 line or a 25 line, 54 character per line
; interlaced ; TVT-6L Raster Scan:
;
; uP - 6502         Start - JMP 17bF  Displayed 04C0-0AFF
; System - KIM-1,2  End - Interrupt   Program Space 1780-17E2
;
; Upper Address (178)     Lower Address (1787)
; |*|*|*|*|PH|PL|V8|V4|   |V2|V1|H32|H16|H8|H4|H2|H1|
;
; 0.1,F   - normal program (no tvt)       Tape Ident - 6B
; 2       - blank scan                    Program Length 99 words +
; 3       - scan row 1                       1 word page zero (EC)
; 4       - scan row 2
; ...etc  ..........
; d       - scan row 11
; E       - vertical sync pulse

        SCAN = $2000            ; SCAN PROM

        .org    $1780

l1780:  LDA     #$24            ; Initialize Upper Address
l1782:  STA     l1786+2         ; Store Upper Address
        NOP                     ; Equalize 2
l1786:  JSR     SCAN            ; ///Character Scans 0-11////

        ADC     #$20            ; Increment Character Gen by 2
        CMP     #$E0            ; Is it scan 12 or 13?
        BCC     l1782           ; No, Do next character scan
        PHA                     ; Save Upper Address

        LDA     l1786+1         ; Get Lower Address
        ADC     #$3F            ; Increment L; Set C on V2 Overflow
        STA     l1786+1         ; Restore L; save carry
        PLA                     ; Get Upper Word

        NOP                     ; Equalize 2
        JSR     SCAN+$0C        ; ///Blank scans 12,13///
        ADC     #$40            ; Add Carry; Reset Upper Address
l179f:  CMP     #$2b            ; Was this the last line of characters?

        BCC     l1782           ; No, Scan a new line of characters
        LDA     $EC             ; Get Interlace Word
        ADC     #$7F            ; Set Carry if Off Field Finished
        BCC     l17b8           ; Start Even Field if Carry Set

        STA     $E0EC           ; Even V Sync + Replace Interlace
        LDX     #$0E            ; Load Even # VB Scans -2
        LDA     #$24            ; Initialize Even Upper Case
        STA     l1780+1         ;  continued

        LDA     #$2b            ; Initialize Even Character End Compare
        STA     l179f+1         ;  continued
l17b8:  LDY     #$07            ; Equalize 41 microseconds
l17ba:  DEY                     ;  continued

        BPL     l17ba           ;  continued
        BCS     l17ce           ; Skip if Even Field
START:  STA     $E0EC           ; Off V Sync + Replace Interlace
        LDX     #$0F            ; Load Odd #VB Scans -2

        LDA     #$34            ; Initialize Odd Upper Address
        STA     l1780+1         ;  continued
        LDA     #$3b            ; Initialize Odd Character End Compare
        STA     l179f+1         ;  continued

l17ce:  JSR     SCAN+$3F        ; ///1st V Blanking Scan/////
        LDA     #$C0            ; Initialize Lower Address
        STA     l1786+1         ;  continued
        BMI     l17d8           ; Equalize 3 microseconds

l17d8:  CLD                     ; Equalize 4 microseconds
        NOP                     ;  continued
        JSR      SCAN           ; ///Rest of V Blanking Scans///
        DEX                     ; One Less Scan

        BMI      l1780          ; Start Character Scan
        CLC                     ; Clear Carry
        BPL      l17d8          ; Repeat V Blanking Scan

; NOTES:  TVT-6L must be connected and both the SCAN and DECODE
;          PROMS must be in circuit for program to run.
;
;         Both 17A9 and 17bf require that page 00 be enabled when
;          page E0 is addressed. This is done automatically in
;          the KIM-1 decode circuitry.
;
;         Location 00EC on page zero is reserved as an interlace\
;          storage bit.
;
;         Step 1786 goes to where the upper address stored in 1788
;          and the lower address stored in 1787 tells it to.
;          Values in these slots continuously change throughout
;          the program.
;
;         Values in slots 1781 (Upper address start) and 17A0
;          (Character end compare) alternate with the field being
;          scanned.
;
;         Horizontal Scan Frequency = 11.494 kHz. Vertical
;          frequency = 60.0222 Hertz. 87 microseconds per line
;          191.5 lines per field; 2 fields per frame, 383 lines
;          total.
;
;         TVT-6L switch must be i the "64" position.
;
;         ( ) Denotes an absolute address that is program location
;              sensitive.
;
;         * Denotes a relative branch that is program length sensitive.
;
;         Program may be used for 13 x 64 large characters or 25 x 64
;          small characters by changing the following slots:
;
;      13 x 64    25 x 64
;
; 178A   10         20
; 17Ad   14         0E
; 17Af   24         24
; 17b4   28         2b
;
; 17C3   15         0F
; 17C5   24         34
; 17CA   28         3b
