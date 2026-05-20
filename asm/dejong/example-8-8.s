BCDN    =       $00FF           ; Base address of BCD #.
BINO    =       $00F7           ; Base address of binary #.
NBYTE   =       $FD             ; Two complement of # bytes
                                ; in the BCD number.

        .ORG    $1417

; BCD-to-binary subroutine

CONVERT:
        CLD                     ; Clear decimal mode.
        LDA     #$00            ; Clear locations to hold binary #.
        LDX     #NBYTE          ; X is byte counter.
LOOPA:  STA     BINO,X          ; Fill binary # with zeros.
        INX
        BNE     LOOPA
        LDA     #$80
        LDX     #NBYTE          ; Make most significant bit of
        STA     BINO,X          ; binary number a one.
BIGLOOP:
        LDX     #NBYTE
        CLC                     ; Clear carry for rotate.
LOOPB:  ROR     BCDN,X          ; Rotate BCD # into carry.
        INX
        BNE     LOOPB
        LDX     #NBYTE          ; Rotate last carry into binary #.
LOOPC:  ROR     BINO,X          ; One bit at a time.
        INX
        BNE     LOOPC
        BCS     OUT             ; If carry is set, conversion complete.
        LDX     #NBYTE          ; Start correction to BCD/2 operation.
        SEC
LOOPD:  LDA     BCDN,X          ; If bit three is set,
        AND     #$08            ; then subtract $03.
        BEQ     BR1
        LDA     BCDN,X
        SBC     #$03
        STA     BCDN,X
BR1:    LDA     BCDN,X          ; Next check bit seven to see
        AND     #$80            ; if bit seven is set.
        BEQ     BR2             ; If not, do not subtract.
        LDA     BCDN,X          ; If so, subtract $30.
        SBC     #$30
        STA     BCDN,X
BR2:    INX
        BNE     LOOPD           ; Repeat for all bytes of the BCD #.
        BEQ     BIGLOOP         ; Loop back for another bit.
OUT:    RTS                     ; Conversion complete.
