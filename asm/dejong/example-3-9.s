CLEAR   =       $C070
PAD0    =       $C064
PRBYTE  =       $FDDA
CROUT   =       $FD8E

        .org    $1049

AGAIN:  ldx     #$00            ; Initialize counter to zero.
        lda     CLEAR           ; Start the timer integrated circuit.
WAIT:   lda     PAD0            ; Read the paddle port.
        bpl     OUT             ; Get out when bit seven is zero.
STAY:   inx                     ; Otherwise, increment the counter
        bne     WAIT            ; Test the paddle again.
OUT:    txa                     ; Transfer the counter to A.
        jsr     PRBYTE          ; Output the number in A.
        jsr     CROUT           ; Output a carriage return.
        jmp     AGAIN           ; Repeat the entire procedure.
