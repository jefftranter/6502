CHKSMLO =       $0A
CHKSMHI =       $0B

        .ORG    $15A3

        LDA     #00
        CLD
        STA     CHKSMLO
        STA     CHKSMHI
        LDX     #$FF
LOOP:   LDA     $0300,X
        CLC
        ADC     CHKSMLO
        STA     CHKSMLO
        LDA     #00
        ADC     CHKSMHI
        STA     CHKSMHI
        DEX
        BPL     LOOP
        RTS

