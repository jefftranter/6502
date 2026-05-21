COUT    =       $FDED           ; Monitor output routine.
BINO    =       $00F7           ; Base address of binary #.
NBYTE   =       $FD             ; Two complement of # bytes
                                ; in the BCD number (-3).

        .ORG    $1459

; HEX-to ASCII subroutine

        LDY     #$06            ; Y is # of hex digits. 2 times # bytes.
OUTLOOP:
        LDX     #NBYTE          ; X = negative offset to MSB (-3)
        LDA     BINO,X          ; Get the most significant byte.
        AND     #$F0            ; Mask the lest significant nibble.
        LSR     A               ; Shift to the low-order nibble.
        LSR     A
        LSR     A
        LSR     A
        CMP     #$0A            ; Is it a letter A-F?
        BCS     BR1             ; Yes.
        ORA     #$30            ; No, convert number to ASCII.
        BNE     BR2             ; Branch around letter conversion.
BR1:    ADC     #$36            ; Converts A-F to ASCII.
BR2:    ORA     #$80            ; Change to Apple ASCII: bit 7=1.
        JSR     COUT            ; Output the character.
        TYA                     ; Save Y for a moment.
        LDY     #$04            ; Y will count 4 bit shifts.
LOOPY:  LDX     #$02            ; Start with LSB.
        CLC
LOOPX:  ROL     <(BINO+NBYTE),X
        DEX
        BPL     LOOPX
        DEY                     ; Four bits yet?
        BNE     LOOPY           ; No, go back and shift again.
        TAY                     ; Yes, restore Y.
        DEY                     ; Have all the digits been converted?
        BNE     OUTLOOP         ; No, so convert another.
        RTS                     ; Yes, then quit.

