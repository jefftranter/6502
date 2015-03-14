        POINT   = $E0
        INH     = $F9

        SAD     = $1740
        PADD    = $1741
        SBD     = $1742
        PBOD    = $1743
        SAVX    = $17E9
        OUTCH   = $197A
        PACKT   = $1A00
        RDCHT   = $1A24
        RDBIT   = $1A41
        TABLE   = $1FE7

        .ORG    $0000

START:  CLD
        LDA     #$7F
        STA     PADD            ; set display dir reg
SYN:    LDA     #$13            ; ..window 6 and tape in
        STA     POINT           ; and keep pointer
        STA     SBD
        JSR     RDBIT           ; get a bit and
        LSR     INH             ; ..slip it into
        ORA     INH             ; ..the right-hand
        STA     INH             ; ..side:
        STA     SAD             ; show bit flow on display
TST:    CMP     #$16            ; ..is it a SYNC?
        BNE     SYN             ; nope, keep 'em rolling
        JSR     RDCHT           ; yup, start grabbing
        CMP     #$2A            ; ..8 bits at a time and..
        BNE     TST             ; ..if ifs not an "*"..
STREAM: LDA     #$00            ; ..then start showing
        STA     SAVX            ; ..characters 1 at a time
        JSR     RDCHT
        JSR     PACKT           ; ..converting to hexadec,.
        BNE     SYN             ; ..if legal
        LDX     POINT
        INX
        INX                     ; Move along to next..
        CPX     #$15            ; ..display position
        BNE     OVER            ; (If last digit,..
        LDX     #$09            ; ..reset to first)
OVER:   STX     POINT
        STX     SBD
        TAX                     ; change character read
        LDA     TABLE,X         ; ..to segments and..
        STA     SAD             ; send to the display
        BNE     STREAM          ; unconditional jump
        .RES    7
;
; Make a test tape containing an endless stream of SYNC characters
; with the following program:

        .ORG    $0050

GO:     LDY     #$BF            ; directional..
        STY     PBOD            ; ...registers
LP:     LDA     #$16            ; SYNC
        JSR     OUTCH           ; ...out to tape
        BNE     LP
