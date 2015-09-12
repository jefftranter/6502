; Example of making calls to ProDOS MLI.

; Here is an example of a small program that issues calls to the MLI.
; It tries to create a text file named NEWFILE on a volume named HDD3.
; If an error occurs, the Apple II beeps and prints the error code on
; the screen. Both the source and the object are given so you can
; enter it from the Monitor if you wish (remember to use a formatted
; disk named /HDD3).

        .org    $2000

BELL    =       $FF3A   ; Monitor BELL routine
CROUT   =       $FD8E   ; Monitor CROUT routine
PRBYTE  =       $FDDA   ; Monitor PRBYTE routine
MLI     =       $BF00   ; ProDOS system call
CRECMD  =       $C0     ; CREATE command number

Main:   jsr     Create  ; CREATE "/HDD3/NEWFILE"
        bne     Error   ; If error, display it
        rts             ; Otherwise done

Create: jsr     MLI     ; Perform call
        .byte   CRECMD  ; CREATE command number
        .word   CRELIST ; Pointer to parameter list
        rts

Error:  jsr     PRBYTE  ; Print error code
        jsr     BELL    ; Ring the bell
        jsr     CROUT   ; Print a carriage return
        rts

CRELIST:
        .byte   7       ; Seven parameters
        .word   FILENAME ; Pointer to filename
        .byte   $C3     ; Normal file access permitted
        .byte   $04     ; Make it a text file
        .byte   $00,$00 ; AUX_TYPE, not used
        .byte   $01     ; Standard file
        .byte   $00,$00 ; Creation date (unused)
        .byte   $00,$00 ; Creation time (unused)

FILENAME:
        .byte ENDNAME-NAME ; Length of name
NAME:   .byte "/HDD3/NEWFILE" ; followed by the name
ENDNAME:
