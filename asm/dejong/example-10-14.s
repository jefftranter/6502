DDRB    =       $C782
PBD     =       $C780
IFR     =       $C78D

        .ORG    $1A97

        LDA     #$FF            ; Configure port B as an 8-bit
        STA     DDRB            ; output port to control the DAC.
START:  LDX     #$FF            ; Initialize X.
RAMP:   INX                     ; Increment X
        STX     PBD             ; Output it to the DAC.
        LDA     #$10            ; Check the CB1 flag, IFR4.
        BIT     IFR             ; Is it set?
        BEQ     RAMP            ; No, try another X.
        TXA                     ; Yes, transfer X to A.
        JSR     $FDDA           ; Output the character.
        JSR     $FD8E           ; Output a carriage return.
        JMP     START
