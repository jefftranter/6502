; A BCD to Floating-Point Binary Routine
; Marvin L. De Jong
; from Compute! Issue 9 / February 1981 / Page 46

; A Floating-Point Binary to BCD  Routine
; Marvin L. De Jong
; from Compute! Issue 11 / April 1981 / Page 66

; Note: The original listing had many errors (e.g. "#" missing). These have been corrected.

        OVFLO  = $00           ; overflow byte for the accumulator when it is shifted left or multiplied by ten.
        MSB    = $01           ; most-significant byte of the accumulator.
        NMSB   = $02           ; next-most-significant byte of the accumulator.
        NLSB   = $03           ; next-least-significant byte of the accumulator.
        LSB    = $04           ; least-significant byte of the accumulator.
        BEXP   = $05           ; contains the binary exponent, bit seven is the sign bit.
        CHAR   = $06           ; used to store the character input from the keyboard.
        MFLAG  = $07           ; set to $FF when a minus sign is entered.
        DPFLAG = $08           ; decimal point flag, set when decimal point is entered.
        ESIGN  = $0A           ; set to $FF when a minus sign is entered for the exponent.
        MEM    = $00           ; ???
        ACC    = $00           ; ???
        ACCB   = $10           ; ???
        TEMP   = $0B           ; temporary storage location.
        EVAL   = $0C           ; value of the decimal exponent entered after the "E."
        DEXP   = $17           ; current value of the decimal exponent.
        BCDA   = $20           ; BCD accumulator (5 bytes)
        BCDN   = $25           ; ???

; Listing 3. A Floating-Point Binary to BCD Routine.

BEGIN:  LDA MSB         ; Test MSB to see if mantissa is zero.
        BNE BRT         ; If it is, print a zero and then get out.
        LDA #'0'        ; Get ASCII zero.
        JSR OUTCH       ; Jump to output subroutine.
        RTS             ; Return to calling routine.
BRT:    LDA #$00        ; Clear OVFLO location.
        STA OVFLO
BRY:    LDA BEXP        ; Is the binary exponent negative?
        BPL BRZ         ; No.
        JSR TENX        ; Yes. Multiply by ten until the exponent is not negative.
        JSR NORM
        DEC DEXP        ; Decrement decimal exponent.
        CLV             ; Force a jump.
        BVC BRY         ; Repeat.
BRZ:    LDA BEXP        ; Compare the binary exponent to
        CMP #$20        ; $20 = 32.
        BEQ BCD         ; Equal. Convert binary to BCD.
        BCC BRX1        ; Less than.
        JSR DIVTEN      ; Greater than. Divide by ten until BEXP is less than 32.
        INC DEXP
        CLV             ; Force a jump.
        BVC BRZ
BRX1:   LDA #$00        ; Clear OVFLO
        STA OVFLO
BRW:    JSR TENX        ; Multiply by ten.
        JSR NORM        ; Then normalize.
        DEC DEXP        ; Decrement decimal exponent.
        LDA BEXP        ; Test binary exponent.
        CMP #$20        ; Is it 32?
        BEQ BCD         ; Yes.
        BCC BRW         ; It's less than 32 so multiply by 10.
        JSR DIVTEN      ; It's greater than 32 so divide.
        INC DEXP        ; Increment decimal exponent.
BRU:    LDA BEXP        ; Test binary exponent.
        CMP #$20        ; Compare with 32.
        BEQ BRV         ; Shift mantissa right until exponent
        LSR MSB         ; is 32.
        ROR NMSB
        ROR NLSB
        ROR LSB
        ROR TEMP        ; Least-significant bit into TEMP.
        INC BEXP        ; Increment exponent for each shift
        CLV             ; right.
        BVC BRU
BRV:    LDA TEMP        ; Test to see if we need to round
        BPL BCD         ; up. No.
        SEC             ; Yes. Add one to mantissa.
        LDX #$04
BRS:    LDA ACC,X
        ADC #$00
        STA ACC,X
        DEX
        BNE BRS
BCD:    JSR CONVD       ; Jump to 32 bit binary-to-BCD routine.
BRMA:   LDY #$04        ; Rotate BCD accumulator right until non-significant zeros are shifted out or DEXP is zero, whichever comes first.
BRP:    LDX #$04
        CLC
BRQ:    ROR BCDA,X
        DEX
        BPL BRQ
        DEY
        BNE BRP
        INC DEXP        ; Increment exponent for each shift right. Get out when DEXP = 0.
        BEQ BROA
        LDA BCDA        ; Has a non-zero digit been shifted into the least-significant place?
        AND #$0F
        BEQ BRMA        ; No. Shift another digit.
BROA:
        LDA MFLAG
        BEQ BRNA        ; If the sign of the number is minus, output a minus sign first.
        LDA #'-'
        JSR OUTCH       ; ASCII " - " = $2D. Output character.
BRNA:   LDA #$0B        ; Set digit counter to eleven.
        STA TEMP
BRI:    LDY #$04        ; Rotate BCD accumulator left to output most-significant digits first. But first bypass zeros.
BRH:    CLC
        LDX #$FB
BRG:    ROL BCDN,X
        INX
        BNE BRG
        ROL OVFLO       ; Rotate digit into OVFLO.
        DEY
        BNE BRH
        DEC TEMP        ; Decrement digit counter.
        LDA OVFLO       ; Is the rotated digit zero?
        BEQ BRI         ; Yes. Rotate again.
BRX:    CLC             ; Convert digit to ASCII and output it.
        ADC #'0'
        JSR OUTCH
        LDA #$00        ; Clear OVFLO for next digit.
        STA OVFLO
        LDY #$04        ; Output the remaining digits.
BRL:    CLC
        LDX #$FB
BRJ:    ROL BCDN,X      ; Rotate a digit at a time into
        INX             ; OVFLO, then output it. One digit is four bits or one nibble.
        BNE BRJ
        ROL OVFLO
        DEY
        BNE BRL
        LDA OVFLO       ; Get digit.
        DEC TEMP        ; Decrement digit counter.
        BNE BRX
        LDA DEXP        ; Is the decimal exponent zero?
        BEQ ARND1       ; Yes. No need to output exponent.
        LDA #'.'        ; Get ASCII decimal point.
        JSR OUTCH       ; Output it.
        LDA #'E'        ; Get ASCII "E".
        JSR OUTCH
        LDA DEXP        ; Is the decimal exponent plus?
        BPL THERE       ; Yes.
        LDA #'-'        ; No. Output ASCII " - "
        JSR OUTCH
        LDA DEXP        ; It's minus, so complement it and add one to form the twos complement.
        EOR #$FF
        STA DEXP
        INC DEXP
THERE:  LDA #$00        ; Clear OVFLO.
        STA OVFLO
        SED             ; Convert exponent to BCD.
        LDY #$08
BR1A:   ROL DEXP
        LDA OVFLO
        ADC OVFLO
        STA OVFLO
        DEY
        BNE BR1A
        CLD
        CLC
        LDA OVFLO       ; Get BCD exponent.
        AND #$F0        ; Mask low-order nibble (digit).
        BEQ BR2A
        ROR A           ; Rotate nibble to the right.
        ROR A
        ROR A
        ROR A
        ADC #'0'        ; Convert to ASCII.
        JSR OUTCH       ; Output the most-significant digit.
BR2A:   LDA OVFLO       ; Get the least-significant digit.
        AND #$0F        ; Mask the high nibble.
        CLC
        ADC #'0'        ; Convert to ASCII.
        JSR OUTCH
ARND1:
        RTS             ; All finished.

; Listing 2. Multiply by Ten Subroutine.

TENX:   CLC             ; Shift accumulator left.
        LDX #$04        ; Accumulator contains four bytes so X is set to four.
BR1:    LDA ACC,X
        ROL A           ; Shift a byte left.
        STA ACCB,X      ; Store it in accumulator B.
        DEX
        BPL BR1         ; Back to get another byte.
        LDX #$04        ; Now shift accumulator B left once again to get "times four."
        CLC
BR2:    ROL ACCB,X      ; Shift one byte left.
        DEX
        BPL BR2         ; Back to get another byte.
        LDX #$04        ; Add accumulator to accumulator B to get A + 4* A = 5* A.
        CLC
BR3:    LDA ACC,X
        ADC ACCB,X
        STA ACC,X       ; Result into accumulator.
        DEX
        BPL BR3
        LDX #$04        ; Finally, shift accumulator left one bit to get 2*5* A = 10* A.
        CLC
BR4:    ROL ACC,X
        DEX
        BPL BR4         ; Get another byte.
        RTS

; Listing 3. Normalize the Mantissa Subroutine.

NORM:   CLC
BR6:    LDA OVFLO       ; Any bits set in the overflow byte? Yes, then rotate right.
        BEQ BR5
        LSR OVFLO       ; No, then rotate left.
        ROR MSB
        ROR NMSB
        ROR NLSB
        ROR LSB         ; For each shift right, increment binary exponent.
        INC BEXP
        CLV             ; Force a jump back.
        BVC BR6
BR5:    BCC BR7         ; Did the last rotate cause a carry? Yes, then round the mantissa upward.
        LDX #$04
BR8:    LDA ACC,X
        ADC #$00        ; Carry is set so one is added
        STA ACC,X
        DEX
        BPL BR8
        BMI BR6         ; Check overflow byte once more.

BR7:    LDY #$20        ; Y will limit the number of left shifts to 32.
BR10:   LDA MSB
        BMI BR11        ; If mantissa has a one in its most-significant bit, get out.
        CLC
        LDX #$04
BR9:    ROL ACC,X       ; Shift accumulator left one bit.
        DEX
        BNE BR9
        DEC BEXP        ; Decrement binary exponent for each left shift.
        DEY
        BNE BR10        ; No more than $20 = 32 bits shifted.
BR11:   RTS             ; That's it.


; Listing 5. A 32 Bit Binary-to-BCD Subroutine.

CONVD:  LDX #$05        ; Clear BCD accumulator.
        LDA #$00
BRM:    STA BCDA,X      ; Zeros into BCD accumulator.
        DEX
        BPL BRM
        SED             ; Decimal mode for add.
        LDY #$20        ; Y has number of bits to be converted. Rotate binary number into carry.
BRN:    ASL LSB
        ROL NLSB
        ROL NMSB
        ROL MSB
        LDX #$FB        ; X will control a five byte addition. Get least-significant byte of the BCD accumulator, add is to itself, then store.
BRO:    LDA BCDN,X
        ADC BCDN,X
        STA BCDN,X
        INX             ; Repeat until all five bytes have been added.
        BNE BRO
        DEY             ; Get another bit from the binary number.
        BNE BRN
        CLD             ; Back to binary mode.
        RTS             ; And back to the program.

; Listing 1: ASCII to Floating-Point Binary Conversion Program

START:  CLD             ; Decimal mode not required
        LDX #$20        ; Clear all the memory locations used for storage by this routine by loading them with zeros.
        LDA #$00
CLEAR:  STA MEM,X
        DEX
        BPL CLEAR
        JSR INPUT       ; Get ASCII representation of
        CMP #'+'        ; BCD digit. Is it a + sign?
        BEQ PLUS        ; Yes, get another character.   
        CMP #'-'        ; Is it a minus sign?
        BNE NTMNS
        DEC MFLAG       ; Yes, set minus flag to $FF.
PLUS:   JSR INPUT       ; Get the next character.
NTMNS:  CMP #'.'        ; Is character a decimal point?
        BNE DIGIT       ; No. Perhaps it is a digit. Yes, check flag.
        LDA DPFLAG      ; Was the decimal point flag set?
        BNE NORMIZ      ; Time to normalize the mantissa.
        INC DPFLAG      ; Set decimal point flag, and get the next character.
        BNE PLUS
DIGIT:  CMP #$30        ; Is the character a digit?
        BCC NORMIZ      ; No, then normalize the mantissa.
        CMP #$3A        ; Digits have ASCII representations between $30 and $39.
        BCS NORMIZ
        JSR TENX        ; It was a digit, so multiply the accumulator by ten and add the new digit. First strip the ASCII prefix by subtracting $30.
        LDA CHAR
        SEC
        SBC #$30
        CLC             ; Add the new digit to the least-significant byte of the accumulator.
        ADC LSB
        STA LSB         ; Next, any "carry" will be added to the other bytes of the accumulator.
        LDX #$03
ADDIG:  LDA #$00
        ADC ACC,X       ; Add carry here.
        STA ACC,X       ; And save result.
        DEX
        BPL ADDIG       ; The new digit has been added.
        LDA DPFLAG      ; Check the decimal point flag.
        BEQ PLUS        ; If not set, get another character.
        DEC DEXP        ; If set, decrement the exponent, then get another character.
        BMI PLUS
NORMIZ: JSR NORM        ; Normalize the mantissa.
        CLC             ; Clear carry for addition.
        LDA BEXP        ; Get binary exponent.
        ADC #$20        ; Add $20 = 32 to place binary
        STA BEXP        ; point properly.
        LDA MSB         ; If the MSB of the accumulator is zero, then the number is zero, and its all over. Otherwise, check if the last character was an "E".
        BEQ FINISH1     ; Original listing branched to FINISH but that is too far to reach.
        LDA CHAR
        CMP #'E'
        BNE TENPRW      ; If not, move to TENPRW.
        JSR INPUT       ; If so, get another character.
        CMP #'+'        ; Is it a plus?
        BEQ PAST        ; Yes, then get another character.
        CMP #'-'        ; Perhaps it was a minus?
        BNE NUMB        ; No, then maybe it was a number.
        DEC ESIGN       ; Set exponent sign flag.
PAST:   JSR INPUT       ; Get another character.
NUMB:   CMP #'0'        ; Is it a digit?
        BCC TENPRW      ; No, more to TENPRW.
        CMP #$3A
        BCS TENPRW
        SEC             ; It was a digit, so strip ASCII prefix.
        SBC #'0'        ; ASCII prefix is $30.
        STA TEMP        ; Keep the first digit here.
        JSR INPUT       ; Get another character.
        CMP #'0'        ; Is it a digit?
        BCC HERE        ; No. Then finish handling the exponent.
        CMP #$3A
        BCS HERE
        SEC             ; Yes. Decimal exponent is new digit plus 10 times the old digit.
        SBC #'0'
        STA EVAL        ; Strip ASCII prefix from new digit.
        LDA TEMP        ; Get the old character and multiply it by ten. First times two.
        ASL A
        ASL A           ; Times two again makes times four.
        CLC
        ADC TEMP        ; Added to itself makes times five.
        ASL A           ; Times two again makes time ten.
        STA TEMP        ; Store it.
HERE:   CLC             ; Add the new digit, to the exponent.
        LDA TEMP
        ADC EVAL
        STA EVAL        ; Here is the exponent, except for its sign. Was it a negative?
        LDA ESIGN
        BEQ POSTV       ; No.
        LDA EVAL        ; Yes, then form its twos complement by complementation followed by adding one.
        EOR #$FF
        SEC
        ADC #$00
        STA EVAL        ; Result into exponent value location.
POSTV:  CLC             ; Prepare to add exponents.
        LDA EVAL        ; Get "E" exponent.
        ADC DEXP        ; Add exponent from input and norm.
        STA DEXP        ; All exponent work finished.
TENPRW: LDA DEXP        ; Get decimal exponent.
FINISH1:
        BEQ FINISH      ; If it is zero, routine is done
        BPL MLTPLY      ; If it is plus, go multiply by ten.

ONCMOR: JSR DIVTEN      ; Jump to divide-by-ten subroutine.
        CLV             ; Force a jump around the routine.
        BVC ARND        ; The new subroutine is inserted here. Clear accumulator for use as a register. Do $28 = 40 bit divide. OVFLO will be used as "guard" byte.
DIVTEN: LDA #$00
        LDY #$28
BRA:    ASL OVFLO
        ROL LSB
        ROL NLSB        ; Roll one bit at a time into the accumulator which serves to hold the partial dividend.
        ROL NMSB
        ROL MSB
        ROL A           ; Check to see if A is larger than the divisor, $0A = 10.
        CMP #$0A
        BCC BRB         ; No. Decrease the bit counter.
        SEC             ; Yes. Subtract divisor from A.
        SBC #$0A
        INC OVFLO       ; Set a bit in the quotient.
BRB:    DEY             ; Decrease the bit counter.
        BNE BRA
BRC:    DEC BEXP        ; Division is finished, now normalize.
        ASL OVFLO       ; For each shift left, decrease the binary exponent.
        ROL LSB
        ROL NLSB        ; Rotate the mantissa left until a one is in the most-significant bit.
        ROL NMSB
        ROL MSB
        BPL BRC
        LDA OVFLO       ; If the most-significant bit in the guard byte is one, round up.
        BPL BRE
        SEC             ; Add one.
        LDX #$04        ; X is byte counter.
BRD:    LDA ACC,X       ; Get the LSB.
        ADC #$00        ; Add the carry.
        STA ACC,X       ; Result into mantissa.
        DEX
        BNE BRD         ; Back to complete addition.
        BCC BRE         ; No carry from MSB so finish.
        ROR MSB         ; A carry, put in bit seven, and increase the binary exponent.
        INC BEXP
BRE:    LDA #$00        ; Clear the OVFLO position, then get out.
        STA OVFLO
        RTS
ARND:   LDA #$00        ; Clear overflow byte.
        STA OVFLO
        INC DEXP        ; For each divide-by-10, increment the decimal exponent until it is zero. Then its all over.
        BNE ONCMOR
        BEQ FINISH
MLTPLY: LDA #$00        ; Clear overflow byte.
        STA OVFLO
STLPLS: JSR TENX        ; Jump to multiply-by-ten subroutine.
        JSR NORM        ; Then normalize the mantissa.
        DEC DEXP        ; For each multiply-by-10, decrement the decimal exponent until it's zero. All finished now.
        BNE STLPLS
FINISH: RTS

; Replica 1 I/O Routines

OUTCH:
          JMP PrintChar         ; Output character in A
INPUT:
          JSR GetKey            ; Get a key
          STA CHAR
          JMP PrintChar         ; and echo it
CLDISP:
          JMP ClearScreen       ; Clear the screen
