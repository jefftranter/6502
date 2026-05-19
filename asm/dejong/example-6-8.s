CNTR    =       $00

        .ORG    $13D1

        LDX     #$FD            ; X contains 2's complement of the
BACK:   INC     CNTR,X          ; # of bytes in the counter.
        BNE     OUT             ; Quit unless increment gives zero.
        INX
        BNE     BACK            ; Increment another byte.
OUT:    RTS                     ; Return.
