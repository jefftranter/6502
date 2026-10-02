; Example of making calls to ProDOS MLI.

; Here is an example of a small program that issues calls to the MLI.
; It tries to create a text file named NEWFILE on a volume named HDD3.
; If an error occurs, the Apple II beeps and prints the error code on
; the screen. Both the source and the object are given so you can
; enter it from the Monitor if you wish (remember to use a formatted
; disk named /HDD3).

; Returns to ProDOS via a QUIT MLI call.

        .org    $2000

PWREDUP =       $03F4   ; Autostart ROM Power-up Mask
BELL    =       $FF3A   ; Monitor BELL routine
CROUT   =       $FD8E   ; Monitor CROUT routine
PRBYTE  =       $FDDA   ; Monitor PRBYTE routine
MLI     =       $BF00   ; ProDOS system call
CRECMD  =       $C0     ; CREATE command number
QUITCMD  =      $65     ; QUIT command number

Main:   jsr     Create  ; CREATE "/HDD3/NEWFILE"
        bne     Error   ; If error, display it
        jmp     Return  ; Otherwise done

Create: jsr     MLI     ; Perform call
        .byte   CRECMD  ; CREATE command number
        .word   CRELIST ; Pointer to parameter list
        rts

Error:  jsr     PRBYTE  ; Print error code
        jsr     BELL    ; Ring the bell
        jsr     CROUT   ; Print a carriage return
                        ; Fall thru to Return code below

Return:
;       rts             ; Uncomment this line to simply return (e.g. to Basic)
        inc     PWREDUP ; Increment the power-up byte to break the checksum
        jsr     MLI     ; Call ProDOS MLI
        .byte   QUITCMD ; QUIT command code
        .word   QUITLIST ; Pointer to parameters

CRELIST:
        .byte   7       ; Seven parameters
        .word   FILENAME ; Pointer to filename
        .byte   $C3     ; Normal file access permitted
        .byte   $04     ; Make it a text file
        .byte   $00,$00 ; AUX_TYPE, not used
        .byte   $01     ; Standard file
        .byte   $00,$00 ; Creation date (unused)
        .byte   $00,$00 ; Creation time (unused)

QUITLIST:
        .byte 4         ; Parameter count
        .byte 0         ; Reserved
        .word 0         ; Reserved
        .byte 0         ; Reserved
        .word 0         ; Reserved

FILENAME:
        .byte ENDNAME-NAME ; Length of name
NAME:   .byte "/HDD3/NEWFILE" ; followed by the name
ENDNAME:
