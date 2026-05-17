KYBD    =       $C000
SCREEN  =       $07F7

        .org    $1000

START:  lda     KYBD            ; Transfer the number in KYBD to A.
        sta     SCREEN          ; Move number in A to SCREEN.
