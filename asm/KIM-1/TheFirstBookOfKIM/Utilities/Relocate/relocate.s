; following addresses must be initialized
; by user prior to run

        ALOC    = $E0
        LIMIT   = $E3
        PAGLIM  = $E7           ; limit above which kill relocn
        ADJST   = $E8           ; adjustment distance (signed)
        POINT   = $EA           ; start of program
        BOUND   = $EC           ; lower boundary for adjustment

; main program starts here

       .ORG    $0110

START:  CLD
        LDY     #0
        LDA     (POINT),Y       ; get op code
        TAY                     ; +cache in Y
        LDX     #7
LOOP:   TYA                     ; restore op code
        AND     TAB1-1,X        ; remove unwanted bits
        EOR     TAB2-1,X        ; & test the rest
        BEQ     FOUND
        DEX                     ; on to the next test
        BNE     LOOP            ; ...if any
FOUND:  LDY     TAB3,X          ; length or flag
        BMI     TRIP            ; triple length?
        BEQ     BRAN            ; branch?
SKIP:   INC     POINT           ; moving right along..
        BNE     INEX            ; ..to next op code
        INC     POINT+1
INEX:   DEY
        BNE     SKIP
        BEQ     START

; length 3 or illegal

TRIP:   INY
        BMI     START+2         ; illegal/end to BRK halt
        INY                     ; set Y to 1
        LDA     (POINT),Y       ; lo-order operand
        TAX                     ; ...into X reg
        INY                     ; Y=2
        LDA     (POINT),Y       ; hi-order operand
        JSR     ADJUST          ; change address, maybe
        STA     (POINT),Y       ; ...and put it back
        DEY                     ; Y=1
        TXA
        STA     (POINT),Y       ; ...also hi-order
        LDY     #3              ; Y=3
        BPL     SKIP

; branch: check "to" and "from" address

BRAN:   INY                     ; Y=1
        LDX     POINT           ; "from" addrs lo-order
        LDA     POINT+1         ; ...& hi-order
        JSR     ADJUST          ; change, maybe
        STX     ALOC            ; save lo-order only
        LDX     #$FF            ; flag for "back" branches
        LDA     (POINT),Y       ; get relative branch
        CLC
        ADC     #2              ; adjust the offset
        BMI     OVER            ; backwards branch?
        INX                     ; nope
OVER:   STX     LIMIT
        CLC
        ADC     POINT           ; calculate "to" lo-order
        TAX                     ; ...and put in X
        LDA     LIMIT           ; 00 or FF
        ADC     POINT+1         ; "to" hi-order
        JSR     ADJUST          ; change, maybe
        DEX                     ; readjust the offset
        DEX
        TXA
        SEC
        SBC     ALOC            ; recalculate relative branch
        STA     (POINT),Y       ; and re-insert
        INY                     ; Y=2
        BPL     SKIP

; examine address and adjust, maybe

ADJUST: CMP     PAGLIM
        BCS     OUT             ; too high?
        CMP     BOUND+1
        BNE     TES2            ; hi-order?
        CPX     BOUND           ; lo-order?
TES2:   BCC     OUT             ; too low?
        PHA                     ; stack hi-order
        TXA
        CLC
        ADC     ADJST           ; adjust lo-order
        TAX
        PLA                     ; unstack hi-order
        ADC     ADJST+1         ; and adjust
OUT:    RTS

; tables for op-code indentification

TAB1:   .BYTE   $0C, $1F, $0D, $87, $1F, $FF, $03
TAB2:   .BYTE   $0C, $19, $08, $00, $10, $20, $03
TAB3:   .BYTE   $02, $FF, $FF, $01, $01, $00, $FF, $FE

; end
