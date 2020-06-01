; Experiment 2
;
; Set Timer 1 to free running mode and toggle PB7 line.
; With 2MHz clock, maximum speed is 500KHz (COUNT = $0000)
; Minimum rate 15.26Hz (COUNT = $FFFF)
; Actual frequency is  f = PH2/(2(n+2))
; e.g. for 60Hz with 2MHz PH2 n = 16665 = $4119
; comes out to 59.9988 Hz
; Note that this takes no CPU power once set up.
; If used for a clock, error is more than 1 minute per day.
; unless you use a value that comes out to an exact frequency.
;
; BASIC program to find counts that result in exact frequencies:
; 100  FOR I = 0 TO 65535
; 110 F = 1000000 / (I + 2)
; 120  IF F =  INT (F) THEN  PRINT I;" ";F
; 130  NEXT I
;
; Output:
; COUNT FREQ (HZ)
; 0 500000
; 2 250000
; 3 200000
; 6 125000
; 8 100000
; 14 62500
; 18 50000
; 23 40000
; 30 31250
; 38 25000
; 48 20000
; 62 15625
; 78 12500
; 98 10000
; 123 8000
; 158 6250
; 198 5000
; 248 4000
; 318 3125
; 398 2500
; 498 2000
; 623 1600
; 798 1250
; 998 1000
; 1248 800
; 1598 625
; 1998 500
; 2498 400
; 3123 320
; 3998 250
; 4998 200
; 6248 160
; 7998 125
; 9998 100
; 12498 80
; 15623 64
; 19998 50
; 24998 40
; 31248 32
; 39998 25
; 49998 20
; 62498 16
; 
; Good choice for a real-time clock might be 100Hz.
; Will do this in a later experiment.
;
       .org $0280
       .include "6522.inc"

        COUNT = $4119

        LDA #$00
        STA IER             ; disable all interrupts
        LDA #%11000000
        STA ACR             ; Set to T1 free running PB7 enabled
        LDA #<COUNT
        STA T1CL            ; Low byte of count
        LDA #>COUNT
        STA T1CH            ; High byte of count
        RTS
