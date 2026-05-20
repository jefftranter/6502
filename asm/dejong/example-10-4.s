T1L     =       $C784
T1H     =       $C785
COUT    =       $FDF0
T2CL    =       $C788
ACR     =       $C78B
IFR     =       $C78D
CHAR    =       $00B1
SPACE   =       $00B2
MARK    =       $00B3
DOT     =       $00B4
HALFDOT =       $00B5
THFTDOT =       $00B6
DDOT    =       $00B7
FDOT    =       $00B8
STORE   =       $00B9
TEMP    =       $00BA

        .ORG    $2250

START:  CLD
        LDA     #$20            ; Set up T2 to count pulses.
        STA     ACR
        LDA     #$0E
        STA     DOT
        STA     MARK
        SEI
        JSR     CAL
        LDA     #$01
        STA     CHAR
        JSR     TIMER           ; Start receiving code.
STATE1: LDA     #$00            ; In state 1 the program
RPT:    STA     SPACE           ; waits until a tone at
        STA     MARK            ; least 3/4 dot length
CNT:    JSR     COUNT           ; has been detected.
        LDA     MARK            ; Then it jumps to state 2.
        CMP     THFTDOT
        BCS     STATE2
        LDA     SPACE
        CMP     DOT
        BCS     STATE1
        BCC     CNT
STATE2: LDA     #$00            ; In state 2 a tone is being
        STA     SPACE           ; counted. When the tone ends
MORE:   JSR     COUNT           ; the program continues
        LDA     SPACE           ; in this state until
        CMP     HALFDOT         ; a space has been
        BCC     MORE            ; detected.
STATE3: ASL     CHAR            ; In state 3 a decision
        LDA     MARK            ; is made to see if
        CMP     DDOT            ; the element was a dot
        BCC     ARND            ; or a dash.
        INC     CHAR            ; The character register
        LSR     A               ; is updated.
        LSR     A
        STA     MARK
        LSR     A
        CLC
        ADC     MARK
        STA     MARK
ARND:   JSR     CAL             ; Jump to automatic
        LDA     #$00            ; calibration routine.
        STA     MARK
LOAF:   JSR     COUNT
        LDA     MARK
        CMP     THFTDOT         ; Wait for another element.
        BCS     STATE2          ; Back to state 2.
        LDA     SPACE           ; Wait for a character space.
        CMP     DDOT
        BCC     LOAF
        JSR     OUTPUT          ; Output the character.
        LDA     #$01
        STA     CHAR            ; Reset the character
LOITER: JSR     COUNT           ; Register. Wait
        LDA     MARK            ; for mark or a wordspace.
        CMP     THFTDOT
        BCS     STATE2
        LDA     SPACE
        CMP     FDOT
        BCC     LOITER
        JSR     OUTPUT          ; Output the space.
        LDA     #$00
        BEQ     RPT
TIMER:  LDA     #$52            ; Subroutine timer
        STA     T1L
        LDA     #$05
        STA     T1H
        LDA     T2CL
        STA     STORE
        RTS
COUNT:  CLI                     ; Subroutine to count
        SEI                     ; pulses from the
WAIT:   BIT     IFR             ; receiver.
        BVC     WAIT
        SEC
        LDA     STORE
        SBC     T2CL
        STA     TEMP
        JSR     TIMER
        LDA     TEMP
        BEQ     AHED
        CLC
        ADC     MARK
        STA     MARK
        CLC
        BCC     DETOUR
AHED:   INC     SPACE
DETOUR: RTS
CAL:    LDA     DOT             ; Calibration subroutine.
        ASL     DOT
        ADC     DOT
        ADC     MARK
        LSR     A
        LSR     A
        CMP     #$0F
        BCS     SKIP
        LDA     #$0F
SKIP:   STA     DOT
        ASL     A
        STA     DDOT
        ASL     A
        CLC
        ADC     DOT
        STA     FDOT
        LDA     DOT
        LSR     A
        STA     HALFDOT
        LSR     A
        ADC     HALFDOT
        STA     THFTDOT
        RTS
OUTPUT: LDA     CHAR            ; Output subroutine.
        TAY
        LDA     TAB,Y
        ORA     #$80
        JSR     COUT
        RTS

; Morse Code-to-ASCII Lookup Table

        .ORG    $0E80

TAB:    .BYTE   $20, $20, $45, $54, $49, $41, $4E, $4D
        .BYTE   $53, $55, $52, $57, $44, $4B, $47, $4F
        .BYTE   $48, $56, $46, $20, $4C, $20, $50, $4A
        .BYTE   $42, $58, $43, $59, $5A, $51, $20, $20
        .BYTE   $35, $34, $20, $33, $20, $20, $20, $32
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $31
        .BYTE   $36, $3D, $2F, $20, $20, $20, $20, $20
        .BYTE   $37, $20, $20, $20, $38, $20, $39, $30
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $20, $20, $20, $20, $20
        .BYTE   $20, $20, $20, $2C
