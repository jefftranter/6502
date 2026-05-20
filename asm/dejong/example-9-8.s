PBD     =       $C700
DDRB    =       $C702
PCR     =       $C70C
IFR     =       $C70D

        .ORG    $17DA

INITLZ: LDA     #$7F            ; Make pins 0-6 output pins.
        STA     DDRB
        LDA     PCR             ; Initialize PCR so CB1 detects
        ORA     #$B0            ; position transition, pulse
        STA     PCR             ; output on pin CB2.
        LDA     #$10
        STA     IFR             ; Clear IFR4, the CB1 interrupt flag.
        LDA     #$0D            ; Send a carriage return
        STA     PBD             ; to the printer.
