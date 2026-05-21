AREG    =       $0045
PREG    =       $0048
PCL     =       $003A
PCH     =       $003B
XREG    =       $0046
YREG    =       $0047
SREG    =       $0049
KYBD    =       $C000
STROBE  =       $C010
PRBYTE  =       $FDDA
PRBLNK  =       $F948
CROUT1  =       $FD8B
REGDSP  =       $FAD7
CURSHO  =       $0024
CURSVT  =       $0025

        .ORG    $8000
        STA     AREG            ; Save A.
        PLA                     ; Pull P off stack.
        STA     PREG            ; Save P.
        PLA                     ; Pull PCL off stack.
        STA     PCL             ; Save it.
        PLA                     ; Pull PCH off stack.
        STA     PCH             ; Save it.
        STY     YREG            ; Save Y.
        STX     XREG            ; Save X.
        TSX                     ; Stack pointer to X
        STX     SREG            ; Save S.
        LDA     #$00            ; Home cursor.
        STA     CURSHO          ; Horizontal position.
        STA     CURSVT          ; Vertical position.
        LDX     #$17            ; Clear screen.
BR3:    JSR     CROUT1
        DEX
        BPL     BR3
        LDA     #$00
        STA     CURSHO
        STA     CURSVT
        LDA     PCH             ; Get PCH.
        JSR     PRBYTE          ; Print it.
        LDA     PCL             ; Get PCL.
        JSR     PRBYTE          ; Print it.
        LDY     #$00            ; Clear Y.
        JSR     PRBLNK          ; Print blanks.
        LDA     (PCH),Y         ; Get op code.
        JSR     PRBYTE          ; Print it.
        JSR     REGDSP          ; Display the registers.
        LDA     #$C3            ; ASCII C.
        STA     $0767           ; Display it.
        STA     $0751
        LDA     #$DA            ; ASCII Z.
        STA     $0766           ; Display it.
        LDA     #$C9            ; ASCII I.
        STA     $0765           ; Display it.
        LDA     #$C4            ; ASCII D.
        STA     $0764           ; Display it.
        LDA     #$C2            ; ASCII B.
        STA     $0763           ; Display it.
        LDA     #$A0            ; ASCII SPACE.
        STA     $0762           ; Display it.
        LDA     #$D6            ; ASCII V.
        STA     $0761           ; Display it.
        LDA     #$CE            ; ASCII N.
        STA     $0760           ; Display it.
        LDA     AREG            ; Get A.
        PHA                     ; Save it.
        LDX     #$07            ; Display it.
BACK:   ROR     AREG
        LDA     #$00
        ADC     #$B0
        STA     $07F0,X
        DEX
        BPL     BACK
        PLA
        STA     AREG
        LDX     #$07            ; Get P.
        LDA     PREG            ; Save it.
        PHA
BR1:    ROR     PREG            ; One bit at a time.
        LDA     #$00            ; Convert to ASCII.
        ADC     #$B0
        STA     $07E0,X         ; Output it to the screen.
        DEX                     ; Get another bit.
        BPL     BR1
        PLA                     ; Get P back.
        STA     PREG            ; Restore it.
        LDA     #$D0            ; ASCII P.
        STA     $0750           ; Display it.
        STA     $0758
        LDA     #$CF            ; ASCII O.
        STA     $0757           ; Display it.
        LDA     #$C1            ; ASCII A.
        STA     $0770           ; Display it.
BR2:    LDA     KYBD            ; Wait for keyboard.
        BPL     BR2
        STA     STROBE          ; Clear strobe.
        LDX     SREG            ; Restore the registers.
        TXS
        LDY     YREG
        LDX     XREG
        LDA     PCH
        PHA
        LDA     PCL
        PHA
        LDA     PREG
        PHA
        LDA     AREG
        RTI                     ; Return to the program.
