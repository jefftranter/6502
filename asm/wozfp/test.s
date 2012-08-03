; Tests of the floating point math routines

        .include "wozfp.s"

TEST1:

; Convert a fixed point number 274 ($0112) to float

        LDA #$01
        STA M1          ; High byte
        LDA #$12
        STA M1+1        ; Low byte
        JSR FLOAT       ; Convert to float

; Result comes back in M1 (3 byte mantissa) and X (1 byte exponent)
;      _____    _____    _____    _____ 
;     |     |  |     |  |     |  |     |
;FP1  | $88 |  | $44 |  | $80 |  |  0  |   (+274)
;     |_____|  |_____|  |_____|  |_____|
;
;       X1       M1

        RTS

TEST2:

; Convert a floating point number (above) to fixed point.
; Returns in M1 (high) and M1+1 (low)

        LDA #$88
        STA X1
        LDA #$44
        STA M1
        LDA #$80
        STA M1+1
        LDA #$0
        STA M1+2
        JSR FIX
        RTS
