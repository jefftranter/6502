;
; Serial loader program, found on OSI cassettes for Extended Monitor and Editor/Assembler.
; This code is followed by the actual program to load in MOS Technology format.
; Typical input line:
;
; ;180258A8A100D9670230EED96B0230EC10E7413041005B3A4721000923<CR><NUL><NUL><NUL><NUL><NUL><NUL><NUL><NUL><NUL><NUL>
;
; Where the fields consist of:
; ; <- start of record character
;  18 <- hex number of data bytes in the the record (decimal 24)
;    0258 <- address of the first data byte in the record
;        A8A1...2100 <- 24 data bytes
;                   0923 <- modula 65536 checksum of data bytes
;                       <CR><NUL>... <- Carriage return and nulls to provide delay
;
; A last line should be dollar sign followed by start address, e.g. "$0800"
;
; The start address can be adjusted depending on the program to be
; loaded. The Extended Monitor used $0700, the Editor/Assemmbler used
; $1391.


CR       = $0D                  ; Carriage Return
LF       = $0A                  ; Line Feed
LDFLAG   = $0203                ; BASIC load flag 00=no load, FF=load from ACIA
INVEC    = $FFEB                ; Input routine
OUTVEC   = $FFEE                ; Output Routine

        .org    $0700           ; Address varies depending on program to be loaded

        .word   $0000           ; Appears to be unused?
ADDR    .word   $0000           ; Holds start address of loaded program. Also checksum.
D0704   .byte   $00             ; Holds data byte

START   jsr     SUB1            ; Get input byte
        cmp     #';'            ; Line should start with ';'
        beq     LINE            ; If so, branch
        cmp     #'$'            ; Last line should be dollar sign followed by start address, e.g. "$0800"
        bne     START           ; If not, keep reading.
        jsr     S0781           ; Get hex byte from input
        sta     ADDR+1          ; Store high byte
        jsr     S0781           ; Get hex byte form input
        sta     ADDR            ; Store low byte
        jmp     GO              ; Run program
LINE    lda     #$00            ; Initialize checksum to zero
        sta     ADDR
        sta     ADDR+1
        jsr     S076E
        tax
        jsr     S076E           ; Get address high byte
        sta     STORE+2         ; Change self-modifying code below
        jsr     S076E           ; Get address low byte
        sta     STORE+1         ; Change self-modifying code below
L0737   jsr     S076E
STORE   sta     $0FFF           ; Address is changed at run-time
        inc     STORE+1
        bne     L0745
        inc     STORE+2
L0745   dex
        bne     L0737
        jsr     S0781
        cmp     ADDR+1
        bne     L0758
        jsr     S0781
        cmp     ADDR
        beq     START
L0758   ldy     #$00            ; Display error message
PRNT    lda     ERRMSG,y        ; Get byte of message
        beq     L0765           ; Branch if terminating null found
        jsr     OUTVEC          ; Otherwise print
        iny                     ; Increment index
        bne     PRNT            ; And continue
L0765   jsr     S07A3           ; Get input from keyboard
        cmp     #'G'            ; Was it 'G', indicating to restart?
        bne     L0765           ; If not, keep checking for key
        beq     START           ; Otherwise jump to start
S076E   jsr     S0781           ; Get databyte
        clc
        adc     ADDR            ; Update Running checksum
        sta     ADDR
        bcc     L077D
        inc     ADDR+1          ; Update checksum high byte
L077D   lda     D0704
        rts
S0781   jsr     S0784
S0784   jsr     SUB1            ; Get character
        cmp     #'A'            ; Check for hex digit (A-F)
        bcc     L078D           ; Branch if less
        sbc     #$07            ; Adjust for hex digit
L078D   and     #$0F            ; Mask out ASCII bits
        asl     a               ; Shift into upper nybble
        asl     a
        asl     a
        asl     a
        ldy     #$04
L0795   rol     a
        rol     D0704
        dey
        bne     L0795
        lda     D0704
        rts
SUB1    lda     #$80         ; Enter here to set load flag
        .byte   $2C          ; BIT instruction skip trick
S07A3   lda     #$00         ; Enter here to clear load flag
        sta     LDFLAG       ; Set cassette/seria load flag to $80 or $00 depending on above
        jsr     INVEC        ; Get a character
        jmp     OUTVEC       ; Echo it. Returns via RTS at end of OUTVEC.
GO      lda     #$00         ; Turn off cassette/serial load flag
        sta     LDFLAG
        jmp     (ADDR)       ; Jump to loaded program start

ERRMSG  .byte   CR,LF,LF
        .byte   "OBJ CHECKSUM ERR"
        .byte   CR,LF
        .byte   "REWIND PAST ERR - TYPE G TO RESTART"
        .byte   $00
