;
; OSI Serial/Cassette and console input/output.
;
; Build using:
; ca65 -g -l example2.lst example2.s
; ld65 -t none -vm -o example2.bin example2.o
; ./bintolod -s 0000 -l 0000 example2.bin >example2.lod
;
; Then upload and run using:
; ascii-xfr -s example2.lod >/dev/ttyUSB0 

; Useful ROM Routines:
; Get key from keyboard and return in A
; $FD00

; Send character to terminal screen.
; Character in A. Handles CR, LF, etc.
; Maintains cursor position as $D300 +($0200). Default (bottom left) is $65.
; $BF2D

; Send character to ACIA
; $FCB1

; Read character from ACIA
; $FE80

; ROM monitor uses these page zero addresses, so avoid:
; $FB,$FC,$FE,$FF



        .org 0

; Write chars to serial port/UART

clearscreen:
        ldx #$FF
        lda #' '
loop1:  sta $D000,x
        sta $D100,x
        sta $D200,x
        sta $D300,x
        dex
        bne loop1

        lda #$65
        sta $0200

loop:   jsr $FD00
        jsr $BF2D
        jsr $FCB1
        jmp loop



