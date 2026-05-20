PBD     =       $C700
PAD     =       $C701
DDRB    =       $C702
DDRA    =       $C703

        .ORG    $1788

        LDA     #$FF            ; Make port A an output port.
        STA     DDRA
        LDA     #$00            ; Make port B an input port.
        STA     DDRB
LOOP:   LDA     PBD             ; Read port B.
        STA     PAD             ; Write to port A.
        CLC
        BCC     LOOP            ; Loop to do this continuously.
