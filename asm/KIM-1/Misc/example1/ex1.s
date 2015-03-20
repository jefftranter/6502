        T1      = $F0
        SAVEA   = $F3
        SAVEY   = $F4
        SAVEX   = $F5

        CRLF    = $1E2F
        PRTBYT  = $1E3B
        GETCH   = $1E5A
        OUTSP   = $1E9E
        OUTCH   = $1EA0

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

        JSR     CRLF            ; Print "HELLO" on serial console
        LDX     #<S1            ; Get pointer to string
        LDY     #>S1
        JSR     PrintString
        JSR     CRLF

ECHO:   JSR     GETCH           ; Get a key
        CMP     #'X'            ; If X...
        BEQ     DONE            ; exit
;       JSR     OUTCH           ; Echo key back
        JSR     PRTBYT          ; Print hex code for character
        JMP     ECHO            ; ...and continue

DONE:   BRK                     ; Go back to monitor

S1:     .ASCIIZ "Hello, world!"

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
