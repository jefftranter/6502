DDRB    =       $C702
DDRA    =       $C703

        .ORG    $1774

        LDA     #$FF            ; Set up DDRA to make
        STA     DDRA            ; port A an output port.
        LDA     #$81            ; Make pins seven and one of port B
        STA     DDRB            ; output pins.
