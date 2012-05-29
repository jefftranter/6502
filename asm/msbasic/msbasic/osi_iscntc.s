.segment "CODE"
ISCNTC:
        lda     $D011           ; keyboard status
        bmi     L0ECC           ; branch if key pressed
        rts                     ; return
L0ECC:
        lda     $D010           ; get key data
        cmp     #$83            ; is it Ctrl-C ?
;!!! *used*to* run into "STOP"
