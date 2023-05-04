; Assembly code used in swap.bas program.
; Code is relocatable and gets installed at top of available memory.

SCREEN  = $D300       ; Start of video RAM
SWITCH  = $D800       ; 24/48 column display register
CHROUT  = $FF69       ; Character out routine
POSTOUT = $FF6C       ; Post character out routine

F6      = $F6         ; Column start
F7      = $F7         ; Row start
F8      = $F8
F9      = $F9
FA      = $FA
FB      = $FB         ; Cassette/keyboard flag for monitor
FC      = $FC
FD      = $FD
FE      = $FE
FF      = $FF

        * = $1000     ; Actual start address is top of available memory

        STA FE
        PHA
        LDA FB
        BMI L1012
        STA SWITCH
        AND #$01
        STA FA
        LDA #FF
        STA FB
L1012   LDA FA
        BNE L101A
        PLA
        JMP CHROUT
L101A   TXA
        PHA
        TYA
        PHA
        LDA FE
        LDY FF
        LDX FD
        AND #$7F
        CMP #$0D        ; Carriage return?
        BEQ L1084
        CMP #$08        ; Backspace?
        BEQ L1076
        CMP #$0C        ; Form feed?
        BEQ L107D
        CMP #$0A        ; Line feed?
        BEQ L1090
        CMP #$20        ; Space?
        BMI L1054
        CMP #$7B        ; Rubout/Delete?
        BPL L1054
        STA SCREEN,X
        INX
        CPX #$7B
        BEQ L108C
        BNE L1069
L1048   LDY SCREEN,X
        STY FF
        LDA #$A1        ; Blank character
        STA SCREEN,X
        STX FD
L1054   PLA
        TAY
        PLA
        TAX
        PLA
        JMP POSTOUT
L105C   TXA
        AND #$3F
        CMP #$0A
        BNE L1048
        TXA
        SBC #$10
        TAX
        BNE L1048
L1069   TXA
        AND #$3F
        CMP #$3B
        BNE L1048
        TXA
        ADC #$0F
        TAX
L1074   BNE L1048
L1076   TYA
        STA SCREEN,X
        DEX
        BCS L105C
L107D   TYA
        STA SCREEN,X
        INX
        BCS L1069
L1084   TYA
        STA SCREEN,X
        LDX #$4B
        BNE L1048
L108C   LDX #$4B
        BNE L1094
L1090   TYA
        STA SCREEN,X
L1094   STX FC
        LDA #$40
        STA F8
        LDY #$00
        STY F6
        LDX #$CF
L10A0   INX
        STX F9
        STX F7
L10A5   LDA (F8),Y
        STA (F6),Y
        INY
        BEQ L10A0
        BPL L10A5
        CPX #$D3
        BNE L10A5
        LDX FC
        BNE L1074
        .byte $33       ; Unused?
        .END
