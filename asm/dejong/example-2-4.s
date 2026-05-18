KYBD    =       $C000
SCREEN  =       $07F7

        .ORG    $1000

        LDA     KYBD            ; Load A from KYBD.
        STA     SCREEN          ; Move number in A to SCREEN.
