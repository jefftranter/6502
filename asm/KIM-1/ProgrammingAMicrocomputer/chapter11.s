; Substitution Cypher. Chapter 11.

       .ORG     $0000

; KIM-1 ROM routines
STOP    = $1C00
NMIV    = $17FA
GETCH   = $1E5A
OUTCH   = $1EA0

; Zero page variables

SOURCE: .RES    2               ; Pointer to source (not in book listing)
DEST:   .RES    2               ; Pointer to destination (not in book listing)
CYPHER: .RES    26              ; Save 26 cells in page 0

; Constants in page zero:

EORD:   .BYTE   '?', 'D', '/', 'E', $0A
ALFA:   .BYTE   "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES    $0200-*

; This program does the simplest of the coding schemes, namely a sub-
; stitution cypher. We begin by clearing out the cypher alphabet
; (after setting up the stop key of course).

START:  LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDA     #$00
        LDY     #$26            ; Decimal
LO:     STA     CYPHER,Y
        DEY
        BPL     LO

; Now we are going to accept the key phrase and add each (new, valid)
; letter to the cypher alphabet as it is received.

GETKEY: JSR     GETCH
        STA     CHAR
        CMP     #$0D            ; Carriage return is the end of the key
        BEQ     REST
        CMP     #'A'
        BMI     GETKEY          ; It was less than A
        CMP     #'Z'+1
        BPL     GETKEY          ; It was past Z
        JSR     ADDALET
        JMP     GETKEY

; Next we take the remaining letters of the alphabet and put them in
; order.

REST:   LDA     #$00
        STA     PTR
MORELET:
        LDY     PTR
        LDA     ALFA,Y
        STA     CHAR
        JSR     ADDALET
        INC     PTR
        LDA     PTR
        CMP     #27             ; Decimal
        BMI     MORELET

; Next  we ask if the user wants to do encoding or decoding.

WHICH:  LDX     #$04
THIS:   LDA     EORD,X           ; Address of the letters
        JSR     OUTCH            ; "E/D Car. Ret. Linefeed"
        DEX
        BPL     THIS

; We get a character and if it is not an E we assume "decode". For
; encoding we make the alphabet be the source and the cypher be the
; destination. For decoding it is the reverse.

        JSR     GETCH
        CMP     #'E'             ; Which is 45 in zero parity ASCII
        BNE     DECODE
        LDA     #ALFA            ; The address (8 bits in page 0) of ALFA
        STA     SOURCE
        LDA     #CYPHER
        STA     DEST
        JMP     LOAD
DECODE: LDA     #CYPHER          ; An address
        STA     SOURCE
        LDA     #ALFA            ; And address
        STA     DEST

; We are going to accept letters A-Z until we get a "$". then we will
; print out the translation we have been building up in the buffer.
; We are going to find which letter to use by searching the source
; alphabet until we find the letter and then look it up in the destin-
; ation alphabet.

LOAD:   LDX     #$01             ; X is the index of characters
                                ;  received
NEXT:   JSR     GETCH
        CMP     #'$'             ; Which is 24
        BEQ     ENDIN
        CMP     #'A'
        BMI     NEXT
        CMP     #'Z'+1
        BPL     NEXT
        LDY     #26
FIND:   DEY                     ; Search for
        CMP     (SOURCE),Y       ;  the
        BNE     FIND             ;  letter
        LDA     (DEST),Y         ; Get translation
        STA     BUFFER,X         ; Store it in the buffer
        INX
        BNE     NEXT             ; If count round 255 fail thru

; We got a $ or 255 characters so we are ready to type out. We type
; out in 5 blocks of 5 characters per line until the buffer is empty.

ENDIN:  LDA     #$00
        STA     BUFFER,X          ; End of text is a "00"
        LDX     #$01
NEWLINE:
        LDA     #$05              ; Start a new line
        STA     BLOCKCT
NEWBLK: LDA     #$05              ; New block
        STA     CHARCT
OUTONE: LDA     BUFFER,X          ; Get a character
        BEQ     WHICH             ; Have finished bufferful
        INX
        JSR     OUTCH
        DEC     CHARCT
        BNE     OUTONE
        LDA     #' '
        JSR     OUTCH             ; Space between blocks
        DEC     BLOCKCT
        BNE     NEWBLK
        LDA     #$0D              ; Carriage Return
        JSR     OUTCH
        LDA     #$0A              ; Line Feed
        JSR     OUTCH
        LDA     #$7F              ; Rubout
        JSR     OUTCH
        JMP     NEWLINE

; FIXME: This routine is called but is not in the published source
; listing. Need to implement it.

ADDALET:
        RTS

; Variables:

CHAR:   .BYTE   $00             ; The current character
PTR:    .BYTE   $00             ; Which letter we are about to move
BLOCKCT:
        .BYTE   $00             ; How many blocks left this line
CHARCT: .BYTE   $00             ; How many characters left this block
BUFFER: .RES    80              ; Buffer (not in book listing)
