LENGTH  =       $0A
BUFFER  =       $0800

        .ORG    $0582

        LDY     LENGTH          ; Get table length into Y.
        DEY                     ; Y index is # of bytes minus one.
        LDA     #0              ; Clear the accumulator.
LOOPY:  EOR     BUFFER,Y        ; EOR all the numbers
        DEY                     ; in the table.
        BNE     LOOPY
        LDY     LENGTH          ; Set up index for checksum storage.
        STA     BUFFER,Y        ; Checksum into top location.
        RTS
