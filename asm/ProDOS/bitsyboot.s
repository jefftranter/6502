; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4. See https://prodos8.com/bitsy-boot/
; Jeff Tranter <tranter@pobox.com>

ESC     =      $9B              ; Escape character
CR      =      $8D              ; Carriage Return

QUIT    =      $65              ; MLI QUIT call

BASL    =      $28              ; Cursor text line (low byte)
BASH    =      $29              ; Cursor text line (high byte)
TEXT    =      $0400            ; Text screen address
MLI     =      $BF00            ; ProDOS system call
DEVNUM  =      $BF30            ; Unit number of last disk drive devices
DEVCNT  =      $BF31            ; Number of active devices (less one)
DEVLST  =      $BF32            ; Device list table
KBD     =      $C000            ; Keyboard data
KBDSTRB =      $C010            ; Keyboard strobe
CLR80VID =     $C00C            ; Clears 80-column mode
PB0     =      $C061            ; Open Apple key
INIT    =      $FB2F            ; Reset system defaults
BASCALC =      $FBC1            ; Calculate address of screen row
BELL    =      $FBDD            ; Beep speaker
HOME    =      $FC58            ; Move cursor to home
RDKEY   =      $FD0C            ; Get keyboard key
SETKBD  =      $FE89            ; Set keyboard to standard (slot 0)
SETVID  =      $FE93            ; Set video output to standard (slot 0)

        .org    $2000           ; Standard start address for ProDOS system programs

        sta     CLR80VID        ; Turn off 80-column mode
        sta     KBD             ; Turn off 80STORE feature
        jsr     SETVID          ; Reset video to slot 0
        jsr     SETKBD          ; Reset keyboard to slot 0
        jsr     INIT            ; Reset system defaults
        jsr     L20C8           ; Get last device number in upper nybble
        and     #$07            ; Clear lower nybble
        ora     #$B0            ; Set some bits
        sta     L2142           ; Save it
        ldy     DEVCNT          ; Get number of devices/disks
L201C:  lda     DEVLST,y        ; Get device table entry for the drive
        beq     L2036           ; Skip if inactive
        php                     ; Save original value
        lsr     a               ; Shift slot number into lower nybble
        lsr     a
        lsr     a
        and     #$0E            ; Clear other bits
        tax                     ; X now contains slot # *2
        lsr     a               ; A now contains slot #
        ora     #'0'+$80        ; Convert to high-ASCII
        plp                     ; Restore original DEVLST value
        bmi     L2033           ; Branch if entry is for drive 2
        sta     L2103,x         ; Save it
        bne     L2036           ; Do next entry
L2033:  sta     L2112,x         ; Save it
L2036:  dey                     ; Decrement device number
        bpl     L201C           ; Continue if more entries
        jsr     HOME            ; Clear screen
        ldx     #$9D
L203E:  lda     L20CF,x         ; Get text to display
        bmi     L204A           ; Branch if not a high-ASCII character
        jsr     BASCALC         ; Calculate screen address for row
        ldy     L20D0,x         ; Get number of characters to display
        .byte   $2C             ; BIT instruction skip trick
L204A:  sta     (BASL),Y        ; Store character on screen
        dey                     ; Decrement screen position
        dex                     ; Decrement character index
        bne     L203E           ; Branch until done
L2050:  sta     TEXT,y          ; Write text to screen?
        sta     (BASL),y        ; Write text to screen
        dey                     ; Decrement screen position
        bpl     L2050           ; Branch until done
        ldx     #$15            ; 21 lines to be displayed on the screen?
L205A:  txa
        jsr     BASCALC         ; Calculate screen address for row
        ldy     #$14            ; 20 lines to be displayed on the screen?
        lda     #$A1
        sta     (BASL),y        ; Store character on screen
        dex                     ; Decrement line counter
        bne     L205A           ; Repeat until done
        lda     #$10            ; Move cursor to line 16
        sta     BASH
        sta     KBDSTRB         ; Clear keyboard strobe
        bne     L2073           ; Always taken
ERROR:  jsr     BELL            ; Beep to indicate error
L2073:  jsr     RDKEY           ; Get key from keyboard
        bit     PB0             ; Open Apple pressed?
        bmi     L20A5           ; Branch if so
        cmp     #'8'+$80        ; Compare to '8' key
        bcs     L20A5           ; Branch if less
        cmp     #'1'+$80        ; Compare to '1' key
        bcs     L2092           ; Branch if less
        cmp     #ESC            ; Compare to Escape key
        beq     L209B           ; Branch if equal
        cmp     #CR             ; Compare to Carriage Return
        beq     L208F           ; Branch if equal
        cmp     #$A0            ; Compare to space key
        bne     L2073           ; Branch if not equal
L208F:  jsr     L20C8           ; Get last drive number, use it to boot
L2092:  and     #$07            ; Key 1-8 pressed, convert to drive number
        beq     L2073           ; Not valid if zero
        ora     #$C0            ; Change to $Cn, where n is slot number
        sta     L209E+2         ; Change address to call below to $C0n0
L209B:  jsr     HOME            ; Clear screen
L209E:  jsr     MLI             ; Make ProDOS MLI QUIT call
        .byte   QUIT            ; Command code for QUIT
        .word   L20A4           ; Address of parameter table
L20A4:  .byte   $04             ; Parameter table
                                ; Code above does not return

L20A5:  cmp     #ESC            ; Escape key?
        beq     L20AF           ; If so, branch
        and     #$DF
        cmp     #'Q'+$80        ; Q key pressed?
        bne     ERROR           ; If not, then error
L20AF:  bit     PB0             ; Open Apple key pressed?
        bpl     ERROR           ; Branch if not

; Below is 65816 code running on an Apple IIGS.

        .p816
        rep     #$80            ; Clear N bit in status reg
        bmi     ERROR           ; Branch if N bit set, must not be running on a 65816
        lda     $E100BD         ; OS_BOOT system status byte
        dec     a
        bne     ERROR           ; Error - not running ProDOS8
        clc
        xce                     ; Put CPU in 16-bit native mode
        lda     $C08B           ; Read RAM Bank 1
        jml     $E0D000         ; Jump to ROM

        .setcpu "6502"
L20C8:  lda     DEVNUM          ; Get last device number
        lsr     a               ; Shift into upper nybble
        lsr     a
        lsr     a
        lsr     a
L20CF:  rts

; Table of text to display.
; If high bit is set, contains ASCII characters to display.
; If high bit not set, contains row and column on screen for text
; position.

L20D0:  .byte   '-'+$80
        .byte   $16
        .byte   $29
        .byte   'B'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   'S'+$80
        .byte   'Y'+$80
        .byte   ' '+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   $04
        .byte   $23
        .byte   '1'+$80
        .byte   '.'+$80
        .byte   '0'+$80
        .byte   $15
        .byte   $28
        .byte   'B'+$80
        .byte   'Y'+$80
        .byte   $09
        .byte   $1F
        .byte   'J'+$80
        .byte   'O'+$80
        .byte   'H'+$80
        .byte   'N'+$80
        .byte   $0F
        .byte   $20
        .byte   'B'+$80
        .byte   'R'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'K'+$80
        .byte   'S'+$80
        .byte   $12
        .byte   $21
        .byte   'A'+$80
        .byte   'C'+$80
        .byte   'T'+$80
        .byte   'I'+$80
        .byte   'V'+$80
        .byte   'E'+$80
        .byte   ' '+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   'S'+$80
L2103:  .byte   $04
        .byte   $10
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
L2112:  .byte   $08
        .byte   $10
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   ' '+$80
        .byte   '.'+$80
        .byte   $0A
        .byte   $10
        .byte   '1'+$80
        .byte   '-'+$80
        .byte   '7'+$80
        .byte   ':'+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'A'+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   $0F
        .byte   $11
        .byte   'R'+$80
        .byte   'E'+$80
        .byte   'T'+$80
        .byte   ':'+$80
        .byte   'B'+$80
        .byte   'O'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'S'+$80
        .byte   'L'+$80
        .byte   'O'+$80
        .byte   'T'+$80
        .byte   ' '+$80
L2142:  .byte   'N'+$80
        .byte   $12
        .byte   $11
        .byte   'E'+$80
        .byte   'S'+$80
        .byte   'C'+$80
        .byte   ':'+$80
        .byte   'Q'+$80
        .byte   'U'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'T'+$80
        .byte   'O'+$80
        .byte   ' '+$80
        .byte   'P'+$80
        .byte   'R'+$80
        .byte   'O'+$80
        .byte   'D'+$80
        .byte   'O'+$80
        .byte   'S'+$80
        .byte   $17
        .byte   $12
        .byte   'O'+$80
        .byte   'A'+$80
        .byte   '-'+$80
        .byte   'Q'+$80
        .byte   ':'+$80
        .byte   'Q'+$80
        .byte   'U'+$80
        .byte   'I'+$80
        .byte   'T'+$80
        .byte   ' '+$80
        .byte   'T'+$80
        .byte   'O'+$80
        .byte   ' '+$80
        .byte   'G'+$80
        .byte   'S'+$80
        .byte   '/'+$80
        .byte   'O'+$80
        .byte   'S'+$80
        .byte   $17
        .byte   $28
