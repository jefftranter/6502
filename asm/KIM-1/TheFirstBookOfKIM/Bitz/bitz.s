        .org    $0200

MOD     = $11
PREV    = $14
SEED    = $15
SEED1   = $16
SEED2   = $17
FLAG1   = $1C
FLAG2   = $1D
TIMER   = $1704
SAD     = $1740
SADD    = $1741
SBD     = $1742
TABLE   = $1FE7
KEYIN   = $1F40
GETKEY  = $1F6A

START:  CLD
        LDA     #1              ; Set FLAG2
        STA   FLAG2             ; ..to new problem
MAIN:   JSR   KEYIN             ; set directnl reg
        JSR   GETKEY            ; get key input
        CMP   PREV              ; same as last time?
        BEQ   LIGHT             ; yes, skip
        STA   PREV              ; record new input
        CMP   #$15              ; no key?
        BEQ   NOKEY             ; yes, brnch
        LDX   FLAG1             ; first digit found?
        BNE   DIG1              ; yes, check second
        CMP   SEED1             ; first digit match?
        BNE   LIGHT             ; no, ignore input
        TAX
        LDA   TABLE,X           ; change to segment
        STA   FLAG1             ; ..store.
        BNE   LIGHT             ; ..and exit
DIG1:   CMP   SEED2             ; second digit match?
        BNE   LIGHT             ; no, ignore input
        TAX
        LDA   TABLE,X           ; change to segment
        STA   FLAG2
        BNE   LIGHT
NOKEY:  LDX   FLAG2             ; problem solved?
        BEQ   LIGHT             ; not yet, skip
        LDA   #0                ; Clear..
        STA   FLAG1             ; ..for new problem
        STA   FLAG2
        LDA   TIMER             ; get random value
        TAX
        AND   #$0F              ; extract last digit
        STA   SEED2             ; ..and store
        TXA
        LSR   A                 ; Extract first digit
        LSR   A
        LSR   A
        LSR   A
        STA   SEED1             ; ..and store
        STX   SEED              ; Store whole number
        LDX   #$FC              ; Minus 4 for window
PATT:   LDA   #0                ; Clear Accum
        ROL   SEED              ; ..then roll in..
        ROL   A                 ; ..two bits..
        ROL   SEED              ; ..and..
        ROL   A                 ; ..convert..
        TAY                     ; ..to..
        LDA   TAB,Y             ; ..segments
        STA   FLAG1,X
        INX                     ; next segment
        BNE   PATT
LIGHT:  LDA   #$7F              ; Set directional..
        STA   SADD              ; ..registers
        LDY   #9
        LDX   #$FA              ; Minus 6
SHOW:   LDA   FLAG2+1,X         ; Window contents
        STA   SAD
        STY   SBD
WAIT:   DEC   MOD
        BNE   WAIT
        INY
        INY
        INX
        BMI   SHOW
        BPL   MAIN
TAB:    .BYTE $14,$12,$24,$22

; end
