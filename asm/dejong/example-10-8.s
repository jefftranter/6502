LOTIME  =       $F2             ;CONTAINS LO-BYTE FOR TIMER.
HITIME  =       $F1             ;CONTAINS HI-BYTE FOR TIMER.
TRIG    =       $F0             ;CONTAINS TRIGGER LEVEL.
TABLE   =       $0F00           ;TABLE FOR DATA.
PAD     =       $C781           ;CONVERTER PORT.
T1LL    =       $C784
T1LH    =       $C785
ACR     =       $C78B
PCR     =       $C78C
IFR     =       $C78D

        .ORG    $19C0

        LDX     #$00            ; Clear X.
        LDA     #$0A            ; Initialize PCR. Pulse CA2.
        STA     PCR             ; IFR1 set with pulse on CA1.
        LDA     #$40            ; T1 runs free.
        STA     ACR
        LDA     LOTIME          ; Set up T1LL.
        STA     T1LL
        LDA     PAD             ; Start conversion. These instructions
BACK:   LDA     #$02            ; wait for the voltage to exceed
WAIT:   BIT     IFR             ; a preassigned
        BEQ     WAIT
        LDA     PAD             ; trigger level.
        CMP     TRIG            ; Does it exceed trigger level?
        BCC     BACK            ; No, so wait until it does.
        LDA     HITIME          ; start timing.
        STA     T1LH
MORE:   LDA     #$02            ; Wait for the conversion.
PAUSE:  BIT     IFR
        BEQ     PAUSE           ; Conversion finished?
HOLD:   BIT     IFR             ; Yes, wait for timer.
        BVC     HOLD
        LDA     PAD             ; Read & start converter.
        STA     TABLE,X         ; Store the last result.
        LDA     T1LL            ; Clear IFR5 for timer.
        INX
        BNE     MORE            ; Get the remaining points.
        RTS
