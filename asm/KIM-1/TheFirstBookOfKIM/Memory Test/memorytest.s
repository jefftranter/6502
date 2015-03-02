        .org $0000

POINTL  = $FA
POINTH  = $FB
FLAG    = $70
FLIP    = $71
MOD     = $72
START   = $1C4F

BEGIN:  .byte   $00             ; starting page for test
END:    .byte   $00             ; ending page for test

STRT:   LDA     #0              ; zero pointers
        TAY                     ; for low-order
        STA     POINTL          ; addresses;
BIGLP:  STA     FLAG            ; =00 first pass, =FF second pass
        LDX     #2
        STX     MOD             ; set 3 tests each pass
PASS:   LDA     BEGIN           ; set pointer to..
        STA     POINTH          ; ..start of test area
        LDX     END
        LDA     FLAG
        EOR     #$FF            ; reverse FLAG
        STA     FLIP            ; ..=FF first pass, =00 second pass
CLEAR:  STA     (POINTL),Y      ; write above FLIP value..
        INY                     ; ..into all locations
        BNE     CLEAR
        INC     POINTH
        CPX     POINTH
        BCS     CLEAR
; FLIP value in all locations - now change 1 in 3
        LDX     MOD
        LDA     BEGIN           ; set pointer..
        STA     POINTH          ; ..back to start
FILL:   LDA     FLAG            ; change value
TOP:    DEX
        BPL     SKIP            ; skip 2 out of 3
        LDX     #2              ; restore 3-counter
        STA     (POINTL),Y      ; change 1 out of 3
SKIP:   INY
        BNE     TOP
        INC     POINTH          ; new page
        LDA     END             ; have we passed..
        CMP     POINTH          ; ..end of test area?
        BCS     FILL            ; nope, keep going
; memory set up - now we test it
        LDA     BEGIN           ; set pointer..
        STA     POINTH          ; ..back to start
        LDX     MOD             ; set up 3-counter
POP:    LDA     FLIP            ; test for FLIP value..
        DEX                     ; ..2 out of 3 times..
        BPL     SLIP            ; - or -
        LDX     #2              ; 1 out of 3..
        LDA     FLAG            ; test for FLAG value;
SLIP:   CMP     (POINTL),Y      ; here's the test...
        BNE     OUT             ; branch if failed
        INY
        BNE     POP
        INC     POINTH
        LDA     END
        CMP     POINTH
        BCS     POP
; above test OK - change & repeat
        DEC     MOD             ; change 1/3 position
        BPL     PASS            ; ..& do next third
        LDA     FLAG            ; invert..
        EOR     #$FF            ; ..flag for pass two
        BMI     BIGLP
OUT:    STY     POINTL          ; put low order adds to display
        JMP     START           ; ..and exit to KIM
