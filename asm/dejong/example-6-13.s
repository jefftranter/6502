KYBD    =       $C000

        .ORG    $0800
CODE:
        .ORG    $08B0
        .BYTE   $FC, $7C, $3C, $1C, $0C, $04, $84, $C4
        .BYTE   $E4, $F4, $00, $00, $00, $00, $00, $00
        .BYTE   $00, $60, $88, $A8, $90, $40, $28, $D0
        .BYTE   $08, $20, $78, $B0, $48, $E0, $A0, $F0
        .BYTE   $68, $D8, $F0, $10, $C0, $30, $18, $70
        .BYTE   $98, $B8, $C8

        .ORG    $1487

        LDX     KYBD            ; Character code in X.
        LDA     CODE,X          ; Indexes Morse code in table.
DOTDASH:
        ASL     A               ; Shift code character into carry.
        BNE     SEND            ; Branch to send routine.
        RTS
SEND:   NOP                     ; Dummy instruction illustrates branch.
        CLV                     ; Clear the overflow flag.
        BVC     DOTDASH         ; Force a branch to dotdash.
