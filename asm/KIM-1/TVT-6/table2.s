; Table II
;
; 16 line X 32 character per line Interlaced
; TVT6 Raster Scan:
;
; uP - 6502       Start - JMP 17Ad  Displayed 0200-03FF
; System - KIM-1  End - Interrupt   Program Space 1780-17E2
;
; +--+--+--+--+--+-+-+--+  +--+--+--+---+--+--+--+--+
; |HS|VS|L4|L2|L1|0|1|V8|  |V4|V2|V1|H16|H8|H4|H2|H1|
; +--+--+--+--+--+-+-+--+  +--+--+--+---+--+--+--+--+
;       Upper Address            Lower Address

        SCAN = $8000    ; Start address of SCAN PROM

        .org    $1780

l0:     NOP                     ; Equalize 2 cycles
l1:     STA     l2+2            ; Store upper address
        PHA                     ; Equalize 10 cycles
        PLA                     ; Continued

        BNE     l2              ; Continued
l2:     JSR     SCAN            ; ////Character Scans 1-8////
        ADC     #$08            ; Increment Character Scan Counter
        CMP     #$C0            ; Is VS = 1?

        BCC     l1              ; No, do next character scan.
        JSR     eq              ; Equalize 15 cycles with sub
        JSR     SCAN            ; ////Character Scan 9////
        TAX                     ; Save Upper Address

        LDA     l2+1            ; Get Lower Address
        ADC     #$1F            ; Increment L; Set C on V4 overflow
        STA     l2+1            ; Restore lower word; save carry
        TXA                     ; Get Lower Word

l3:     BNE     l4              ; Equalize 5 cycles
l4:     NOP                     ; continued
        ADC     #$C0            ; Add carry; Reset VS
        JSR     SCAN            ; ////Character Scan 10////

        CMP     #$84            ; It is line "17"?
        BCC     l0              ; No, continue character scan
start:  LDA     iw              ; Get interlace word
        EOR     #$80            ; Change field

        BMI     l5              ; Jump if even field
        STA     $4000+iw        ; Odd Field V Sync: Restore Interlace word
        LDX     #$66            ; Load short number of VB scans
l5:     JSR     eq              ; Equalize 15 cycles via sub

        JSR     eq              ; Equalize 15 cycles via sub again
        BPL     l6              ; Jump if odd field
        STA     $4000+iw        ; Even Field V Sync: restore interlace
        LDX     #$67            ; Load long number of V Blank scans

l6:     JSR     SCAN+$1E        ; ////1st V blanking scan////
        CLD                     ; Equalize 9 cycles
        PHA                     ; Continued
        PLA                     ; Continued

l7:     LDA     #$00            ; Initialize lower address
        STA     l2+1            ; Continued
        LDA     #$82            ; Initialize upper address
        STA     l2+2            ; Continued

        JSR     SCAN            ; ///Remaining V Blanking scans////
        CLC                     ; Initialize carry
        DEX                     ; One less scan

        BMI     l1              ; Start character scan
        BPL     l7              ; Repeat Vertical blanking scan
iw:     .byte   $80             ; Interlace word storage
eq:     BCS     l8              ; ///Equalize 15 SUBROUTINE ////

l8:     RTS                     ; Continued

; NOTES:  TVT6 must be connected and scan microprogram PROM (IC1)
;         must be in circuit for program to run.
;
;         Both 17b4 and 17C1 require that page 17 be enabled
;         when  page 57 is addressed.  This is done automatically
;         with KIM-1 circuitry.
;
;         Step 1788 goes to where the upper address stored in 178A
;         and the lower address stored in 1789 tells it to. Values
;         in these slots continuously change throughout the program.
;
;         For a 525-line system, use 17b8 64 and 17c5 65 and a KIM-1
;         crystal of 992.250 kHz. This is only needed for video
;         superposition and titling applications.
;
;         Normal program horizontal frequency is 15,873,015 Hz;
;         Vertical frequency 60.0114 Hz.  63 us per line; 264.5 lines.
;
;         * Denotes a relative branch that is program length
;         sensitive.
;
;         ( ) Denotes an absolute address that is program location sensitive.
;
;         The TVT6 length jumper must be in the "32" position.
