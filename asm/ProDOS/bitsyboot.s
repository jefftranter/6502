; Reverse engineered source code for ProDOS 8 bitsy.boot program.
; From ProDOS 2.4. See https://prodos8.com/bitsy-boot/
; Jeff Tranter <tranter@pobox.com>
;
; Some things of note:
; 1. The MLI QUIT parameter table is specified as seven bytes:
;    $04 followed by six reserved bytes. The original program only
;    supplies the initial $04; the following six bytes are executable
;    code. This works because the QUIT implementation does not use
;    the remaining reserved bytes, although it does not strictly
;    conform to the documented parameter table format.
; 2. It uses self-modifying code to change the destination of the
;    JSR at L209E. The high byte of the address is replaced with
;    $C0 | slot, allowing the same instruction to boot any selected
;    peripheral slot without requiring separate code for each slot.
; 3. The Apple IIGS code uses some 65816 instructions after verifying
;    that it is running on an Apple IIGS and ProDOS8.
; 4. The code is small enough to fit within one disk block (512 bytes).

; Macro to store string bytes in high-ASCII
.macro hbyte string
    .define _string string
    .repeat .strlen(_string), i
        .byte .strat(_string, i) | $80
    .endrepeat
.undef _string
.endmacro

ESC     =      $9B              ; Escape character
CR      =      $8D              ; Carriage Return

QUIT    =      $65              ; MLI QUIT call

BASL    =      $28              ; Cursor text line (low byte)
BASH    =      $29              ; Cursor text line (high byte)
TEXT    =      $0400            ; Text screen address
MLI     =      $BF00            ; ProDOS system call
DEVNUM  =      $BF30            ; Slot/drive of most recently accessed device
DEVCNT  =      $BF31            ; Number of active devices minus one
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
        jsr     L20C8           ; Get slot number of most recently accessed device
        and     #$07            ; Clear lower nibble
        ora     #$B0            ; Set some bits
        sta     L2142           ; Save it on screen
        ldy     DEVCNT          ; Get last DEVLST index

; DEVLST entries contain drive/slot information in the upper nibble
; and device characteristics in the lower nibble.

L201C:  lda     DEVLST,y        ; Get device entry: DSSSIIII
        beq     L2036           ; Skip if inactive
        php                     ; Save original value
        lsr     a               ; Shift slot number into lower nibble
        lsr     a
        lsr     a
        and     #$0E            ; Clear other bits
        tax                     ; X now contains slot # *2
        lsr     a               ; A now contains slot #
        ora     #'0'+$80        ; Convert to high-ASCII
        plp                     ; Restore original DEVLST value
        bmi     L2033           ; Drive 2 entries have bit 7 set
        sta     L2103,x         ; Save it on screen
        bne     L2036           ; Do next entry
L2033:  sta     L2112,x         ; Save it on screen
L2036:  dey                     ; Decrement device number
        bpl     L201C           ; Continue if more entries
        jsr     HOME            ; Clear screen
        ldx     #$9D
L203E:  lda     L20CF,x         ; Get text to display
        bmi     L204A           ; Branch if not a high-ASCII character
        jsr     BASCALC         ; Calculate screen address for row
        ldy     L20D0,x         ; Get number of characters to display

; $2C is BIT abs. Executed here, it consumes the next two bytes (the
; STA opcode and its operand bytes), effectively skipping the STA
; instruction and falling through to the common character store.

        .byte   $2C             ; BIT instruction skip trick
L204A:  sta     (BASL),Y        ; Store character on screen
        dey                     ; Decrement screen position
        dex                     ; Decrement character index
        bne     L203E           ; Branch until done
L2050:  sta     TEXT,y          ; Write text to top line of screen
        sta     (BASL),y        ; Write text to screen
        dey                     ; Decrement screen position
        bpl     L2050           ; Branch until done
        ldx     #21             ; Want to display vertical line at column 21
L205A:  txa
        jsr     BASCALC         ; Calculate screen address
        ldy     #20             ; Want to display vertical line of '!'
        lda     #'!'+$80
        sta     (BASL),y        ; Store character on screen
        dex                     ; Decrement counter
        bne     L205A           ; Repeat until done
        lda     #$10            ; Move cursor to line 16
        sta     BASH
        sta     KBDSTRB         ; Clear keyboard strobe
        bne     L2073           ; Always taken
ERROR:  jsr     BELL            ; Beep to indicate error
L2073:  jsr     RDKEY           ; Get key from keyboard
        bit     PB0             ; Open Apple pressed?
        bmi     L20A5           ; Branch if so
        cmp     #'8'+$80        ; Is key >= 8?
        bcs     L20A5           ; Yes, handle as Open-Apple command or error
        cmp     #'1'+$80        ; Is key >= 1?
        bcs     L2092           ; Yes, boot selected slot
        cmp     #ESC            ; Compare to Escape key
        beq     L209B           ; Branch if equal
        cmp     #CR             ; Compare to Carriage Return
        beq     L208F           ; Branch if equal
        cmp     #$A0            ; Compare to space key
        bne     L2073           ; Branch if not equal
L208F:  jsr     L20C8           ; Get last drive number, use it to boot
L2092:  and     #$07            ; Convert key 1 - 7 to slot number
        beq     L2073           ; Not valid if zero
        ora     #$C0            ; Form slot I/O address $Cn00
        sta     L209E+2         ; Change address to call below to $C0n0
L209B:  jsr     HOME            ; Clear screen
L209E:  jsr     MLI             ; Make ProDOS MLI QUIT call (can be changed by code above)
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

; Detect a 65816 by executing REP and testing the resulting N flag.
; REP #$80 clears N on a 65816; the subsequent BMI rejects a CPU
; on which this sequence does not behave as expected.

        rep     #$80            ; Clear N bit in status reg
        bmi     ERROR           ; Branch if N bit set. If so, must not be running on a 65816
        lda     $E100BD         ; Get GS OS_BOOT status
        dec     a
        bne     ERROR           ; Must indicate ProDOS 8
        clc
        xce                     ; Put CPU in 16-bit native mode
        lda     $C08B           ; Select/read language card RAM Bank 1
        jml     $E0D000         ; Jump to ROM

        .setcpu "6502"
L20C8:  lda     DEVNUM          ; Get most recently accessed device
        lsr     a               ; Move slot number into low three bits
        lsr     a
        lsr     a
        lsr     a
L20CF:  rts

; Table of text to display.
; If high bit is set, contains Apple II screen characters to display.
; If high bit is clear, the next two bytes specify the screen row
; and column for the text.

L20D0:  hbyte   "-"
        .byte   22
        .byte   41
        hbyte   "BITSY BOOT"
        .byte   4
        .byte   35
        hbyte   "1.0"
        .byte   21
        .byte   40
        hbyte   "BY"
        .byte   9
        .byte   31
        hbyte   "JOHN"
        .byte   15
        .byte   32
        hbyte   "BROOKS"
        .byte   18
        .byte   33
        hbyte   "ACTIVE  SLOTS"
L2103:  .byte   4
        .byte   16
        hbyte   ". . . . . . ." ; This gets overwritten at run time by active slot numbers
L2112:  .byte   8
        .byte   16
        hbyte   ". . . . . . ." ; This gets overwritten at run time by active slot numbers
        .byte   10
        .byte   16
        hbyte   "1-7:BOOT A SLOT"
        .byte   15
        .byte   17
        hbyte   "RET:BOOT SLOT "
L2142:  hbyte   "N"            ; This gets overwritten at run time by boot slot
        .byte   18
        .byte   17
        hbyte   "ESC:QUIT TO PRODOS"
        .byte   23
        .byte   18
        hbyte   "OA-Q:QUIT TO GS/OS"
        .byte   23
        .byte   40
