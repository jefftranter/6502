; Tracking. Chapter 9.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; Stop button. Make A0 and B0 be output and A7 be input.

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$01
        STA     DIRA
        LDA     #$01
        STA     DIRB

; Put an initial value in for DELTA.

        LDA      #$01
        STA      z:DELTA

; ALFA1 is the beginning of the outermost loop of the program. The
; command signal gets changed whenever the OUTCOUNT goes to zero. We
; start with it equal to 20h. To slow down the rate of change of the
; command signal use a larger integer.

ALFA1:  LDA      #$01
        STA      z:OUTCOUNT

; This point of the program sets the sampling time to 127. We compute
; the current value of the error and reset the sample count B to zero.

ALFA2:  LDX      #127            ; Decimal
        LDA      z:N
        LSR                      ; Divide N by two
        CLC
        ADC      z:CMND
        STA      z:ERROR         ; ERROR = N/2 + CMND
        LDA      #$00
        STA      z:N


; Now we get down to the meat. This is the innermost loop of the
; program. We are going to sample the input voltage to see if it is
; bigger than or smaller than the trigger voltage. The we will send
; out a correction signal on the A to D feedback line (A0). Finally
; we output a 1 on the meter circuit if we have counted down on X so
; far that it is less than the ERROR we wish to display. Otherwise
; we output a 0. Remember: there are two separate outputs here; A0
; is the feedback to the A to D converter and B0 is the output to
; drive the meter display.

ALFA3:  LDA      PORTA
        BPL      ISZERO
        LDA      #$01
        STA      PORTA           ; Set A0=1
        JMP      COMBINE
ISZERO: LDA      #$00
        STA      PORTA           ; Set A0=0
        INC      z:N
COMBINE:
        CPX      z:ERROR
        BMI      MINER           ; Go if X < ERROR
        LDA      #$00
        JMP      DISPLAY
MINER:  LDA      #$01            ; X < ERROR
DISPLAY:
        STA      PORTB           ; Set display
        DEX
        BNE      ALFA3           ; If X != 0 do inner loop again
        DEC      z:OUTCOUNT
        BNE      ALFA2           ; We haven't done the outer
                                 ;  loop 20 times yet


; It is time to update the command signal. We add DELTA to the
; command. If the result is 0 or 63 we reverse the sign of delta.
; Otherwise we just go back to ALFA1.

        LDA      z:CMND
        CLC
        ADC      z:DELTA         ; CMND = CMND + DELTA
        STA      z:CMND
        BEQ      MAKEPLUS        ; If CMND = 0
        CMP      #$63
        BEQ      MAKEMIN         ; If CMND = 63
        JMP      ALFA1
MAKEPLUS:
        LDA      #$01
        STA      z:DELTA
        JMP      ALFA1
MAKEMIN:
        LDA      #$FF
        STA      z:DELTA
        JMP      ALFA1

; We need the following variables:

N:     .BYTE     $00             ; Count of the number of zeros
                                 ; put out as feedback
ERROR: .BYTE     $00             ; Sum of response and command
OUTCOUNT:
       .BYTE     $00             ; Times around the outer loop
DELTA: .BYTE     $00             ; Increment for command
CMND:  .BYTE     $00             ; The signal the response is
                                 ; supposed to equal
