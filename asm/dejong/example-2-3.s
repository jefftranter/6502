KYBD    =       $C000
SCREEN  =       $07F7

        .ORG    $1000

        LDA     KYBD
        STA     SCREEN

