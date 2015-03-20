        ADDRL   = $10
        ADDRH   = $11
        SAVEA   = $12
        SAVEY   = $13
        SAVEX   = $14
        T1      = $15

        CRLF    = $1E2F
        PRTBYT  = $1E3B
        GETCH   = $1E5A
        OUTSP   = $1E9E
        OUTCH   = $1EA0
        GETBYT  = $1F9D

        .ORG    $0200

START:  CLD                     ; Make sure not in decimal mode
        LDX     #$FF            ; Initialize stack
        TXS

        LDA     #$00            ; Set up vectors for SST/ST and BRK
        STA     $17FA
        STA     $17FE
        LDA     #$1C
        STA     $17FB
        STA     $17FF

        JSR     CRLF            ; Print prompt on serial console
        LDX     #<S1            ; Get pointer to string
        LDY     #>S1
        JSR     PrintString

        JSR     GETBYT          ; Get high byte of addess
        STA     ADDRH
        JSR     GETBYT          ; Get low byte of addess
        STA     ADDRL
        JSR     CRLF

; Dump memory in this format:
; 0200: 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F

NEXT:   LDA     ADDRH
        JSR     PRTBYT          ; Print high byte of address
        LDA     ADDRL
        JSR     PRTBYT          ; Print low byte of address
        LDA     #':'
        JSR     OUTCH           ; Print a space
        LDY     #$00
PRLINE: STY     SAVEY
        JSR     OUTSP           ; Print a space
        LDY     SAVEY
        LDA     (ADDRL),Y       ; get byte at address
        STY     SAVEY
        JSR     PRTBYT          ; print it in hex
        LDY     SAVEY
        INY
        CPY     #16             ; printed 16 addresses?
        BNE     PRLINE
        JSR     CRLF
        LDA     ADDRL           ; Add 16 to address
        CLC
        ADC     #16
        STA     ADDRL
        LDA     ADDRH           ; Add any carry to high byte
        ADC     #0
        STA     ADDRH
        JMP     NEXT            ; Print next line of data

DONE:   BRK                     ; Go back to monitor

S1:     .ASCIIZ "Address: "

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null (zero).
; Registers changed: None
;
PrintString:
        PHA                     ; Save A
        TYA
        PHA                     ; Save Y
        STX     T1              ; Save in page zero so we can use indirect addressing
        STY     T1+1
        LDY     #0              ; Set offset to zero
@loop:  LDA     (T1),Y          ; Read a character
        BEQ     done            ; Done if we get a null (zero)
        JSR     PrintChar       ; Print it
        CLC                     ; Increment address
        LDA     T1              ; Low byte
        ADC     #1
        STA     T1
        BCC     @nocarry
        INC     T1+1            ; High byte
@nocarry:
        JMP     @loop           ; Go back and print next character
done:   
        PLA
        TAY                     ; Restore Y
        PLA                     ; Restore A
        RTS

; Output a character
; Pass byte in A
; Registers changed: none
PrintChar:
        STA     SAVEA           ; Save A, X, Y as they may be changed
        STY     SAVEY
        STX     SAVEX
        JSR     OUTCH           ; Call monitor character out routine
        LDX     SAVEX           ; Restore Y, X, A
        LDY     SAVEY
        LDA     SAVEA
        RTS                     ; Return.
