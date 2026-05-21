DDRB    =       $C782
PBD     =       $C780
TABLE   =       $0F00

        .ORG    $1A2A

        LDA      #$FF           ; Configure port B as an 8-bit
        STA      DDRB           ; output port to control the DAC.
        LDX      #$00           ; Initialize X.
LOOPX:  LDA      TABLE,X        ; Fetch a number from the table.
        STA      PBD            ; Output it to the DAC.
        INX
        BNE      LOOPX
        BRK
