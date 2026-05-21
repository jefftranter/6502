LOTIME  =       $FD             ; CONTAINS LO-BYTE FOR TIMER.
HITIME  =       $FE             ; CONTAINS HI-BYTE FOR TIMER.
IAL     =       $FB
LOPAGE  =       $08
HIPAGE  =       $0F
PAD     =       $C781           ; CONVERTER PORT.
T1LL    =       $C784
T1LH    =       $C785
ACR     =       $C78B
PCR     =       $C78C
IFR     =       $C78D

        .ORG    $1A12

        LDX     #$00      ; Initialize locations used
        STX     IAL       ; for the indirect indexed
        LDX     #LOPAGE   ; addressing mode.
        STX     IAL+1
        LDX     #HIPAGE
        LDY     #$00
        LDA     #$0A      ; Initialize PCR. Pulse CA2.
        STA     PCR       ; IFR1 Set with pulse on CA1.
        LDA     #$40      ; T1 runs free.
        STA     ACR
        LDA     LOTIME    ; Set up T1LL.
        STA     T1LL
        LDA     PAD       ; Start conversion. These instructions
        LDA     HITIME    ; start timing.
        STA     T1LH
MORE:   LDA     #$02      ; Wait for the conversion.
PAUSE:  BIT     IFR
        BEQ     PAUSE     ; Conversion finished?
HOLD:   BIT     IFR       ; Yes, wait for timer.
        BVC     HOLD
        LDA     PAD       ; Read & start converter.
        STA     (IAL),Y   ; Store the last datum.
        LDA     T1LL      ; Clear IFR5.
        INY
        BNE     MORE      ; Page filled?
        INC     IAL+1     ; Yes, increment the page
        CPX     IAL+1     ; number.
        BCS     MORE      ; All pages filled?
        RTS               ; Yes, then return.
