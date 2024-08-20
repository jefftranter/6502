; Digital Clock. Chapter 8.
; Note that you need to put a jumper on the AUX IRQ header.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
IRQV    = $17FE
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703
PORTC   = $1740
DIRC    = $1741
PORTD   = $1742
DIRD    = $1743

; When we load the program from tape the address register ends up
; pointing at cell zero. We will use the first 6 cells to hold hours,
; minutes, and seconds in decimal.

TH:     .BYTE   $00             ; Tens of hours
H:      .BYTE   $00             ; Hours
TM:     .BYTE   $00             ; Tens of minutes
M:      .BYTE   $00             ; Minutes
TS:     .BYTE   $00             ; Tens of seconds
S:      .BYTE   $00             ; Seconds

; Now we will set up the stop key, clear decimal mode, set the stack
; pointer and make ports C and D both be output. Store the address
; 0200 (INTER) in the IRQ interrupt vector address 17FE/F so that a
; time out will take us to INTER:

SETTIME:
        CLD                     ; Clear decimal mode
        LDX     #$FF
        TXS
        STX     DIRC            ; These ports control
        STX     DIRD            ; the display in KIM
        LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        CLI                     ; Enable interrupt
        LDA     #<INTER         ; Set up
        STA     IRQV            ; interrupt
        LDA     #>INTER         ; address
        STA     IRQV+1

; We will call the subroutine BINARIZE to convert the new time to
; binary and start up the timer with B7 as input:

        LDX     #$00            ; X says which character to
        JSR     BINARIZE        ;  pick up
        STA     z:HRS
        LDX     #$02
        JSR     BINARIZE
        STA     z:MIN
        LDX     #$04
        JSR     BINARIZE
        STA     z:SECS
        LDA     #$00
        STA     DIRB
        LDA     #$FF
        STA     $170E           ; Start timer counting in 64's

; We now set up to drive the display. We begin with the left most
; display character called 08 by KIM. We look up the first thing to
; be displayed stored in 0000 (the tens of hours) and translate it
; to the segment code using the table in the KIM stored at 1FE7. We
; put that translation in PORTC and then delay for about 5 milli-
; seconds:

DISPLAY:
        LDA     #$08
        STA     PORTD
        LDX     #$00            ; Point to first character
MOVE:   LDY     $0000,X         ; Load Y indexed by X
        LDA     $1FE7,Y         ; Get translation
        STA     PORTC
        LDA     #$00
        STA     z:COUNT
DELAY:  DEC     z:COUNT
        BNE     DELAY

; Now we bump the index register X by 1 to get the next character and
; bump the number in port B by 2 so it points out the next display
; character. If we have done less than 6 characters we go back to
; MOVE. Otherwise we go to DISPLAY.

        INX
        INC     PORTD
        INC     PORTD
        CPX     #$06
        BMI     MOVE
        JMP     DISPLAY

; The BINARIZE subroutine is short so we put it in here:

BINARIZE:
        LDA     $0000,X         ; Get the first character
        ASL                     ; Shift left 2 places
        ASL                     ;  so have 4N
        CLC
        ADC     $0000,X         ; Add N so we have 5N
        ASL                     ; Shift left so have 10N
        CLC
        ADC     $0001,X         ; Add units in
        RTS                     ; Return

; The address of the following routine is stored in the IRQ vector so
; each time the timer times out we will come to this routine. We
; preserve context, restart the timer and see if we have had 61d time
; outs. That makes just one second. If less than one second
; we return from interrupt. Otherwise we go to COUNTREC.

INTER:  PHA
        TXA                     ; Save A,X and Y on stack
        PHA
        TYA
        PHA
        LDA     #$FF            ; Restart timer
        STA     $170E
        DEC     z:TIMES
        BEQ     ONESEC          ; Have completed one second
RESTORE:
        PLA
        TAY
        PLA
        TAX
        PLA
        RTI
ONESEC: LDA     #61
        STA     z:TIMES

; Now we count up the number of seconds that have gone by. If less
; than 60 we go to convert seconds to display:

COUNTSEC:
        INC     z:SECS
        LDA     z:SECS
        CMP     #60
        BPL     COUNTMINS
        JMP     CONSEC

; If the seconds have counted out past 59 to 60 we have to change the
; minutes so we do: first resetting the seconds to 0:

COUNTMINS:
        LDA     #$00
        STA     z:SECS
        INC     z:MIN
        LDA     z:MIN
        CMP     #60
        BPL     COUNTHRS
        JMP     CONMIN

; After 59 minutes (60 really, counting 0) we have to change the hour
; display. After 12 o'clock we say 1 o'clock, not zero.

COUNTHRS:
        LDA     #$00
        STA     z:MIN
        INC     z:HRS
        LDA     z:HRS
        CMP     #13
        BPL     RSTHRS
        JMP     CONHRS
RSTHRS: LDA     #$01
        STA     z:HRS

; This last instruction falls through to CONHRS. Now every time we
; change the hours display we have certainly got to change the minutes
; (from 59 to 0) and whenever we change minutes we have to change the
; seconds. each time we get a value in the accumulator and jump off
; to a CVT subroutine that does the work. It returns with tens in X
; and units in A. Then we go back to the interrupted main program
; after restoring registers.

CONHRS: LDA     z:HRS
        JSR     CVT
        STX     TH
        STA     H
CONMIN: LDA     z:MIN
        JSR     CVT
        STX     TM
        STA     M
CONSEC: LDA     z:SECS
        JSR     CVT
        STX     TS
        STA     S
        JMP     RESTORE

; The CVT routine needs to change a binary number to a two digit
; decimal number. We do it by brute force subtraction:

CVT:    LDX     #$00
        SEC                     ; Set carry
CVLP:   SBC     #$0A            ; Subtract 10d
        BMI     TOOFAR
        INX
        JMP     CVLP
TOOFAR: ADC     #$0A            ; Add back in the last decade
        RTS

TIMES:  .BYTE   $00
COUNT:  .BYTE   $00
SECS:   .BYTE   $00
MIN:    .BYTE   $00
HRS:    .BYTE   $00
