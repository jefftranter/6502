        RND     = $E0
        NGUESS  = $E1
        LAST    = $E2
        INH     = $F9
        POINTL  = $FA
        POINTH  = $FB

        SCANDS  = $1F1F
        KEYIN   = $1F40
        GETKEY  = $1F6A

        .ORG    $0200


START:  SED
TOP:    LDA     RND             ; generate random #
        SEC                     ; 01 to 98
        ADC     #0
        LDX     #1              ; overflow at 99
        CMP     #$99
        BNE     OVR0
        TXA
OVR0:   STA     RND
        JSR     KEYIN
        BNE     TOP
        CLD                     ; initialize:
        LDA     #$99            ; hi
        STA     POINTH
        LDA     #0
        STA     POINTL          ; and lo
RSET:   LDX     #$A0            ; guess counter
NSET:   STX     INH
        STX     NGUESS
GUESS:  JSR     SCANDS          ; light display
        JSR     GETKEY          ; test key
        CMP     #$13            ; go key?
        BEQ     START
        CMP     LAST
        BEQ     GUESS           ; same key?
        STA     LAST
        CMP     #$0A            ; 'A' key?
        BEQ     EVAL            ; yes, evaluate guess
        BCS     GUESS           ; no key?
        ASL     A               ; roll character
        ASL     A               ; ..into..
        ASL     A               ; position..
        ASL     A
        LDX     #3
LOOP:   ASL     A               ; ..then
        ROL     INH             ; ..into
        DEX                     ; ..display
        BPL     LOOP
        BMI     GUESS
EVAL:   LDA     INH             ; guess lower..
        CMP     RND             ; ..than number?
        BCC     OVR1            ; yes, skip
        CMP     POINTH          ; no, check hi
        BCS     GUESS           ; out of range?
        STA     POINTH
OVR1:   LDX     RND             ; number lower..
        CPX     INH             ; ..than guess?
        BCC     OVR2            ; yes, skip
        LDX     POINTL          ; no,check lo
        CPX     INH
        BCS     GUESS           ; out of range?
        STA     POINTL
OVR2:   LDX     NGUESS          ; 'guess' number
        INX                     ; ..plus 1
        CPX #$AA                ; past limit?
        BEQ RSET                ; yes, reset
        BNE NSET
