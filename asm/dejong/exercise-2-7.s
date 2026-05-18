TXTCLR  =       $C050
MIXCLR  =       $C052
HISCR   =       $C055
LORES   =       $C056

        .ORG    $1000

        STA     TXTCLR
        STA     MIXCLR
        STA     LORES
        STA     HISCR
        BRK
