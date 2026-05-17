KYBD    =       $C000
SCREEN  =       $07F7

        .org    $1000

        lda     KYBD
        sta     SCREEN

