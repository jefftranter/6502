ADD1    =       $0010
ADD2    =       $0018
SUM     =       $0080

        .ORG    $13B0

        SED                     ; Set decimal mode
        CLC                     ; Clear carry for first sum.
        LDY     #$03            ; Y contains # bytes to be added.
LOOP:   LDA     ADD1,Y          ; Get byte from first addend.
        ADC     ADD2,Y          ; Add byte from second addend.
        STA     SUM,Y           ; Result into sum.
        DEY                     ; Decrement byte count.
        BNE     LOOP            ; Continue until all bytes have been
        RTS                     ; added.
