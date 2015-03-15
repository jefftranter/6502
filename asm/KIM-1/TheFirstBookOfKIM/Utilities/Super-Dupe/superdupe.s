        POINTL  = $FA
        POINTH  = $FB
        POINT   = $E0
        POINT2  = $E2
        GANG    = $F5
        CHKSUM  = $F6
        CHKHI   = $F7
        INH     = $F9

        EXIT    = $0154
        HIC     = $0161
        OUTBT   = $0170
        OUTCHT  = $0188
        NPUL    = $01BE
        SBD     = $1742
        PBDD    = $1743
        LOADT9  = $1929
        RDBYT   = $19F3
        PACKT   = $1A00
        RDCHT   = $1A24
        RDBIT   = $1A41
        SCANDS  = $1F1F
        GETKEY  = $1F6A
        CHK     = $1F91
        TIMG    = $C000

        .ORG    $0000

START:  LDX     #3
LOOP:   LDA     POINT2,X
        STA     POINT,X
        DEX
        BPL     LOOP
        LDA     #0
        STA     CHKSUM
        STA     CHKHI
        CLD
        LDA     #7
        STA     SBD
SYN:    JSR     RDBIT
        LSR     INH
        ORA     INH
        STA     INH
TST:    CMP     #$16            ; sync?
        BNE     SYN
        JSR     RDCHT
        DEC     INH
        BPL     TST
        CMP     #$2A
        BNE     TST
        JSR     RDBYT
        STA     INH
        LDX     #$FE            ; neg 2
ADDR:   JSR     RDBYT
        STA     POINTH+1,X
        JSR     CHK
        INX
        BMI     ADDR
BYTE:   LDX     #2
DUBL:   JSR     RDCHT
        CMP     #$2F            ; eot?
        BEQ     WIND
        JSR     PACKT
        BNE     ELNK            ; error?
        DEX
        BNE     DUBL
        STA     (POINT,X)
        JSR     CHK
        INC     POINT
        BNE     OVER
        INC     POINT+1
OVER:   BNE     BYTE
WIND:   JSR     RDBYT
        CMP     CHKHI
        BNE     ELNK            ; error?
        JSR     RDBYT
        CMP     CHKSUM
ELNK:   BNE     START           ; (or 65?)
FLSH:   JSR     SCANDS
        BEQ     FLSH            ; display SA,ID
        JSR     GETKEY

; Below is code matching published binary:
;       CMP     #$07
;       BCS     FLSH
;       STA     GANG
;       ASL     A
;       BEQ     START
;       STA     NPUL
;       ADC     GANG
;       STA     NPUL+2
;       LDA     #$27
;       STA     GANG
;       LDA     #$BF
;       STA     PBDD

; Below is code in published listing:
        STA     GANG
        ASL     A
        BEQ     START
        STA     NPUL
        ADC     GANG
        STA     TIMG+1
        LDA     #$27            ; register mask
        STA     GANG
        LDA     #$BF
        STA     PBDD
        LDX     #$64
        LDA     #$16            ; sync

        LDX     #$64            ; send 100
        LDA     #$16            ; sync
        JSR     HIC
        LDA     #$2A
        JSR     OUTCHT
        LDA     INH
        JSR     OUTBT
        LDA     POINTL
        JSR     OUTBT
        LDA     POINTH
        JSR     OUTBT
DATA:   LDY     #0
        LDA     (POINT2),Y
        JSR     OUTBT
        INC     POINT2
        BNE     SAMP
        INC     POINT2+1
SAMP:   LDA     POINT2
        CMP     POINT
        LDA     POINT2+1
        SBC     POINT+1
        BCC     DATA
        LDA     #$2F            ; eot
        JSR     OUTCHT
        LDA     CHKHI
        JSR     OUTBT
        LDA     CHKSUM
        JMP     EXIT

        .RES    2
        .ORG    $00D0
        JMP     LOADT9

        .RES    15
        .ORG    $00E2
        .BYTE   $00, $02, $00, $02
