;
; Test and demonstration of the floating point math routines
;

        .include "wozfp.s"

;   FLOATING POINT DEMONSTRATION PROGRAM
; 
; F - FIXED TO FLOATING POINT
; P - FLOATING TO FIXED POINT
; N - NATURAL LOG
; L - COMMON LOG
; E - EXPONENTIAL
; A - FLOATING POINT ADD
; S - FLOATING POINT SUBTRACT
; M - FLOATING POINT MULTIPLY
; D - FLOATING POINT DIVIDE
; ? - THIS HELP SCREEN
; X - EXIT
; 
; SELECT A FUNCTION: 1
; FIXED TO FLOATING POINT
; ENTER 16-BIT HEX NUMBER: 00 0C
; FLOATING POINT IS: 83  60 00 00
; 
; SELECT A FUNCTION: 2
; FLOATING TO FIXED POINT
; ENTER 8-BIT EXPONENT and 24-BIT MANTISSA: 83 60 00 00
; FIXED POINT IS: 00 0C
; 
; SELECT A FUNCTION: 6
; FLOATING POINT ADD
; ENTER 8-BIT EXPONENT and 24-BIT MANTISSA: 83 60 00 00
; ENTER 8-BIT EXPONENT and 24-BIT MANTISSA: 83 60 00 00
; RESULT IS: 84 52 00 00

        .export FPDEMO
FPDEMO:
        JSR ClearScreen
        JSR Help

; TODO: Use command table code from JMON

Command:
        LDX #<PromptString
        LDY #>PromptString
        JSR PrintString         ; Print command prompt

        JSR GetKey              ; Get a key
        JSR PrintChar           ; Echo the command
        JSR PrintCR             ; and newline
        JSR OPICK               ; Call option picker to run appropriate command

        JMP Command

; Print error message for invalid command.
Invalid:
        LDX #<InvalidString
        LDY #>InvalidString
        JSR PrintString
        
        RTS

FixedToFloat:

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

FloatToFixed:

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

NaturalLog:
CommonLog:
Exponential:
Add:
Subtract:
Multiply:
Divide:
        RTS

; Display help information.
Help:
        LDX #<IntroString
        LDY #>IntroString
        JSR PrintString
        RTS

; Return to caller of the program by popping return address so we return to caller of main.
Exit:
        PLA
        PLA
        RTS

; Option picker. Adapted from "Assembly Cookbook for the Apple II/IIe" by Don Lancaster.
; Call with command letter in A.
; Registers affected: X
OPICK:
        TAY                     ; save A
        LDX #MATCHN             ; Get legal number of matches
SCAN:   CMP MATCHFL,X           ; Search for a match
        BEQ GOTMCH              ; Found
        DEX                     ; Try next
        BPL SCAN

GOTMCH: INX                     ; Makes zero a miss
        TXA                     ; Get jump vector
        ASL A                   ; Double pointer
        TAX
        LDA JMPFL+1,X           ; Get page address first!
        PHA                     ; and force on stack
        LDA JMPFL,X             ; Get position address
        PHA                     ; and force on stack
        TYA                     ; restore A
        RTS                     ; Jump via forced subroutine return

; Matchn holds the number of matches.
; Matchfl holds the legal characters.
; JMPFL holds the jump vectors (minus 1).

        MATCHN = JMPFL-MATCHFL

MATCHFL:
        .byte "FPLNEASMD?X"

JMPFL:
        .word Invalid-1
        .word FloatToFixed-1
        .word FixedToFloat-1
        .word NaturalLog-1
        .word CommonLog-1
        .word Exponential-1
        .word Add-1
        .word Subtract-1
        .word Multiply-1
        .word Divide-1
        .word Help-1
        .word Exit-1

IntroString:
        .byte "FLOATING POINT DEMONSTRATION PROGRAM",CR,CR
        .byte "F - FIXED TO FLOATING POINT",CR
        .byte "P - FLOATING TO FIXED POINT",CR
        .byte "L - NATURAL LOG",CR
        .byte "N - COMMON LOG",CR
        .byte "E - EXPONENTIAL",CR
        .byte "A - FLOATING POINT ADD",CR
        .byte "S - FLOATING POINT SUBTRACT",CR
        .byte "M - FLOATING POINT MULTIPLY",CR
        .byte "D - FLOATING POINT DIVIDE",CR
        .byte "? - THIS HELP SCREEN",CR
        .byte "X - EXIT",CR,0

PromptString:
        .byte "SELECT A FUNCTION: ",0

InvalidString:
        .byte "INVALID COMMAND, TYPE '?' FOR HELP",CR,0
