; Port of Acorn System/Atom MOS System Calls to Ohio Scientific
; C1P/Superboard.
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
; RAM from $0000 to $7FFF
; BBC Basic ROM from $8000 to $BFFF
; OS ROM from $FF00 to $FFFF (BBC computer used $C000 to $FFFF)

        FAULT   = $FD           ; Pointer to error block
        BRKV    = $0202         ; NMI/BRK handler address
        WRCHV   = $020E         ; OSWRCH handler address

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

        lda     #$00            ; Can't be $01 or Basic will return
        jmp     $8000           ; Basic entry point

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
; So it makes sense that I need to implement this routine so that
; BASIC will function – otherwise, it wouldn’t be able to get a
; program from the user!

_OSWORD:
        rts

; OSWRCH
;
; Write character.
;
; OSWRCH #FFF4 Write character
; On entry:  A=character to write
; On exit:   all preserved
; OSWRCH #FFF9 Write ASCII character
; On entry:  A=character to write
; On exit:   all preserved

_OSWRCH:
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
        rts

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
        JMP     _OSWRCH
        
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
