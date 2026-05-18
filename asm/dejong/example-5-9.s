PRBYTE  =       $FDDA

        .ORG    $1255

        CLD                     ; Operate in binary, not decimal.
        SEC                     ; Set the carry before subtracting.
        LDA     #$8D            ; Put  $8D into the accumulator.
        SBC     #$67            ; Subtract $67 from $8D.
        JSR     PRBYTE          ; Output the result to the screen.
        BRK
