        WAIT    = $F3
        DIGIT   = $F4
        POINTL  = $FA
        POINTH  = $FB
        TEMP    = $FC
        TMPX    = $FD
        CHAR    = $FE
        MODE    = $FF

        GOEXEC  = $1DC8
        SCAND   = $1F19
        INCPT   = $1F63
        GETKEY  = $1F6A

        .ORG    $0110

START:  CLD                     ; clear decimal mode
        LDA     #$13            ; GO key image
        STA     CHAR
        LDA     #$0             ; value zero..
        STA     POINTL          ; ..to address pointer
        STA     POINTH
LOOP:   DEC     WAIT            ; main program loop
        BNE     LP1             ; pause 1 second
        LDA     TMPX            ; up or down?
        BEQ     LP1             ; neither
        BPL     UP
        LDA     POINTL          ; down, decrement
        BNE     DOWN            ; next page?
        DEC     POINTH
DOWN:   DEC     POINTL
LP1:    JSR     SCAND           ; light display
        JSR     GETKEY          ; check keys
        CMP     CHAR            ; same key as last time?
        BEQ     LOOP
        STA     CHAR            ; note new key input
        CMP     #$15            ; no key?
        BEQ     LOOP            ; yes, skip
        LDX     #0
        STX     TMPX            ; clear up/down flag
        CMP     #$10            ; numeric?
        BCC     NUM             ; yes, branch
        STX     DIGIT
        CMP     #$11            ; DA?
        BEQ     OVER            ; yes, leave X=0
        INX                     ; no, set X=1
OVER:   STX     MODE            ; 0 or 1 into MODE
        CMP     #$12            ; +?
        BNE     PASS            ; no, skip
        INC     TMPX            ; yes, set browse
PASS:   CMP     #$14            ; PC?
        BNE     PASS2           ; no, skip
        DEC     TMPX            ; yes, down-browse
PASS2:  CMP     #$13            ; GO?
        BNE     LP1             ; no, loop
        JMP     GOEXEC          ; start program

; numeric (hex) entry comes here

NUM:    ASL     A               ; position digit
        ASL     A
        ASL     A               ; to left
        ASL     A
        STA     TEMP
        LDX     #4              ; 4 bits to move
        LDY     MODE            ; AD or DA?
        BNE     ADDR            ; branch if AD node
        DEC     DIGIT           ; time to step?
        BPL     SAME            ; no, skip
        JSR     INCPT           ; yes, step
        INC     DIGIT           ; ..and restore
        INC     DIGIT           ; ..digit count
SAME:   LDA     (POINTL),Y      ; get data
DADA:   ASL     TEMP            ; move a bit..
        ROL     A               ; ..into data
        STA     (POINTL),Y
        DEX
        BNE     DADA            ; last bit?
        BEQ     LP1             ; yes, exit
ADDR:   ASL     A               ; move bits
        ROL     POINTL          ; into address
        ROL     POINTH
        DEX
        BNE     ADDR
        BEQ     LP1

; increment address for browsing

UP:     JSR     INCPT
        TAX
        BPL     LP1
        .end
