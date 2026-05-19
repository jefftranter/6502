TABLE   =       $0300

        .ORG    $13C1

        LDA     #$00            ; Start with the smallest possible number.
        LDX     #$7F            ; Index highest location in table.
BR1:    CMP     TABLE,X         ; Is A > # in table?
        BCS     BR2             ; Yes, then do not replace A.
        LDA     TABLE,X         ; No, then replace A with number.
BR2:    DEX                     ; From the table. Decrement X.
        BPL     BR1             ; Search complete?
        RTS                     ; Yes.
