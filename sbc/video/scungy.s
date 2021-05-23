; Scungy video demonstration software
;
; Adapted from Fig. 1-14 on page 32 of "Son of Cheap Video" by Don
; Lancaster to run on my 6502 SBC.
;
; uP - 6502             Start - JMP 100E  Displayed 0380-039F
; System - 6502 SBC +   Stop - RST        Program Space 1000-1040
;          Scungy Video                       (65 words)
;                                         Scan Space - 2000-201F
;                                             (32 words)

        SCAN = $2000            ; Start address of SCAN PROM
        VIA  = $8000            ; Start address of 6522 VIA
        VIA_DDRA = VIA+3        ; DDRA register
        VIA_ORA  = VIA+1        ; ORA register

        .org    $1000

; Live Scan Subroutine:
l0200:  INC     VIA_ORA         ; Output H sync pulse
        INC     VIA_ORA         ; Advance row count
        JSR     SCAN            ; ///DO SCAN MICROINSTRUCTION///

        CMP     VIA_ORA         ; Is this the last dot row?
        BNE     l0200           ; No, do another row of dots
        RTS                     ; Return to main scan

; Main Scan Program:

START:  NOP                     ; Equalize 6 uS
        NOP
        NOP
        LDA     #$FF            ; Make A port an output
        STA     VIA_DDRA        ;  continued
        LDA     #1              ; Start V sync pulse

        STA     VIA_ORA         ;  continued
        LDA     #$0E            ; Last row compare
        LDY     #$1F            ; Delay for rest of V Sync
l021f:  DEY                     ;  continued

        BNE     l021f           ;  continued
        DEC     VIA_ORA         ; End V sync pulse
        LDX     #$AF            ; Set # of blank scans
l0227:  PHA                     ; Equalize 9 us

        PLA                     ;  continued
        NOP                     ;  continued
        INC     VIA_ORA         ; Output H sync pulse
        DEC     VIA_ORA         ;  continued

        LDY     #$08            ; Delay to complete blank scan
l0232:  DEY                     ;  continued
        BNE     l0232           ;  continued
        DEX                     ; One less blank scan

        BNE    l0227            ; Done with blank scans?
        NOP                     ; Equalize 6 us
        NOP                     ;  continued

        JSR    l0200            ; ///DO LIVE SCAN SUBROUTINE///
        JMP    START            ; Start new field
