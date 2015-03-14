        OSAL    = $D0
        OSAH    = $D1
        OEAL    = $D2
        OEAH    = $D3
        NSAL    = $D4
        NSAH    = $D5
        NEAL    = $D6
        NEAH    = $D7
        BCL     = $D8
        BCH     = $D9

        .ORG    $1780

START:  CLD
        LDY     #$FF            ; STORE TEST VALUE
        SEC
        LDA     OEAL            ; HOW MANY BYTES?
        SBC     OSAL            ; TO MOVE?
        STA     BCL
        LDA     OEAH
        SBC     OSAH
        STA     BCH
        CLC
        LDA     BCL             ; ADD THE COUNT TO
        ADC     NSAL            ; THE NEW START TO
        STA     NEAL            ; GET A NEW END
        LDA     BCH
        ADC     NSAH
        STA     NEAH
        INC     BCL             ; ADJUST THE BYTE COUNT
        INC     BCH             ; TO PERMIT ZERO TESTING
        SEC
        LDA     NSAL            ; IF NEW LOCATION
        SBC     OSAL            ; HIGHER THAN OLD
        LDA     NSAH            ; CARRY FLAG IS SET
        SBC     OSAH
LOOP:   LDX     #$00            ; HIGH POINTER INDEX
        BCC     MOVE
        LDX     #$02            ; LOW POINTER INDEX
MOVE:   LDA     (OSAL,X)        ; MOVE OLD. NOTE ERROR IN PRINTED LISTING
        STA     (NSAL,X)        ; TO NEW. NOTE ERROR IN PRINTED LISTING
        BCC     DOWN
        DEC     OEAL            ; ADJUST UP POINTER, (OLD)
        TYA                     ; BELOW ZERO?
        EOR     OEAL
        BNE     NOT             ; NO, ENOUGH
        DEC     OEAH            ; YES, ADJUST THE HIGH BYTE
NOT:    DEC     NEAL            ; ADJUST THE OTHER ONE (NEW)
        TYA
        EOR     NEAL            ; NEED HIGH BYTE ADJUSTED?
        BNE     NEIN            ; NO
        DEC     NEAH            ; YES, DO IT
NEIN:   BCS     COUNT
DOWN:   INC     OSAL            ; ADJUST "OLD" DOWN POINTER
        BNE     NYET
        INC     OSAH            ; AND THE HIGH BYTE IF NEEDED
NYET:   INC     NSAL            ; AND THE "NEW" ONE
        BNE     COUNT
        INC     NSAH
COUNT:  DEC     BCL             ; TICK OFF THE BYTES,
        BNE     ONE             ; ENOUGH FINGERS?
        DEC     BCH             ; USE THE OTHER HAND
ONE:    BNE     LOOP            ; 'TIL THEY'RE ALL DONE
DONE:   BRK                     ; & BACK TO MONITOR
