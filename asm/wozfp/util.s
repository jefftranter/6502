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


  T1      = $30                 ; Temp variable 1 (2 bytes)
T2:       .res 1                ; Temp variable 2

; Constants
  CR      = $0D                 ; Carriage Return
  SP      = $20                 ; Space
  ESC     = $1B                 ; Escape

; Hardware addresses
  KBD     = $D010               ; PIA.A keyboard input
  KBDCR   = $D011               ; PIA.A keyboard control register
  DSP     = $D012               ; PIA.B display output register

; -------------------- Utility Functions --------------------

; Get character from keyboard
; Returns character in A
; Clears high bit to be valid ASCII
; Registers changed: A
GetKey:
        LDA KBDCR               ; Read keyboard control register
        BPL GetKey              ; Loop until key pressed (bit 7 goes high)
        LDA KBD                 ; Get keyboard data
        AND #%01111111          ; Clear most significant bit to convert to standard ASCII
        RTS

; Gets a hex digit (0-9,A-F). Echoes character as typed.
; ESC key cancels command and goes back to command loop.
; If RETOK is zero, ignore Return key.
; If RETOK is non-zero, pressing Return will cause it to return with A=0 and carry set.
; If CHAROK is non-zero, pressing a single quote allows entering a character.
; Ignores invalid characters. Returns binary value in A
; Registers changed: A
GetHex:
        JSR GetKey
        CMP #'0'
        BMI GetHex              ; Invalid, ignore and try again
        CMP #'9'+1
        BMI @Digit
        CMP #'A'
        BMI GetHex              ; Invalid, ignore and try again
        CMP #'F'+1
        BMI @Letter
        JMP GetHex              ; Invalid, ignore and try again
@Digit:
        JSR PrintChar           ; echo
        SEC
        SBC #'0'                ; convert to value
        CLC
        RTS
@Letter:
        JSR PrintChar           ; echo
        SEC
        SBC #'A'-10             ; convert to value
        CLC
        RTS

; Get Byte as 2 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns byte in A
; If RETOK is zero, ignore Return key.
; If RETOK is non-zero, pressing Return as first character will cause it to return with A=0 and carry set.
; If CHAROK is non-zero, pressing a single quote allows entering a character.
; Registers changed: A
GetByte:
        JSR GetHex
        BCC @NotRet
        RTS                     ; <Return> was pressed, so return
@NotRet:
        PHA                     ; Save character
        PLA
        ASL
        ASL
        ASL
        ASL
        STA T1                  ; Store first nybble
@IgnoreRet:
        JSR GetHex
        BCS @IgnoreRet          ; If <Return> pressed, ignore it and try again
        CLC
        ADC T1                  ; Add second nybble
        STA T1                  ; Save it
        LDA T1                  ; Get value to return
        RTS

; Get Address as 4 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns address in X (low), Y (high)
; Registers changed: X, Y
GetAddress:
        PHA                     ; Save A
        JSR GetByte             ; Get the first (most significant) hex byte
        BCS @RetPressed         ; Quit if Return pressed
        TAY                     ; Save in Y
        JSR GetByte             ; Get the second (least significant) hex byte
        TAX                     ; Save in X
@RetPressed:
        PLA                     ; Restore A
        RTS

; Print 16-bit address in hex
; Pass byte in X (low) and Y (high)
; Registers changed: None
PrintAddress:
        PHA                     ; Save A
        TYA                     ; Get low byte
        JSR PRBYTE              ; Print it
        TXA                     ; Get high byte
        JSR PRBYTE              ; Print it
        PLA                     ; Restore A
        RTS

; Print byte in hex
; Pass byte in A
; Registers changed: None
PrintByte:
        JSR PRBYTE              ; Just call PRBYTE routine
        RTS

; Print byte as ASCII character or "."
; Pass character in A.
; Registers changed: None
PrintAscii:
        CMP #$20                ; first printable character (space)
        BMI NotAscii
        CMP #$7E+1              ; last printable character (~)
        BPL NotAscii
        JSR PrintChar
        RTS
NotAscii:
        PHA                     ; save A
        LDA #'.'
        JSR PrintChar
        PLA                     ; restore A
        RTS

; Print a carriage return
; Registers changed: None
PrintCR:
        PHA
        LDA #CR
        JSR PrintChar
        PLA
        RTS

; Print a space
; Registers changed: None
PrintSpace:
        PHA
        LDA #SP
        JSR PrintChar
        PLA
        RTS

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null (zero).
; Registers changed: None
;
PrintString:
        PHA             ; Save A
        TYA
        PHA             ; Save Y
        STX T1          ; Save in page zero so we can use indirect addressing
        STY T1+1
        LDY #0          ; Set offset to zero
@loop:  LDA (T1),Y      ; Read a character
        BEQ done        ; Done if we get a null (zero)
        JSR PrintChar   ; Print it
        CLC             ; Increment address
        LDA T1          ; Low byte
        ADC #1
        STA T1
        BCC @nocarry
        INC T1+1        ; High byte
@nocarry:
        JMP @loop       ; Go back and print next character
done:
        PLA
        TAY             ; Restore Y
        PLA             ; Restore A
        RTS

; Print byte as two hex chars.
; Taken from Woz Monitor PRBYTE routine ($FFDC).
; Pass byte in A
; Registers changed: A
PRBYTE:
        PHA             ; Save A for LSD.
        LSR
        LSR
        LSR             ; MSD to LSD position.
        LSR
        JSR PRHEX       ; Output hex digit.
        PLA             ; Restore A.
                        ; Falls through into PRHEX routine

; Print nybble as one hex digit.
; Take from Woz Monitor PRHEX routine ($FFE5).
; Pass byte in A
; Registers changed: A
PRHEX:
        AND #$0F        ; Mask LSD for hex print.
        ORA #'0'+$80    ; Add "0".
        CMP #$BA        ; Digit?
        BCC PrintChar   ; Yes, output it.
        ADC #$06        ; Add offset for letter.
                        ; Falls through into PrintChar routine

; Output a character
; Pass byte in A
; Based on Woz Monitor ECHO routine ($FFEF).
; Registers changed: none
PrintChar:
        PHP             ; Save status
        PHA             ; Save A as it may be changed
@Loop:
        BIT DSP         ; bit (B7) cleared yet?
        BMI @Loop       ; No, wait for display.
        STA DSP         ; Output character. Sets DA.
        PLA             ; Restore A
        PLP             ; Restore status
        RTS             ; Return.

; Output a character multiple times
; A contains character to print.
; X contains number of times to print.
; Registers changed: X
PrintChars:
        JSR PrintChar
        DEX
        BNE PrintChars
        RTS

; Clear screen by printing 24 carriage returns.
; Registers changed: none
ClearScreen:
        PHA             ; save A
        TXA             ; save X
        PHA
        LDA #CR
        LDX #24
        JSR PrintChars
        PLA             ; restore X
        TAX
        PLA             ; restore A
        RTS
