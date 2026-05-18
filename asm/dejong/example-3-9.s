CLEAR   =       $C070
PAD0    =       $C064
PRBYTE  =       $FDDA
CROUT   =       $FD8E

        .ORG    $1049

AGAIN:  LDX     #$00            ; Initialize counter to zero.
        LDA     CLEAR           ; Start the timer integrated circuit.
WAIT:   LDA     PAD0            ; Read the paddle port.
        BPL     OUT             ; Get out when bit seven is zero.
STAY:   INX                     ; Otherwise, increment the counter
        BNE     WAIT            ; Test the paddle again.
OUT:    TXA                     ; Transfer the counter to A.
        JSR     PRBYTE          ; Output the number in A.
        JSR     CROUT           ; Output a carriage return.
        JMP     AGAIN           ; Repeat the entire procedure.
