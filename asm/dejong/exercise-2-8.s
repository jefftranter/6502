        .org    $1000

; Part A

        lda     #$4C
        sta     $03FB
        lda     #00
        sta     $03FC
        lda     #$80
        sta     $03FD

; Part B

        lda     $FFFF
        sta     $0000

; Part C

        lda     #$00
        sta     $003A
        sta     $003B
        sta     $0045
        sta     $0046
        sta     $0047
        sta     $0048
        sta     $0049
        brk

; Part D

LOOP:   sta     $C030           ; Toggle speaker
        lda     $C000           ; Delay
        lda     $C000           ; "
        lda     $C000           ; "
        lda     $C000           ; "
        jmp     LOOP
