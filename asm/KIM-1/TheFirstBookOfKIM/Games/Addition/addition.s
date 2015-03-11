        .org    $0200

SCANDS  = $1F1F
GETKEY  = $1F6A
PREV    = $60
FLAG    = $61
ACCUM   = $62
INH     = $F9
POINTL  = $FA
POINTH  = $FB

START:  JSR     SCANDS          ; light display
        JSR     GETKEY          ; read keyboard
        CMP     PREV            ; same as last time?
        BEQ     START           ; yes, skip
        STA     PREV            ; no, save new key
        CMP     #$0A            ; numeric key?
        BCC     NUM             ; yes, branch
        CMP     #$13            ; GO key?
        BEQ     DOGO            ; yes, branch
        CMP     #$12            ; + key?
        BNE     START           ; no, invalid key
        SED                     ; prepare to add
        CLC
        LDX     #$FD            ; minus 3; 3 digits
ADD:    LDA     POINTH+1,X      ; display digit
        ADC     ACCUM+3,X       ; add total
        STA     POINTH+1,X      ; total to display
        STA     ACCUM+3,X       ; add total
        INX                     ; next digit
        BMI     ADD             ; last digit?
        STX     FLAG            ; flag total-in-display
        CLD
        BPL     START           ; return to start
DOGO:   LDA     #0              ; set flag for
        STA     FLAG            ; total-in-display
        LDX     #2              ; for 3 digits...
CLEAR:  STA     INH,X           ; clear display
        DEX                     ; next digit
        BPL     CLEAR           ; last digit?
        BMI     START           ; finished, back to go
NUM:    LDY     FLAG            ; total-in-display?
        BNE     PASS            ; no, add new digit
        INC     FLAG            ; clear t-i-d flag
        PHA                     ; save key
        LDX     #2              ; 3 digits to move
MOVE:   LDA     INH,X           ; get display digit
        STA     ACCUM,X         ; copy to total Accum
        STY     INH,X           ; clear display
        DEX                     ; next digit
        BPL     MOVE            ; last digit?
        PLA                     ; recall key
PASS:   ASL     A               ; move digit..
        ASL     A               ; ..into position
        ASL     A
        ASL     A
        LDX     #4              ; 4 bits
SHIFT:  ASL     A               ; move bit from A
        ROL     INH             ; ..to INH..
        ROL     POINTL          ; ..to rest of
        ROL     POINTH          ; display
        DEX                     ; next bit
        BNE     SHIFT           ; last bit?
        BEQ     START           ; yes, back to start
