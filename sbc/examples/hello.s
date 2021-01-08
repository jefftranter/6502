; Simple example to print message on serial console.

        MONCOUT = $FF3B         ; ROM character out routine
        CR      = $0D           ; Carriage return
        LF      = $0A           ; Line feed

        .org     $2000          ; Start address

        ldy     #0              ; Index into string
loop:
        lda     Hello,y         ; Get character from string
        beq     done            ; Done if null
        jsr     MONCOUT         ; Output character
        iny                     ; Update index
        bne     loop            ; Go back and repeat
done:
        rts                     ; Return

Hello:
        .byte   CR, LF, "Hello, world!", CR, LF, $00
