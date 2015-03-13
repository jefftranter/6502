        INH     = $F9
        POINTH  = $FB

        SBD     = $1742
        RDBYT   = $19F3
        RDCHT   = $1A24
        RDBIT   = $1A41
        SCANDS  = $1F1F

        .ORG    $0000

GO:     CLD
        LDA     #$07            ; Directional reg
        STA     SBD
SYN:    JSR     RDBIT           ; Scan thru bits...
        LSR     INH             ; ..shifting new bit
        ORA     INH             ; ..into left of
        STA     INH             ; ..byte INH
TST:    CMP     #$16            ; SYNC character?
        BNE     SYN             ; no, back to bits
        JSR     RDCHT           ; get a character
        DEC     INH             ; count 22 SYNC's
        BPL     TST
        CMP     #$2A            ; then test astk
        BNE     TST             ; ..or SYNC
        LDX     #$FD            ; if asterisk,
RD:     JSR     RDBYT           ; stack 3 bytes
        STA     POINTH+1,x      ; into display
        INX                     ; area
        BMI     RD
SHOW:   JSR     SCANDS          ; ...and shine
        BNE     GO              ; until keyed
        BEQ     SHOW            ; at's all folks
