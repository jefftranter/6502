; A BCD to Floating-Point Binary Routine
; Marvin L. De Jong
; from Compute! Issue 9 / February 1981 / Page 46

; The original listing had many errors (e.g. "#" missing).

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

; Listing 1: ASCII to Floating-Point Binary Conversion Program
        .org $0E00

START:  CLD             ; Decimal mode not required
        LDX #$20         ; Clear all the memory locations used for storage by this routine by loading them with zeros.
        LDA #$00
CLEAR:  STA MEM,X
        DEX
        BPL CLEAR
        JSR CLDISP      ; Clears AIM 65 display.
        JSR INPUT       ; Get ASCII representation of BCD digit. Is it a + sign? Yes, get another character. Is it a minus sign?
        CMP #$2B
        BEQ PLUS
        CMP #$2D
        BNE NTMNS
        DEC MFLAG       ; Yes, set minus flag to $FF.
PLUS:   JSR INPUT       ; Get the next character.
NTMNS:  CMP #$2E        ; Is character a decimal point?
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
        CLC             ; Add the new digit to the least- significant byte of the accumulator.
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
        STY TEMP        ; Save Y. It contained the number of "left shifts" in NORM.
        LDA #$20
        SEC             ; The binary exponent is 32 - number of left shifts that NORM took to make the most-significant bit one.
        SBC TEMP
        STA BEXP
        LDA MSB         ; If the MSB of the accumulator is zero, then the number is zero, and its all over. Otherwise, check if the last character was an "E".
        BEQ FINISH1     ; Original listing branched to FINISH but that is too far to reach.
        LDA CHAR
        CMP #$45
        BNE TENPRW      ; If not, move to TENPRW.
        JSR INPUT       ; If so, get another character.
        CMP #$2B        ; Is it a plus?
        BEQ PAST        ; Yes, then get another character.
        CMP #$2D        ; Perhaps it was a minus?
        BNE NUMB        ; No, then maybe it was a number.
        DEC ESIGN       ; Set exponent sign flag.
PAST:   JSR INPUT       ; Get another character.
NUMB:   CMP #$30        ; Is it a digit?
        BCC TENPRW      ; No, more to TENPRW.
        CMP #$3A
        BCS TENPRW
        SEC             ; It was a digit, so strip ASCII prefix.
        SBC #$30        ; ASCII prefix is $30.
        STA TEMP        ; Keep the first digit here.
        JSR INPUT       ; Get another character.
        CMP #$30        ; Is it a digit?
        BCC HERE        ; No. Then finish handling the exponent.
        CMP #$3A
        BCS HERE
        SEC             ; Yes. Decimal exponent is new digit plus 10 times the old digit.
        SBC #$30
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
ONCMOR: LDX #$03        ; It's minus. Divide by ten.
BACK:   ASL LSB         ; First shift the accumulator
        ROL NLSB        ; three bits left.
        ROL NMSB
        ROL MSB
        ROL OVFLO
        DEC BEXP        ; Decrease the binary exponent for each left shift.
        DEX
        BNE BACK
        LDY #$20        ; Number of trial divisions of $0A into the accumulator giving a $20 = 32 bit quotient.
AGAIN:  ASL LSB
        ROL NLSB
        ROL NMSB
        ROL MSB
        ROL OVFLO
        DEY
        BEQ OUT         ; Get out when number of trial divisions reaches $20 = 32.
        LDA OVFLO
        SEC             ; Subtract 10 = $0A from partial divident in OVFLO.
        SBC #$0A
        BMI AGAIN       ; If result is minus, zero into quotient
        STA OVFLO       ; Otherwise store result in OVFLO, and set bit to one in quotient.
        INC LSB
        CLC
        BCC AGAIN       ; Try it again.
OUT:    LDA OVFLO       ; Check once more to see if quotient should be rounded upwards.
        CMP #$0A
        BCC AHEAD       ; No.
        LDX #$04        ; Yes. Add one to quotient.
REPET:  LDA ACC,X       ; Get each byte of the accumulator and add the carry from the previous addition.
        ADC #$00
        STA ACC,X
        DEX
        BNE REPET
        BCC AHEAD       ; What if carry from accumulator occurred? Get mostsignificant byte and put a 1 in bit seven.
        LDA MSB
        ORA #$80
        STA MSB         ; Result into high byte, and increment the binary exponent.
        INC BEXP
AHEAD:  LDA MSB         ; Because of three-bit shift at start of division, a one-bit shift (at most) may be required to normalize the mantissa now.
        BMI ARND
        ASL LSB
        ROL NLSB
        ROL NMSB
        ROL MSB
        DEC BEXP        ; If so, also decrement binary exponent.
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

; Listing 2. Multiply by Ten Subroutine.

        .org $0D00
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

        .org $0D30
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
BR7:    LDY #$00        ; Y will count number of left shifts.
BR10:   LDA MSB         ; Does most-significant byte have a one in bit seven? Yes, get out.
        BMI BR11
        CLC             ; No. Then shift the accumulator left one bit.
        LDX #$04
BR9:    ROL ACC,X
        DEX
        BNE BR9
        INY             ; Keep track of left shifts.
        CPY #$20        ; Not more than $20 = 32 bits.
        BCC BR10
BR11:   RTS             ; That's it.

; Listing 4. AIM 65 Input/Output Subroutines.

        .org $0F30
INPUT:  JSR $E93C
        JSR $F000
        STA $06
        JSR $0F72
        JSR $0F60
        LDA $06
        RTS

        .org $0F60
        LDX #$13
        TXA
        PHA
        LDA $A438,X
        ORA #$80
        JSR $EF7B
        PLA
        TAX
        DEX
        BPL $0F62
        RTS
        STA $A44C
        LDX #$01
        LDA $A438,X
        DEX
        STA $A438,X
        INX
        INX
        CPX #$15
        BCC $0F77
        RTS
        LDX #$12
        LDA $A438,X
        INX
        STA $A438,X
        DEX
        DEX
        BPL $0F87
        LDA #$20
        STA $A438
        JSR $0F60
        RTS
CLDISP: LDX #$13
        LDA #$20
        STA $A438,X
        DEX
        BPL $0F9F
        RTS
