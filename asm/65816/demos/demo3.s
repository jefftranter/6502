; 65816 Programming Example 3

; Determine CPU type.
; Taken from Western Design Center programming manual.

  .org $6000

  .p816
  .smart

MAIN:
        LDX #<S1
        LDY #>S1
        JSR PrintString         ; Display "CPU TYPE IS: " string
        JSR CHECK               ; Get CPU type
        BMI T02                 ; N set means 6502
        BCC TC02                ; C clear means 65C02
        BCS T816                ; C set means 65816
T02:
        LDX #<S2                ; Display "6502"
        LDY #>S2
        JMP PRINT
TC02:
        LDX #<S3                ; Display "65C02"
        LDY #>S3
        JMP PRINT
T816:
        LDX #<S4                ; Display "65816"
        LDY #>S4
PRINT:
        JSR PrintString
        RTS

S1: .byte CR,"CPU TYPE IS: ",0
S2: .byte "6502",CR,0
S3: .byte "65C02",CR,0
S4: .byte "65816",CR,0

; CHECK - -
; CHECK PROCESSOR TYPE
; MINUS = 6502
; CARRY CLEAR = 65C02
; CARRY SET = 65816

CHECK:
  SED           ; Trick with decimal mode used
  LDA #$99      ; set negative flag
  CLC
  ADC #$01      ; add 1 to get new accum value of 0
  BMI DONE      ; branch if 0 does not clear negative flag: 6502

; else 65C02 or 65802 if neg flag cleared by decimal-mode arith

  CLC
  XCE           ; OL to execute unimplemented C02 opcodes
  BCC DONE      ; branch if didn’t do anything: 65C02
  XCE           ; switch back to emulation mode
  SEC           ; set carry
DONE:
  CLD           ; binary
  RTS

; -------------------------

  T1      = $30                 ; Temp variable 1 (2 bytes)
  CR      = $0D                 ; Carriage Return
  DSP     = $D012               ;  PIA.B display output register

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null.
; Cannot be longer than 256 characters.
; Registers changed: A, Y
;
PrintString:
        STX T1
        STY T1+1
        LDY #0
@loop:  LDA (T1),Y
        BEQ done
        JSR PrintChar
        INY
        BNE @loop               ; if doesn't branch, string is too long
done:   RTS

; Output a character
; Pass byte in A
; Based on Woz Monitor ECHO routine ($FFEF).
; Registers changed: none
PrintChar:
       BIT DSP                  ; bit (B7) cleared yet?
       BMI PrintChar            ; No, wait for display.
       STA DSP                  ; Output character. Sets DA.
       RTS                      ; Return.
