PBD     =       $C700
DDRB    =       $C702
PCR     =       $C70C
IFR     =       $C70D
DOSSYS  =       $03EA

        .ORG    $02CC

INITIAL:
        LDA     #<PRINT         ; Set up Apple output registers
        STA     $36             ; to point to printer routine.
        LDA     #>PRINT
        STA     $37
        LDA     #$7F            ; Initialize port B.
        STA     DDRB
        LDA     PCR             ; Initialize PCR.
        ORA     #$80
        STA     PCR
        LDA     #$10            ; Clear IFR4.
        STA     IFR
        LDA     #$0D
        STA     PBD             ; Output carriage return.
        JMP     DOSSYS          ; Jump to disk routine
                                ; To exchange output registers.

PRINT:  PHA
LOAF:   LDA     #$10
        BIT     IFR
        BEQ     LOAF
        STA     IFR
        PLA
        STA     PBD
        JMP     $FDF0           ; Jump to output character
                                ; to the video monitor.
