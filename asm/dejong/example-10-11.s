DDRB    =       $C782
PBD     =       $C780

        .ORG    $1A14

        LDA     #$FF            ; Configure port B as an 8-bit
        STA     DDRB            ; Output port to control the DAC.
        LDX     #$00            ; Initialize X.
LOOPX:  STX     PBD             ; Output the number in X to the DAC.
WAIT:   BIT     $C000           ; Wait for a key depression.
        BPL     WAIT
        LDA     $C010           ; Clear the keyboard flip-flop.
        INX
        BNE     LOOPX           ; Get another point.
        BRK
