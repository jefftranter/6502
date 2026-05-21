PCR     =       $C78C
PAD     =       $C781
TABLE   =       $0F00

        .ORG    $199E

; Fast One-Page Conversion Routine.
; *********************************

        LDA     #$0A            ; Initialize PCR. Pulse CA2, IFR1 set
        STA     PCR             ; on negative transition on CA1.
        LDX     #$00            ; Start with index at zero.
        LDA     PAD             ; Start the first conversion.
        NOP                     ; These instructions waste time
        NOP                     ; until the conversion is complete.
        NOP
        NOP
        NOP
BACK:   NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
HERE:   LDA     PAD             ; Read the converter and
        STA     TABLE,X         ; start another, store datum.
        INX
        BNE     BACK            ; Get 356 conversions.
        RTS                     ; Quit.
