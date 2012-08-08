;
; Test and demonstration of the floating point math routines
;
; Copyright (C) 2012 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;

; Revision History
; Version Date         Comments
; 0.0     03-Aug-2012  First version started
; 0.1     08-Aug-2012  Hooked up DeJong BDC/binary code

        .include "wozfp.s"

        .include "bcdfloat.s"

        .export FPDEMO

; Entry point.
FPDEMO:
        JSR ClearScreen         ; Clear screen
        JSR SetupBrkHandler     ; Set up BRK (error) handler
        JSR Help                ; Display help info

; Main command loop.
Command:
        LDX #<PromptString      ; Print command prompt
        LDY #>PromptString
        JSR PrintString

        JSR GetKey              ; Get a key
        JSR PrintChar           ; Echo the command
        JSR PrintCR             ; and newline
        JSR OPICK               ; Call option picker to run appropriate command
        JMP Command             ; Go back and get next command

; Print error message for invalid command.
Invalid:
        LDX #<InvalidString
        LDY #>InvalidString
        JSR PrintString
        RTS

; Convert a fixed point number to float.
FixedToFloat:
        LDX #<FixedToFloatString
        LDY #>FixedToFloatString
        JSR PrintString
        LDX #<Enter16BitHexString       ; Prompt user for number
        LDY #>Enter16BitHexString
        JSR PrintString
        JSR GetByte
        STA M1                          ; High byte
        JSR GetByte
        STA M1+1                        ; Low byte
        JSR PrintCR
        JSR FLOAT                       ; Convert to float
        LDX #<FloatingPointIsString
        LDY #>FloatingPointIsString
        JSR PrintString

; Result comes back in M1 (3 byte mantissa) and X1 (1 byte exponent).
; Display the exponent followed by a space then three mantissa bytes.

        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Convert floating point to fixed point.
FloatToFixed:
        LDX #<FloatToFixedString
        LDY #>FloatToFixedString
        JSR PrintString
        LDX #<EnterFloatString
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR
        JSR FIX                 ; Returns in M1 (high) and M1+1 (low)
        LDX #<FixedPointIsString
        LDY #>FixedPointIsString
        JSR PrintString
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        JSR PrintCR
        RTS

; Natural log -- log to base e or ln(x)
NaturalLog:
        LDX #<NaturalLogString
        LDY #>NaturalLogString
        JSR PrintString

        LDX #<EnterFloatString          ; Get float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        JSR LOG                          ; Take the log

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Common log -- log to base 10 or log(x)
CommonLog:
        LDX #<CommonLogString
        LDY #>CommonLogString
        JSR PrintString

        LDX #<EnterFloatString          ; Get float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        JSR LOG10                        ; Take the log

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; exp(x) i.e. e^x
Exponential:
        LDX #<ExponentialString
        LDY #>ExponentialString
        JSR PrintString

        LDX #<EnterFloatString          ; Get float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        JSR EXP                          ; Calculate the exponent

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Add two floating point numbers.
Add:
        LDX #<AddString
        LDY #>AddString
        JSR PrintString

        LDX #<EnterFloatString          ; Get first float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        LDX #<EnterFloatString          ; Get second float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X2
        JSR PrintSpace
        JSR GetByte
        STA M2
        JSR GetByte
        STA M2+1
        JSR GetByte
        STA M2+2
        JSR PrintCR

        JSR FADD                         ; Do the add

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Substract two floating point numbers (first minus second).
Subtract:
        LDX #<SubtractString
        LDY #>SubtractString
        JSR PrintString

        LDX #<EnterFloatString          ; Get first float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X2
        JSR PrintSpace
        JSR GetByte
        STA M2
        JSR GetByte
        STA M2+1
        JSR GetByte
        STA M2+2
        JSR PrintCR

        LDX #<EnterFloatString          ; Get second float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        JSR FSUB                         ; Do the subtract

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Multiply two floating point numbers.
Multiply:
        LDX #<MultiplyString
        LDY #>MultiplyString
        JSR PrintString

        LDX #<EnterFloatString          ; Get first float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        LDX #<EnterFloatString          ; Get second float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X2
        JSR PrintSpace
        JSR GetByte
        STA M2
        JSR GetByte
        STA M2+1
        JSR GetByte
        STA M2+2
        JSR PrintCR

        JSR FMUL                         ; Do the multiply

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; Divide two floating point numbers (first divided by second).
Divide:
        LDX #<DivideString
        LDY #>DivideString
        JSR PrintString

        LDX #<EnterFloatString          ; Get first float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X2
        JSR PrintSpace
        JSR GetByte
        STA M2
        JSR GetByte
        STA M2+1
        JSR GetByte
        STA M2+2
        JSR PrintCR

        LDX #<EnterFloatString          ; Get second float number
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA X1
        JSR PrintSpace
        JSR GetByte
        STA M1
        JSR GetByte
        STA M1+1
        JSR GetByte
        STA M1+2
        JSR PrintCR

        JSR FDIV                         ; Do the divide

        LDX #<ResultIsString             ; Display result
        LDY #>ResultIsString
        JSR PrintString
        LDA X1
        JSR PrintByte
        JSR PrintSpace
        LDA M1
        JSR PrintByte
        LDA M1+1
        JSR PrintByte
        LDA M1+2
        JSR PrintByte
        JSR PrintCR
        RTS

; String to floating point.
StringToFloat:
        LDX #<StringToFloatingPointString
        LDY #>StringToFloatingPointString
        JSR PrintString
        LDX #<EnterFPString
        LDY #>EnterFPString
        JSR PrintString
        JSR START
        LDX #<FloatingPointIsString
        LDY #>FloatingPointIsString
        JSR PrintString
        LDA BEXP                        ; Contains the binary exponent, bit seven is the sign bit.
        JSR PrintByte
        JSR PrintSpace
        LDA MSB                         ; Most-significant byte of the accumulator.
        JSR PrintByte
        LDA NMSB                        ; Next-most-significant byte of the accumulator.
        JSR PrintByte
        LDA NLSB                        ; Next-least-significant byte of the accumulator.
        JSR PrintByte
        LDA LSB                         ; Least-significant byte of the accumulator.
        JSR PrintByte
        JSR PrintSpace
        LDA MFLAG                       ; Set to $FF when a minus sign is entered.
        Jsr PrintByte
        JSR PrintCR
        RTS

; Floating point to ASCII string
FloatToString:
        LDX #<FloatingPointToStringString
        LDY #>FloatingPointToStringString
        JSR PrintString
        LDX #<EnterFloatString
        LDY #>EnterFloatString
        JSR PrintString
        JSR GetByte
        STA BEXP                                ; Exponent
        JSR PrintSpace
        JSR GetByte
        STA MSB
        JSR GetByte
        STA NMSB
        JSR GetByte
        STA NLSB
        JSR GetByte
        STA LSB
        JSR PrintSpace
        JSR GetByte
        STA MFLAG                               ; Minus flag
        JSR PrintCR
        LDX #<FloatingPointIsString
        LDY #>FloatingPointIsString
        JSR PrintString
        JSR BEGIN
        RTS

; Display help information.
Help:
        LDX #<IntroString
        LDY #>IntroString
        JSR PrintString
        RTS

; Exit command. Return to caller of the program by popping return
; address so we return to caller of main.
Exit:
        PLA
        PLA
        RTS

; Install handler to jump to our routine when BRK occurr due to an error.
SetupBrkHandler:
        LDA $FFFE               ; get address of BRK vector
        STA T1                  ; and save in page zero
        LDA $FFFF
        STA T1+1
        LDA #$4C                ; JMP instruction
        LDY #0
        STA (T1),Y              ; store at IRQ/BRK vector
        LDA #<BreakHandler      ; handler address low byte
        INY
        STA (T1),Y              ; write it after JMP
        LDA #>BreakHandler      ; handler address low byte
        INY
        STA (T1),Y              ; write it after JMP
        RTS

; Called when BRK instruction is executed due to an error.
; Display the address (actually address+2) where break occurred.
BreakHandler:
        LDX #<ErrorString
        LDY #>ErrorString
        JSR PrintString
        PLA                      ; P
        PLA                      ; PC low
        TAX
        PLA                      ; PC high
        TAY
        JSR PrintAddress
        JSR PrintCR
        JMP Command

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
        .byte "FPLNEASMDBT?X"

JMPFL:
        .word Invalid-1
        .word FixedToFloat-1
        .word FloatToFixed-1
        .word NaturalLog-1
        .word CommonLog-1
        .word Exponential-1
        .word Add-1
        .word Subtract-1
        .word Multiply-1
        .word Divide-1
        .word StringToFloat-1
        .word FloatToString-1
        .word Help-1
        .word Exit-1

; Strings

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
        .byte "B - STRING TO FLOATING POINT",CR
        .byte "T - FLOATING POINT TO STRING",CR
        .byte "? - THIS HELP SCREEN",CR
        .byte "X - EXIT",CR,0

PromptString:
        .byte CR, "SELECT A FUNCTION: ",0

InvalidString:
        .byte "INVALID COMMAND, TYPE '?' FOR HELP",CR,0

FixedToFloatString:
       .byte "FIXED TO FLOATING POINT",CR,0

Enter16BitHexString:
       .byte "ENTER 16-BIT HEX NUMBER: ",0

FloatingPointIsString:
        .byte "FLOATING POINT IS: ",0

FloatToFixedString:
       .byte "FLOATING TO FIXED POINT",CR,0

EnterFloatString:
        .byte "ENTER EXPONENT AND MANTISSA: ",0

EnterFPString:
       .byte "ENTER FP STRING: ",0

FixedPointIsString:
        .byte "FIXED POINT IS: ",0

AddString:
        .byte "FLOATING POINT ADD",CR,0

SubtractString:
        .byte "FLOATING POINT SUBTRACT",CR,0

MultiplyString:
        .byte "FLOATING POINT MULTIPLY",CR,0

DivideString:
        .byte "FLOATING POINT DIVIDE",CR,0

StringToFloatingPointString:
        .byte "STRING TO FLOATING POINT",CR,0

FloatingPointToStringString:
        .byte "FLOATING POINT TO STRING",CR,0

NaturalLogString:
        .byte "NATURAL LOG",CR,0

CommonLogString:
        .byte "COMMON LOG",CR,0

ExponentialString:
        .byte "EXPONENTIAL",CR,0

ResultIsString:
        .byte "RESULT IS: ",0

ErrorString:
        .byte "ERROR OCCURRED AT ADDRESS $",0
