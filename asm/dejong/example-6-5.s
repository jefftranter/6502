DIFF    =       $08
SBTHND  =       $10
MINUND  =       $18

        .ORG    $13A2

        CLD                     ; Clear decimal mode
        SEC                     ; Set carry for no borrow.
        LDX     #$04            ; X contains the number of bytes.
LOOP:   LDA     MINUND,X        ; Get byte from minuend.
        SBC     SBTHND,X        ; Subtract subtrahend from minuend.
        STA     DIFF,X          ; Store the result there.
        DEX                     ; Decrement the byte counter.
        BNE     LOOP            ; Continue until byte counter is zero.
        RTS
