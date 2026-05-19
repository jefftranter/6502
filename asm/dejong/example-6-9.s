NUMB    =       $0380

        .ORG    $13DB

        LDY     #$03            ; Y serves as byte counter.
LOOP:   LDA     #$FF            ; A EOR $FF is "not A".
        EOR     NUMB,Y          ; Complement the number.
        STA     NUMB,Y          ; And store it in the same location.
        DEY                     ; Decrement the byte counter.
        BNE     LOOP
        RTS
