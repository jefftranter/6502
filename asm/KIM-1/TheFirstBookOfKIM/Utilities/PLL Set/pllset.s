        PD0     = $1700
        PA0     = $1701
        SAD     = $1740
        PADD    = $1741
        SBD     = $1742
        CLK1T   = $1744
        CLKRDI  = $1747

        .ORG    $1780

BEGN:   LDA     #$07            ; Set the input
        STA     SBD
        LDA     #$01            ; and output ports
        STA     PA0
        STA     $E1             ; Initialize the toggle
        LDA     #$7F
        STA     PADD            ; Open display channels
MORE:   LDX     #09             ; Start with the first
NEXT:   LDY     #07             ; digit   Light top & right
        BIT     SBD             ; if PLL output
        BMI     SEGS            ; is high
        LDY     #$38            ; otherwise left & bottom
SEGS:   STY     SAD             ; Turn on the segments
        STX     SBD             ; and the digit
DELA:   BIT     CLKRDI          ; Half cycle done?
        BPL     DELA            ; No, wait for time up
        INC     $E2             ; Count the cycles
        BMI     LOTO            ; 128 1/2 cycles, send low tone
HITO:   LDA     #$91            ; 128 1/2 cycles, send hi tone
        BNE     CLK1
LOTO:   LDA     #$93
        NOP                     ; Equalize the branches
CLK1:   STA     CLK1T           ; Set the clock
        LDA     #$01
        EOR     $E1             ; Flip the toggle register
        STA     $E1
        STA     PD0             ; Toggle the output port
        INX
        INX                     ; Next display digit
        CPX     #$15            ; Last one?
        BNE     NEXT            ; No, do next
        BEQ     MORE            ; Yes, do more
