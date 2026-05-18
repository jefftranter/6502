KYBD    =       $C000
SCREEN  =       $07F7

        .ORG    $1000

START:  LDA     KYBD            ; Transfer the number in KYBD to A.
        STA     SCREEN          ; Move number in A to SCREEN.
        JMP     START           ; Go to instruction labelled START.
