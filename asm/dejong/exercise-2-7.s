TXTCLR  =       $C050
MIXCLR  =       $C052
HISCR   =       $C055
LORES   =       $C056

        .org    $1000

        sta     TXTCLR
        sta     MIXCLR
        sta     LORES
        sta     HISCR
        brk
