; Scungy video demonstration software
;
; Adapted from Fig. 1-14 on page 32 of "Son of Cheap Video" by Don
;  Lancaster.
;
; uP - 6502             Start - JMP 020E  Displayed 0380-039F
; System - KIM-1 +      Stop - RST        Program Space 0200-023F
;          Scungy Video                       (64 words)
;                                         Scan Space - 1780-179F
;                                             (32 words)
;                                         IRQ - 1780 (17FE 80; 17FF 17)

        SCAN = $1780            ; Start address of SCAN PROM
        RIOT = $1700            ; Start address of 6530 RIOT

        .org    $0200

; Live Scan Subroutine:
l0200:  INC     RIOT            ; Output H sync pulse
        INC     RIOT            ; Advance row count
        BRK                     ; ///DO SCAN MICROINSTRUCTION///
        NOP                     ; Equalize 2 uS

        CMP     RIOT            ; Is this the last dot row?
        BNE     l0200           ; No, do another row of dots
        RTS                     ; Return to main scan

; Main Scan Program:

START:  NOP                     ; Equalize 6 uS
        NOP
        NOP
        LDA     #$FF            ; Make A port an output
        STA     RIOT+1          ;  continued
        LDA     #1              ; Start V sync pulse

        STA     RIOT            ;  continued
        LDA     #$0E            ; Last row compare
        LDY     #$1F            ; Delay for rest of V Sync
l021f:  DEY                     ;  continued

        BNE     l021f           ;  continued
        DEC     RIOT            ; End V sync pulse
        LDX     #$AF            ; Set # of blank scans
l0227:  PHA                     ; Equalize 9 us

        PLA                     ;  continued
        NOP                     ;  continued
        INC     RIOT            ; Output H sync pulse
        DEC     RIOT            ;  continued

        LDY     #$08            ; Delay to complete blank scan
l0232:  DEY                     ;  continued
        BNE     l0232           ;  continued
        DEX                     ; One less blank scan

        BNE    l0227            ; Done with blank scans?
        NOP                     ; Equalize 6 us
        NOP                     ;  continued

        JSR    l0200            ; ///DO LIVE SCAN SUBROUTINE///
        JMP    START            ; Start new field
