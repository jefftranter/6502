; Port of Acorn System/Atom MOS System Calls to my 6502
; Single Board Computer.
;
; Jeff Tranter <tranter@pobpox.com>
;
; Helpful references:
; http://mdfs.net/Docs/Comp/Acorn/Atom/MOSEntries
; https://en.wikipedia.org/wiki/Acorn_MOS
; https://central.kaserver5.org/Kasoft/Typeset/BBC/Ch43.html
; https://danceswithferrets.org/geekblog/?p=872
; http://danceswithferrets.org/geekblog/?p=961

; Memory map:
; RAM from $0000 to $3FFF
; BBC Basic in RAM from $4000 to $7FFF
; OS ROM from $FF00 to $FFFF


        LF      = $0A           ; Line feed
        CR      = $0D           ; Carriage return
        ESC     = $1B           ; Ecape

        FAULT   = $FD           ; Pointer to error block
        BRKV    = $0202         ; NMI/BRK handler address
        WRCHV   = $020E         ; OSWRCH handler address

        TMP1    = $50           ; Temporary (two bytes)

; SBC defines
        ACIA    = $A000         ; Serial port registers
        ACIAControl = ACIA+0
        ACIAStatus  = ACIA+0
        ACIAData  = ACIA+1

.org    $FF00

; NMI and BRK handler
; Based on BBC code. See "Faults, events and BRK handling" section in
; the BBC Microcomputer User Guide.

_NMI:
        STA     $FC             ; temporary for A
        PLA
        PHA                     ; get processor status
        AND     #$10
        BNE     LBRK
        JMP     ($0204)         ; IRQ1V
LBRK:   TXA                     ; BRK handling
        PHA                     ; save X
        TSX
        LDA     $103,X          ; get address low
        CLD
        SEC
        SBC     #1
        STA     FAULT
        LDA     $104,X          ; get address high
        SBC     #0
        STA     FAULT+1
        jmp     (BRKV)

; RESET routine
_RESET:
        lda     #OSWRCH & 255   ; Set up RAM vector to OSWRCH
        sta     WRCHV
        lda     #OSWRCH / 256
        sta     WRCHV+1

        lda     #$01            ; Must be $01 or Basic will return
        jmp     $4000           ; Basic entry point

; IRQ routine
_IRQ:
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
        ldx     #$0000 & 256    ; Return value $0000
        ldy     #$0000 / 256
        rts

; OSBYTE &83 (131) - Read OSHWM, bottom of user memory
; On exit X and Y hold the lowest address of user memory, used to
; initialise BASIC's 'PAGE'.
osbyte83:
        ldx     #$0000 & 256
        ldy     #$0000 / 256
        rts

; OSBYTE &84 (132) - Read top of user memory
; On exit X and Y point to the first byte after the top of user memory,
; used to initialise BASIC's 'HIMEM'.
osbyte84:
        ldx     #$4000 & 256
        ldy     #$4000 / 256
        rts

; OSBYTE &85 (133) - Read base of display RAM for a given mode
; X=mode number
; On exit X and Y point to the first byte of screen RAM if MODE X were chosen
osbyte85:
        ldx     #$F000 & 256    ; Return fake value $F000
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
; 0 to receive typed commands for the interpeter. It’s also how the
; BASIC keyword INPUT works.
;
; On entry:
; XY+0,XY+1 => string buffer
; XY+2  maximum line length (buffer size minus 1)
; XY+3  minimum acceptable ASCII value
; XY+4  maximum acceptable ASCII value
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
; default is ESCAPE CHR$27).

; Extensions may implement line input extensions, for example on RISC
; OS and many other systems, BS (CHR$8) duplicates DELETE, and Ctrl-J
; (CHR$10) duplicates RETURN.

_OSWORD:
        cmp     #$00            ; Get OSWORD call number
        bne     done            ; Return if not OSWORD 0
        stx     TMP1            ; String buffer low byte
        sty     TMP1+1          ; String buffer high byte
        ldy     #0              ; Number of characters read
loop:   jsr     OSRDCH          ; Get character
        sta     (TMP1),y        ; Save in buffer
        cmp     #CR             ; CR?
        beq     done
        cmp     #LF             ; LF?
        beq     done
        cmp     #ESC            ; ESC?
        beq     done
; TODO: Add support for backspace and delete.
; TODO: Check for acceptable ASCII values
; TODO: Check for maximum line length.
        iny                     ; Increment character count
        jmp     loop            ; Go back and read more characters
done:   rts

; OSWRCH
; Write character.
; OSWRCH #FFF4 Write character
; On entry:  A=character to write
; On exit:   all preserved

_OSWRCH:
	pha
SerialOutWait:
	lda	ACIAStatus
	and	#2
	cmp	#2
	bne	SerialOutWait
	pla
	sta	ACIAData
        rts

; OSRDCH
; Read character.
; Character returned in A.
; If an error occurred (usually, Escape being pressed), then the carry
; flag is set on exit. If the error was Escape, then A will be $1B.

_OSRDCH:
SerialInWait:
	lda	ACIAStatus
	and	#1
	cmp	#1
	bne	SerialInWait
	lda	ACIAData
        cmp     #ESC             ; Escape?
        bne     retn
	sec		         ; Carry set if error (e.g. Escape pressed)
	rts
retn:
	clc                      ; Carry clear if no error
	rts

; -------- STANDARD MOS ENTRY POINTS --------

        .res   $FFCE-*
OSFIND:
        rts

        .res    $FFD1-*
OSGBPB:
        rts

        .res    $FFD4-*
OSBPUT:
        rts

        .res    $FFD7-*
OSBGET:
        rts

        .res    $FFDA-*
OSARGS:
        rts

        .res    $FFDD-*
OSFILE:
        rts

        .res    $FFE0-*
OSRDCH:
        jmp     _OSRDCH

        .res    $FFE3-*
OSASCI:
        rts

        .res    $FFE7-*
OSNEWL:
        rts
        
        .res    $FFEC-*
OSWRCR:
        rts
        
        .res    $FFEE-*
OSWRCH:
        jmp     _OSWRCH
        
        .res    $FFF1-*
OSWORD:
        jmp     _OSWORD

        .res    $FFF4-*
OSBYTE:
        jmp     _OSBYTE
        
        .res    $FFF7-*
OS_CLI:
        rts

        .res    $FFFA-*
NMI:
        .word   _NMI

        .res    $FFFC-*
RESET:
        .word   _RESET

        .res    $FFFE-*
IRQ:
        .word   _IRQ
