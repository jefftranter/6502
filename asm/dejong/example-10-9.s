GRAPH1  =       $152E
GRAPH2  =       $153A
ATOD    =       $19C0

        .ORG    $1A00

        JSR     GRAPH1          ; Subroutine in example 6-18.
AGAIN:  JSR     ATOD            ; Subroutine in example 10-8.
        JSR     GRAPH2          ; Subroutine in example 6-18.
WAIT:   LDA     $C000           ; Read keyboard.
        BPL     WAIT            ; Wait for key.
        LDA     $C010           ; Reset keyboard flip-flop.
        JMP     AGAIN           ; Get another set of data.

; Subroutines GRAPH1 and GRAPH2 call subroutines
; in examples 6-15 AND 6-16.
