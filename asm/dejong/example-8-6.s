BCD     =       $00F0
COUT    =       $FDED

        .ORG    $13F4

; BCD-to-ASCII Subroutine

        LDY     #$0A            ; Y is # of BCD digits.
OUTLOOP:
        LDA     BCD             ; Get MSB of BCD #.
        AND     #$F0            ; Mask the low nibble.
        LSR     A               ; Move the high-order nibble
        LSR     A               ; to the low-order nibble.
        LSR     A
        LSR     A
        ORA     #$30            ; Convert to 7-bit ASCII.
        ORA     #$80            ; Convert to Apple ASCII.
        JSR     COUT            ; Use Apple output routine.
        TYA                     ; Save Y in A.
        LDY     #$04            ; Shift BCD # 4 bits left.
LOOP5:  LDX     #$04            ; X + 1 is # of bytes in BCD #.
LOOP4:  ROL     BCD,X           ; Rotate one byte.
        DEX                     ; Do we need to get another?
        BPL     LOOP4           ; Yes.
        DEY                     ; Decrement bit counter.
        BNE     LOOP5           ; Four bits yet?
        TAY                     ; Yes, so get Y back.
        DEY                     ; Have all digits been converted?
        BNE     OUTLOOP         ; No, so convert the others.
        RTS                     ; Yes, then quit.
