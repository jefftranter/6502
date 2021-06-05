; Scungy video demonstration software
;
; Adapted from Fig. 1-14 on page 32 of "Son of Cheap Video" by Don
; Lancaster to run on my 6502 SBC.
;
; uP - 6502             Start - START     Displayed 0380-039F
; System - 6502 SBC +   Stop - RST        Program Space 1000-1040
;          Scungy Video                       (65 words)
;                                         Scan Space - 2000-201F
;                                             (32 words)
;

        VIA      = $8000        ; Start address of 6522 VIA
        VIA_DDRA = VIA+3        ; DDRA register
        VIA_ORA  = VIA+1        ; ORA register

        .org    $1FB0

        JMP     START

; Live Scan Subroutine:
; Each horizontal scan should be exactly 63 us (clock cycles) in length.
; 6 + 6 + 6 + 36 + 2 + 4 + 3 = 63

; TODO: This is only called once and could be in-line code.

l0200:  INC     VIA_ORA         ; (6) Output H sync pulse
        INC     VIA_ORA         ; (6) Advance row count
        JSR     SCAN            ; (6) ///DO SCAN MICROINSTRUCTION///
        NOP                     ; (2) Equalize 2 us
        CMP     VIA_ORA         ; (4) Is this the last dot row?
        BNE     l0200           ; (2+) No, do another row of dots
        RTS                     ; (6) Return to main scan

; Main Scan Program:
; 2 + 2 + 2 + 2 + 4 + 2 + 4 + 2 + (2 + 3) * 31 - 1 + 6 = 180
; 63 x 3 = 189

START:  NOP                     ; (2) Equalize 6 us
        NOP                     ; (2)
        NOP                     ; (2)
        LDA     #$FF            ; (2) Make A port an output
        STA     VIA_DDRA        ; (4)  continued
        LDA     #$01            ; (2) Start V sync pulse
        STA     VIA_ORA         ; (4)  continued
        LDA     #$10            ; (2) Last row compare ($10 or $0E?)
        LDY     #$1F            ; (2) Delay for rest of V Sync
l021f:  DEY                     ; (2)  continued
        BNE     l021f           ; (2+) continued
        DEC     VIA_ORA         ; (6) End V sync pulse

; 2 + 3 + 4 + 2 + 6 + 6 + 2 + (2 + 3) * 8 - 1 + 2 + 3 = 69

        LDX     #$AF            ; (2) Set # of blank scans (175)
l0227:  PHA                     ; (3) Equalize 9 us
        PLA                     ; (4)  continued
        NOP                     ; (2)  continued
        INC     VIA_ORA         ; (6) Output H sync pulse
        DEC     VIA_ORA         ; (6)  continued
        LDY     #$08            ; (2) Delay to complete blank scan
l0232:  DEY                     ; (2)  continued
        BNE     l0232           ; (2+) continued
        DEX                     ; (2) One less blank scan
        BNE    l0227            ; (2+) Done with blank scans?
        NOP                     ; (2) Equalize 6 us
        NOP                     ; (2)  continued
        JSR    l0200            ; (6) ///DO LIVE SCAN SUBROUTINE///
        JMP    START            ; (3) Start new field

        .res   $2000-*,$00

; Scan code for Scungy video 1x32 alphanumeric display.
; JSR/RTS method.
; Total cycles: 36

SCAN:
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        LDY    #$A0             ; (2)
        RTS                     ; (6) first 2 are part of the scan
