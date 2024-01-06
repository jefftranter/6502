; Port of Acorn System/Atom MOS System Calls to my 6502
; Single Board Computer.
;
; Jeff Tranter <tranter@pobox.com>
;
; Helpful references:
; http://mdfs.net/Docs/Comp/Acorn/Atom/MOSEntries
; https://en.wikipedia.org/wiki/Acorn_MOS
; https://central.kaserver5.org/Kasoft/Typeset/BBC/Ch43.html
; https://danceswithferrets.org/geekblog/?p=872
; http://danceswithferrets.org/geekblog/?p=961

; Memory map:
; RAM from $0000 to $7FFF
; BBC Basic and MOS in ROM from $C000 to $FFFF

        LF      = $0A           ; Line feed
        CR      = $0D           ; Carriage return
        ESC     = $1B           ; Escape
        DEL     = $7F           ; Delete
        BS      = $08           ; Backspace

; SBC defines
        ACIA    = $A000         ; Serial port registers
        ACIAControl = ACIA+0
        ACIAStatus  = ACIA+0
        ACIAData  = ACIA+1

; IRQ and BRK handler
; Based on BBC code. See "Faults, events and BRK handling" section in
; the BBC Microcomputer User Guide.

_IRQ:
        sta     $FC             ; temporary for A
        pla
        pha                     ; get processor status
        and     #$10
        bne     LBRK
        jmp     ($0204)         ; IRQ1V
LBRK:   txa                     ; BRK handling
        pha                     ; save X
        tsx
        lda     $103,X          ; get address low
        cld
        sec
        sbc     #1
        sta     FAULT
        lda     $104,X          ; get address high
        sbc     #0
        sta     FAULT+1
        pla                     ; Get back original value of X
        tax
        lda     $FC             ; Get back original value of A
        cli                     ; Allow interrupts
        jmp     (BRKV)          ; And jump via BRKV

; RESET routine
_RESET:
        cld                     ; Make sure not in decimal mode

        ldx     #$FF            ; Initialize stack to known value
        txs

; Initialize ACIA
        lda     #$03            ; Reset 6850
        sta     ACIAControl
        lda     #$15            ; Set ACIA to 8N1 and divide by 16 clock
        sta     ACIAControl

; Display startup message
        ldy #0
ShowStartMsg:
        lda     StartMsg,Y
        beq     cont
        jsr     OSWRCH
        iny
        bne     ShowStartMsg
cont:
        lda     #OSWRCH & 255   ; Set up RAM vector to OSWRCH
        sta     WRCHV
        lda     #OSWRCH / 256
        sta     WRCHV+1

        lda     #$01            ; Must be $01 or Basic will return
        jmp     L8000           ; Basic entry point

StartMsg:
        .byte   "BBC BASIC v2 for 6502 SBC 05-Jan-2024",CR,LF,0
ClearMsg:
        .byte   ESC,"[2J",ESC,"[H",0

; NMI routine
_NMI:
        rti                     ; Simply return

; OSBYTE
;
; OSBYTE is a mechanism for getting or setting information between OS
; and running programs. It can perform lots of different functions -
; you specify the one you want by putting the right value into the
; accumulator, optionally set extra values in the X and Y registers,
; and then call OSBYTE:
;
; LDA #&83
; JSR &FFF4 ; entry point for OSBYTE

; Thankfully I don’t need to implement all the OSBYTE functions at
; this stage – just &82, &83, &84 and &85. Any other OSBYTE call can
; be ignored for now.
;
; What do those functions do?
;
; OSBYTE &82 – Read High Order Address
; OSBYTE &83 – Read OSHWM, bottom of user memory
; OSBYTE &84 – Read top of user memory
; OSBYTE &85 – Read start of display memory
;
; BASIC calls these when it starts in order to find out how much RAM
; it has to work with. The start of RAM moves according to what
; expansion ROMs claim extra space on bootup, and the end of RAM
; depends on how much RAM needs to be allocated for display memory.

_OSBYTE:
        cmp     #$82
        beq     osbyte82
        cmp     #$83
        beq     osbyte83
        cmp     #$84
        beq     osbyte84
        cmp     #$85
        beq     osbyte82
        rts

; OSBYTE &82 (130) - Read High Order Address
; Returns X=lo byte of 32 bit address of this machine
; Y=hi byte of 32 bit address of this machine
; ie. this machine's 32 bit address is &YYXX0000 upwards
osbyte82:
        ldx     #$0000 & 255    ; Return value $0000
        ldy     #$0000 / 256
        rts

; OSBYTE &83 (131) - Read OSHWM, bottom of user memory
; On exit X and Y hold the lowest address of user memory, used to
; initialise BASIC's 'PAGE'.
osbyte83:
        ldx     #$0900 & 255    ; Return LOMEM of $0900
        ldy     #$0900 / 256
        rts

; OSBYTE &84 (132) - Read top of user memory
; On exit X and Y point to the first byte after the top of user memory,
; used to initialise BASIC's 'HIMEM'.
osbyte84:
        ldx     #$8000 & 255    ; Return HIMEM of $8000
        ldy     #$8000 / 256
        rts

; OSBYTE &85 (133) - Read base of display RAM for a given mode
; X=mode number
; On exit X and Y point to the first byte of screen RAM if MODE X were chosen
osbyte85:
        ldx     #$F000 & 255    ; Return fake value $F000
        ldy     #$F000 / 256
        rts

; OSWORD
;
; Implement OSWORD 0 ("input line")
;
; OSWORD is like OSBYTE, but less restricted by having to cram all
; data-passing into three registers.
;
; Instead, OSWORD passes data via a control block – which is just an
; area of RAM. The address of that RAM should be passed in the X and Y
; registers, and the command number in A (as before). The OSWORD call
; then uses that control block (it might read data from it, or write
; data to it) as part of its operation.
;
; OSWORD 0 is "input line" – it’s a standard way for a program to ask
; the operating system to accept a line of text from an input source.
; This line of text is stored in the control block. BASIC uses OSWORD
; 0 to receive typed commands for the interpreter. It’s also how the
; BASIC keyword INPUT works.
;
; On entry:
; XY+0,XY+1 => string buffer (assumed to be $0037, typically pointing to $0700)
; XY+2  maximum line length (buffer size minus 1, typically $EE = 238)
; XY+3  minimum acceptable ASCII value (typically $20)
; XY+4  maximum acceptable ASCII value (typically $FF)
; On exit:
; Carry=0 if not terminated by Escape
; Y is the line length excluding the CR, so buffer+Y will point to the CR
; A,X undefined
; Carry=1 if Escape terminated input, A,X,Y undefined

; This call reads characters from the current input stream by calling
; OSRDCH. Line editing is performed, at a minimum DELETE (CHR$127)
; deletes a character, Ctrl-U (CHR$21) deletes the whole line, and (if
; enabled) cursor keys perform copy editing. Editing is terminated
; with RETURN (CHR$13) or the current Escape character if enabled (the
; default is ESCAPE (CHR$27).

; Extensions may implement line input extensions, for example on RISC
; OS and many other systems, BS (CHR$8) duplicates DELETE, and Ctrl-J
; (CHR$10) duplicates RETURN.

_OSWORD:
        cmp     #$00            ; Get OSWORD call number
        bne     done            ; Return if not OSWORD 0
        ldy     #0              ; Number of characters read
loop:   jsr     OSRDCH          ; Get character
        cmp     #LF             ; LF?
        beq     loop            ; If so, ignore
        cmp     #DEL            ; Delete?
        beq     delete
        cmp     #BS             ; Backspace?
        beq     delete
        sta     ($37),Y         ; Save in buffer
        cmp     #CR             ; CR?
        beq     done
        cmp     #ESC            ; ESC?
        beq     edone
        cmp     #$20            ; Check for acceptable ASCII. Less than $20?
        bcc     loop            ; If so, ignore it
        iny                     ; Increment character count
        cpy     #$EE            ; Check for maximum line length
        beq     done            ; Branch if max reached
        jmp     loop            ; Else go back and read more characters
done:   clc                     ; Normal return, clear carry
        rts
edone:  sec                     ; Esc pressed, set carry
        rts
delete:
        dey                     ; Back out last character
        lda     #BS             ; Output backspace to erase on screen
        jsr     _OSWRCH
        lda     #' '            ; Output space to overwrite last character
        jsr     _OSWRCH
        lda     #BS             ; Output backspace again
        jsr     _OSWRCH
        jmp     loop            ; Continue

; OSWRCH
; Write character.
; OSWRCH #FFF4 Write character
; On entry:  A=character to write
; On exit:   all preserved
; TODO: Implement support for more VDU sequences (but only a few bytes
; left in the ROM). Note that some are ; standard ASCII characters and
; will work as is on a serial terminal.

_OSWRCH:
        pha
        cmp     #12             ; VDU code 12?
        beq     Clear
SerialOutWait:
        lda     ACIAStatus
        and     #2
        cmp     #2
        bne     SerialOutWait
        pla
        sta     ACIAData
        rts

; VDU 12: Clear screen and move move cursor to home (top left corner).
; Implement by sending ANSI escape sequence "<ESC>[2J<ESC>[H".

Clear:  tya                     ; Save Y
        pha
        ldy #0
ShowClearMsg:
        lda     ClearMsg,Y
        beq     ret
        jsr     _OSWRCH
        iny
        bne     ShowClearMsg
ret:    pla                     ; Restore Y
        tay
        pla                     ; Restore A
        rts

; OSRDCH
; Read character.
; Character returned in A.
; If an error occurred (usually, Escape being pressed), then the carry
; flag is set on exit. If the error was Escape, then A will be $1B.
; Echoes the character to the output.

_OSRDCH:
SerialInWait:
        lda     ACIAStatus
        and     #1
        cmp     #1
        bne     SerialInWait
        lda     ACIAData
        cmp     #ESC             ; Escape?
        bne     retn
        sec                      ; Carry set if error (e.g. Escape pressed)
        rts
retn:
        jsr     OSWRCH           ; Echo the character
        cmp     #CR              ; If CR, also echo LF
        bne     notcr
        pha                      ; Save original character
        lda     #LF
        jsr     OSWRCH           ; Send LF
        pla                      ; Restore character
notcr:  clc                      ; Carry clear if no error
        rts

; -------- STANDARD MOS ENTRY POINTS --------
; For compatibility, these are at the same addresses as in the original
; code.

        .res   $FFCE-*
; Open or close a file - not implemented.
OSFIND:
        rts
        nop
        nop
;       $FFD1
; Load or save a block of memory to file - not implemented.
OSGBPB:
        rts
        nop
        nop
;       $FFD4
; Write a byte to file - not implemented.
OSBPUT:
        rts
        nop
        nop
;       $FFD7
; Get a byte from file - not implemented.
OSBGET:
        rts
        nop
        nop
;       $FFDA
; Read or write a file's attributes - not implemented.
OSARGS:
        rts
        nop
        nop
;       $FFDD
; Default handling for OSFILE (for cassette and ROM filing system) - not implemented.
OSFILE:
        rts
        nop
        nop
;       $FFE0
; Read a character.
OSRDCH:
        jmp     _OSRDCH
;       $FFE3
; Write character in A to output. If character is CR, calls OSNEWL.
OSASCI:
        cmp     #CR
        bne     OSWRCH          ; May fall through
;       $FFE7
; Write a newline.
OSNEWL:
        lda     #LF
        jsr     _OSWRCH
;       $FFEC
; Write carriage return.
OSWRCR:
        lda     #CR             ; And fall through
;       $FFEE
; Write a character
OSWRCH:
        jmp     _OSWRCH
;       $FFF1
; System call.
OSWORD:
        jmp     _OSWORD
;       $FFF4
; System call.
OSBYTE:
        jmp     _OSBYTE
;       $FFF7
; Command Line Interpreter - not implemented.
OS_CLI:
        rts
        nop
        nop
;       $FFFA
; NMI handler.
NMI:
        .word   _NMI
;       $FFFC
; Reset handler.
RESET:
        .word   _RESET
;       $FFFE
; BRK/IRQ handler.
IRQ:
        .word   _IRQ
