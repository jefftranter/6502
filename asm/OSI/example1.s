;
; "Good Listener" Example program from OSI OS65V manual.
;
; Echoes keys pressed on a line of the screen with single line
;  scrollng.
;
; Build using:
; ca65 -g -l example1.lst example1.s
; ld65 -t none -vm -o example1.bin example1.o
; ./bintolod -s 0000 -l 0000 example1.bin >example1.lod
;
; Then upload and run using:
; ascii-xfr -s example1.lod >/dev/ttyUSB0 

        GETKEY := $FEED

        .org 0

        ldx #0            ; Clear index
fill:   jsr GETKEY        ; Next pressed into A
        sta $D146,x       ; Into next line cell
        inx               ; Increment index by 1
        cpx #20           ; End of the line?
        bne fill          ; Back until equal
repeat: jsr GETKEY        ; Next pressed to A
        tay               ; Save key in Y
        ldx #0            ; Clear index
move:   lda $D147,x       ; Load line(i+1)
        sta $D146,x       ; Store into line(i)
        inx               ; Increment index
        cpx #19           ; End of the line?
        bne move          ; Back until equal
        tya               ; Restore key-in
        sta $D159         ; Store new key
        jmp repeat        ; Back for more
