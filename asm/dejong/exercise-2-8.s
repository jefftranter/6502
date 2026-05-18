        .ORG    $1000

; Part A

        LDA     #$4C
        STA     $03FB
        LDA     #00
        STA     $03FC
        LDA     #$80
        STA     $03FD

; Part B

        LDA     $FFFF
        STA     $0000

; Part C

        LDA     #$00
        STA     $003A
        STA     $003B
        STA     $0045
        STA     $0046
        STA     $0047
        STA     $0048
        STA     $0049
        BRK

; Part D

LOOP:   STA     $C030           ; Toggle speaker
        LDA     $C000           ; Delay
        LDA     $C000           ; "
        LDA     $C000           ; "
        LDA     $C000           ; "
        JMP     LOOP
