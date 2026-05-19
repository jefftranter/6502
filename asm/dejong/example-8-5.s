BCD     =       $00F0           ; Most significant byte of BCD #.
BIN     =       $00E0           ; Most significant byte of binary #.

        .ORG    $13D0

; Binary-to-BCD Subroutine

        LDA     #$00            ; Clear locations for BCD #.
        LDX     #$04            ; X + 1 is # of bytes for BCD #.
LOOP1:  STA     BCD,X           ; Load with zeros.
        DEX                     ; Decrement byte counter.
        BPL     LOOP1           ; Finished?
        SED                     ; Yes, set decimal more for additions.
        LDY     #$20            ; Y is number of bits to be converted.
BIGLOOP:
        LDX     #$03            ; X counts bytes.
        CLC                     ; This set of instructions
LOOP2:  ROL     BIN,X           ; moves the binary number
        DEX                     ; into the carry, one bit
        BPL     LOOP2           ; at a time.
        LDX     #$04            ; The next loop adds the
LOOP3:  LDA     BCD,X           ; binary coded decimal number
        ADC     BCD,X           ; to itself.
        STA     BCD,X
        DEX
        BPL     LOOP3
        DEY                     ; Decrement bit counter.
        BNE     BIGLOOP         ; No, get another bit.
        CLD                     ; Yes, get out.
        RTS
