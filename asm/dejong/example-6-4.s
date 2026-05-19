TABZ    =       $F0

        .ORG    $1398

        LDA     #$00            ; Load A with all zeros.
        LDX     #$1F            ; $1F is starting value of index.
LOOP:   STA     TABZ,X          ; Load this location with zeros.
        DEX                     ; Decrement the counter to point to the
        BPL     LOOP            ; next location. If X > 0
        BRK                     ; then branch back.
