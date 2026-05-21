LOTIME  =       $FD             ; Contains lo-byte for timer.
HITIME  =       $FE             ; Contains hi-byte for timer.
TRIG    =       $FC             ; Contains trigger level.
TABLE   =       $0F00           ; Table for data.
PBD     =       $C780           ; DAC location.
DDRB    =       $C782           ; Port B data direction register.
PAD     =       $C781           ; Converter port.
T1LL    =       $C784
T1LH    =       $C785
ACR     =       $C78B
PCR     =       $C78C
IFR     =       $C78D

        .ORG    $1A3D

        LDX     #$00            ; Clear X.
        LDA     #$0A            ; Initialize PCR. Pulse CA2.
        STA     PCR             ; IFR1 set with pulse on CA1.
        LDA     #$40            ; T1 runs free.
        STA     ACR
        LDA     #$FF            ; Set up port B to be an output
        STA     DDRB            ; port for the AD558 D/A converter.
        LDA     LOTIME          ; Set up T1LL.
        STA     T1LL
AGAIN:  LDA     PAD             ; Start conversion. These instructions
BACK:   LDA     #$02            ; wait for the voltage to exceed
WAIT:   BIT     IFR             ; a preassigned
        BEQ     WAIT
        LDA     PAD             ; trigger level.
        CMP     TRIG            ; Does it exceed trigger level?
        BCC     BACK            ; No, so wait until it does.
        LDA     HITIME          ; Start timing.
        STA     T1LH
MORE:   LDA     #$02            ; Wait for the conversion.
PAUSE:  BIT     IFR
        BEQ     PAUSE           ; Conversion finished?
HOLD:   BIT     IFR             ; Yes, wait for timer.
        BVC     HOLD
        LDA     PAD             ; Read & start converter.
        STA     TABLE,X         ; Store the last result.
        STA     PBD
        LDA     T1LL            ; Clear IFR5 for timer.
        INX
        BNE     MORE            ; Get the remaining points.
LOOPX:  LDA     TABLE,X         ; Get a number.
        STA     PBD             ; Output it to the DAC.
        INX
        BNE     LOOPX
        BIT     $C000           ; Check for a key down.
        BPL     LOOPX           ; Output the table again.
        STA     $C010           ; Clear keyboard flip-flop.
        BMI     AGAIN
