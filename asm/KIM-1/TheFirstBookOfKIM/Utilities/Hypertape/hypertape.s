        TIC     = $F1
        COUNT   = $F2
        TRIB    = $F3
        GANG    = $F5

        SBD     = $1742
        PBDD    = $1743
        CLK1T   = $1744
        CLKRDI  = $1747
        CHKL    = $17E7
        CHKH    = $17E8
        SAL     = $17F5
        SAH     = $17F6
        EAL     = $17F7
        EAH     = $17F8
        ID      = $17F9
        VEB     = $17EC
        DISPZ   = $185C
        INTVEB  = $1932        
        CHKT    = $194C
        INCVEB  = $19EA

        .ORG    $0100

; this program also included in Super-dupe

DUMP:   LDA    #$AD
        STA    VEB
        JSR    INTVEB           ; set up sub
        LDA    #$27
        STA    GANG             ; flag for SBD
        LDA    #$BF
        STA    PBDD
        LDX    #$64
        LDA    #$16
        JSR     HIC
        LDA     #$2A
        JSR     OUTCHT
        LDA     ID
        JSR     OUTBT
        LDA     SAL
        JSR     OUTBTC
        LDA     SAH
        JSR     OUTBTC
DUMPT4: JSR     VEB
        JSR     OUTBTC
        JSR     INCVEB
        LDA     VEB+1
        CMP     EAL
        LDA     VEB+2
        SBC     EAH
        BCC     DUMPT4
        LDA     #$2F
        JSR     OUTCHT
        LDA     CHKL
        JSR     OUTBT
        LDA     CHKH
EXIT:   JSR     OUTBT
        LDX     #$02
        LDA     #$04
        JSR     HIC
        JMP     DISPZ

; subroutines

HIC:    STX     TIC
HIC1:   PHA
        JSR     OUTCHT
        PLA
        DEC     TIC
        BNE     HIC1
        RTS
OUTBTC: JSR     CHKT
OUTBT:  PHA
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        JSR     HEXOUT
        PLA
        JSR     HEXOUT
        RTS
;
HEXOUT: AND     #$0F
        CMP     #$0A
        CLC
        BMI     HEX1
        ADC     #$07
HEX1:   ADC     #$30
OUTCHT: LDY     #$07
        STY     COUNT
TRY:    LDY     #$02
        STY     TRIB
ZON:    LDX     NPUL,Y
        PHA
ZON1:   BIT     CLKRDI
        BPL     ZON1
        LDA     TIMG,Y
        STA     CLK1T
        LDA     GANG
        EOR     #$80
        STA     SBD
        STA     GANG
        DEX
        BNE     ZON1
        PLA
        DEC     TRIB
        BEQ     SETZ
        BMI     ROUT
        LSR     A
        BCC     ZON
SETZ:   LDY     #0
        BEQ     ZON
ROUT:   DEC     COUNT
        BPL     TRY
        RTS

; frequency/density controls

NPUL:   .BYTE   $02
TIMG:   .BYTE   $C3, $03, $7E
