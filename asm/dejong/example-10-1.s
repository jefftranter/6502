LOBYTE  =       $0000           ; Low-order byte for timer.
HIBYTE  =       $0001           ; Hi-order byte for timer.
DVSRLO  =       $0002           ; Low-order byte of divisor.
DVSRMI  =       $0003           ; 
DVSRHI  =       $0004           ; 
DVNDLO  =       $0005           ; Low-order byte of dividend.
DVNDMI  =       $0006           ; 
DVNDHI  =       $0007           ; 
REMLO   =       $0008           ; Low-order byte of remainder.
REMMI   =       $0009           ; 
REMHI   =       $000A           ; 
SPEED   =       $000B           ; BCD value of code speed.
BISPED  =       $000C           ; Binary value of code speed.
FIFO    =       $000D           ; 
CODE    =       $0800           ; 

        .ORG    $2000

; Subroutine TIMER
TIMER:  PHA                     ; Save A on the stack.
        TXA                     ; Save X
        PHA                     ; on stack.
        TYA                     ; Save Y
        PHA                     ; on the stack.
        LDX     LOBYTE          ; Lo-order byte into timing loop.
        LDY     HIBYTE          ; Hi-order byte into timing loop.

TMLOOP: DEX
        BNE     TMLOOP
        DEY
        BNE     TMLOOP          ; Both timing loops complete?
        PLA                     ; Get Y
        TAY                     ; from the stack.
        PLA                     ; Get X
        TAX                     ; from stack.
        PLA                     ; Get A from stack.
        RTS                     ; Return to calling program.

; ***************
; Subroutine SEND
SEND:   LDY     #$00            ; Clear Y for indirect indexed load.
        LDA     (FIFO),Y        ; Get character from the table.
        INC     FIFO            ; Increment FIFO pointer.
        TAX                     ; Character becomes index.
        LDA     CODE,X          ; Get Morse code character.
        BEQ     WDSPCE          ; Send a word space.
REST:   ASL     A               ; Shift code into carry flag.
        BEQ     CHSPCE          ; Character finished. Send space.
        BCS     DASH            ; Send a dash if carry is set.
        LDX     #$01            ; X counts # of timer calls.
DOT:    STA     $C058           ; Annunciator to logic zero
MORE:   JSR     TIMER           ; for one dot time.
        DEX
        BNE     MORE
        STA     $C059           ; Annunciator to logic one.
        JSR     TIMER           ; Add an element space.
        CLV                     ; Branch back to get the
        BVC     REST            ; rest of the character.
DASH:   LDX     #$03            ; Send a character space.
        BNE     DOT
CHSPCE: LDX     #$02            ; Send a character space.
SPACE:  JSR     TIMER
        DEX
        BNE     SPACE           ; More space.
        RTS
WDSPCE: LDX     #$04
        BNE     SPACE

; ************************
; Subroutine BCD-to-binary
CONVERT:
        LDA     #$80            ; This routine converts
        STA     BISPED          ; the BCD value of
BR1:    LSR     SPEED           ; code speed to
        ROR     BISPED          ; a binary number.
        BCS     BR3
        SEC
        LDA     SPEED
        AND     #$08
        BEQ     BR2
        LDA     SPEED
        SBC     #$03
        STA     SPEED
BR2:    BCS     BR1
BR3:    RTS

; *****************
; Subroutine DIVIDE

DIVIDE: LDA     #$00            ; This routine performs
        STA     REMLO           ; the 24-bit division
        STA     REMMI           ; for the code speed
        STA     REMHI           ; calculation.
        LDX     #$18            ; 24-bit division.
        ASL     DVNDLO
        ROL     DVNDMI
        ROL     DVNDHI
BR4:    ROL     REMLO
        ROL     REMMI
        ROL     REMHI
        LDA     REMLO
        CMP     DVSRLO
        LDA     REMMI
        SBC     DVSRMI
        LDA     REMHI
        SBC     DVSRHI
        BCC     BR5
        LDA     REMLO
        SBC     DVSRLO
        STA     REMLO
        LDA     REMMI
        SBC     DVSRMI
        STA     REMMI
        LDA     REMHI
        SBC     DVSRHI
        STA     REMHI
BR5:    ROL     DVNDLO
        ROL     DVNDMI
        ROL     DVNDHI
        DEX
        BNE     BR4
        RTS

; Subroutine RDBYTE
; *****************

TEMP    =       $000C           ; Temporary storage location.
CROUT   =       $FD8E           ; Carriage return.
RDKEY   =       $FD0C           ; Read keyboard.
COUT    =       $FDED           ; Output subroutine.

RDBYTE: JSR     ASHEX           ; Get nibble.
        ASL     A               ; Shift to high nibble.
        ASL     A
        ASL     A
        ASL     A
        STA     TEMP            ; Store nibble.
        JSR     ASHEX           ; Get the second nibble.
        ORA     TEMP            ; Combine with first nibble.
        STA     TEMP            ; Save entire byte.
        JSR     CROUT           ; Output a return.
        LDA     TEMP            ; Get byte back.
        RTS                     ; No. Return.

; ASCII-to-hex Routine
;*********************

ASHEX:  JSR     RDKEY           ; Get a character.
        JSR     COUT            ; Display it.
        AND     #$7F            ; Mask bit 7 off.
        CMP     #$40            ; Digit or letter?
        BCS     ARND
        AND     #$0F            ; Digit, mask hi-nibble.
        BPL     PAST            ; Branch past letter.
ARND:   SBC     #$37            ; Letter, subtract $37.
PAST:   RTS                     ; Return with digit in A.

; Subroutine CNTSPD
; *****************

CNTSPD: JSR     RDBYTE          ; Get a 2-digit BCD number from
        STA     SPEED           ; the keyboard and
        JSR     CONVERT         ; convert it to binary.
        LDA     #$12            ; Find number of clock cycles
        STA     DVNDHI          ; in one dot time.
        LDA     #$BB            ; $13BB50=1,227,600.
        STA     DVNDMI          ; #cycles = 1,227,600/SPEED.
        LDA     #$50
        STA     DVNDLO
        LDA     #$00
        STA     DVSRMI
        STA     DVSRHI
        LDA     BISPED          ; Divide 1,227,600 by
        STA     DVSRLO          ; code speed.
        JSR     DIVIDE
        LDA     #$04            ; $0504 = 1284.
        STA     DVSRLO          ; Hi-byte in timer.
        LDA     #$05            ; Is # cycles divided by
        STA     DVSRMI          ; 1284.
        LDA     #$00
        STA     DVSRHI
        JSR     DIVIDE          ; Find hi-byte for timer.
        LDA     DVNDLO
        STA     HIBYTE
        INC     HIBYTE
        LDA     REMLO           ; Remainder of this division
        STA     DVNDLO          ; will be divided by
        LDA     REMMI           ; five to find the lo-byte
        STA     DVNDMI          ; for the timer subroutine.
        LDA     REMHI
        STA     DVNDHI
        LDA     #$00
        STA     DVSRMI
        STA     DVSRHI
        LDA     #$05            ; Divide by five.
        STA     DVSRLO
        JSR     DIVIDE
        LDA     DVNDLO
        STA     LOBYTE          ; Result into lo-byte for
        RTS                     ; timer subroutine.

; ASCII-to-Morse Lookup Table

        .ORG    $0880

        .BYTE   $00, $00, $00, $00, $00, $00, $00, $CE
        .BYTE   $00, $00, $00, $00, $CE, $8C, $56, $94
        .BYTE   $FC, $7C, $3C, $1C, $0C, $04, $84, $C4
        .BYTE   $E4, $F4, $16, $32, $00, $8C, $00, $32
        .BYTE   $00, $60, $88, $A8, $90, $40, $28, $D0
        .BYTE   $08, $20, $16, $32, $CE, $8C, $56, $94
        .BYTE   $FC, $7C, $3C, $1C, $0C, $04, $84, $C4
        .BYTE   $E4, $F4, $16, $32, $00, $8C, $00, $32
        .BYTE   $00, $60, $88, $A8, $90, $40, $28, $D0       
        .BYTE   $08, $20, $78, $B0, $48, $E0, $A0, $F0
        .BYTE   $68, $D8, $F0, $10, $C0, $30, $18, $70
        .BYTE   $98, $B8, $C8, $00, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00
        .BYTE   $00, $00, $00, $00, $00, $00, $00, $00
