IAL     =       $00
KYBD    =       $C000
STROBE  =       $C010
CODE    =       $0800

        .ORG    $1487

        LDY     #$00
        STY     IAL
        LDA     #$09
        STA     IAL+1
WAIT:   BIT     KYBD
        BPL     WAIT
        LDA     KYBD
        STA     STROBE
        TAX
        LDA     CODE,X
        STA     (IAL),Y
        INC     IAL
        CLC
        BCC     WAIT
