KYBD    =       $C000
SCREEN  =       $07F7

        .org    $1000

        lda     KYBD            ; Load A from KYBD.
        sta     SCREEN          ; Move number in A to SCREEN.
