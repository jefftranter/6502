; Motorola S record (run) file loader and writer.
; Will be integrated into the JMON monitor.
;
; File record format:
; S <rec type> <byte count> <address> <data>... <checksum> <CR>/<LF>/<NUL>
;
; e.g.
; S00F000068656C6C6F202020202000003C
; S11F00007C0802A6900100049421FFF07C6C1B787C8C23783C6000003863000026
; S11F001C4BFFFFE5398000007D83637880010014382100107C0803A64E800020E9
; S111003848656C6C6F20776F726C642E0A0042
; S5030003F9
; S9030000FC
;
; Record types:
; S0 header - accepted but ignored
; S1 - 16-bit address record
; S2,S3,S4 - not supported
; S5,S6 - accepted but ignored
; S7,S8 - not supported
; S9 - start address. Executes if address is not zero.
;
; At any point, quit if <ESC> character received.

; Constants

        ESC     = $1B
        CR      = $0D
        LF      = $0A
        NUL     = $00
        bytesPerLine = $20      ; S record file bytes per line

; Zero page addresses

        address = $38           ; Instruction address, 2 bytes (low/high)

; External routines

        GetKey  = $E9C4         ; ROM get character routine
        PrintChar = $EB5F       ; ROM character out routine
        PrintString = $EAF9     ; ROM print string routine
        PrintCR = $EAE9         ; Print CR
        PrintByte = $EB4C       ; Print hex byte
        PrintAddress = $EA85    ; Print hex address

        .org    $3000

;        jmp     reader

writer:
        lda     #$00            ; startAddress = $E000 (arbitrary, for test purposes)
        sta     startAddress
        lda     #$E0
        sta     startAddress+1
        lda     #$FF            ; endAddress = $E3FF
        sta     endAddress
        lda     #$E3
        sta     endAddress+1
        lda     #$01            ; goAddress = $E001
        sta     goAddress
        lda     #$E0
        sta     goAddress+1
        sta     checksum        ; checksum = $00
        sta     bytesWritten    ; bytesWritten = $00

        lda     startAddress    ; address = startAddress
        sta     address
        lda     startAddress+1
        sta     address+1

; Write S0 record, fixed as: <CR>S0030000FC<CR>

        ldx     #<S0String
        ldy     #>S0String
        jsr     PrintString

writes1:                        ; Write S1 records
        lda     #0
        sta     bytesWritten    ; bytesWritten = 0
        sta     checksum        ; checksum = 0

        lda     #'S'            ; Write "S1"
        jsr     PrintChar
        lda     #'1'
        jsr     PrintChar

        lda     #bytesPerLine+3 ; write bytesPerLine (+3 for size and address)
        jsr     PrintByte

        lda     #bytesPerLine   ; checksum = bytesPerLine
        sta     checksum

        ldx      address        ; write address
        ldy      address+1
        jsr      PrintAddress

        lda      checksum       ; checksum = checksum + addressHigh
        clc
        adc      address+1
        clc
        adc      address        ; checksum = checksum + addressLow
        sta      checksum

writeLoop:
        ldy     #0
        lda     (address),y
        jsr     PrintByte       ; print byte at address

        clc
        adc     checksum        ; checksum = checksum + byte at address
        sta     checksum

        inc     address         ; Increment address (low byte)
        bne     nocarry1
        inc     address+1       ; Increment address (high byte)
nocarry1:
        inc     bytesWritten    ; bytesWritten = bytesWritten + 1

        lda     bytesWritten    ; if bytesWritten != bytesPerLine
        cmp     #bytesPerLine
        bne     writeLoop       ; ...go back and loop

        lda     checksum        ; Calculate checksum 1's complement
        eor     #$ff
        jsr     PrintByte       ; Output checksum
        jsr     PrintCR         ; Output line terminator

        lda     address+1       ; if address <= endAddress, go back and continue
        cmp     endAddress+1
        bmi     writes1
        beq     writes1
        lda     address
        cmp     endAddress
        bmi     writes1
        beq     writes1

; Write S9 record

        lda     #'S'            ; Write S9
        jsr     PrintChar
        lda     #'9'
        jsr     PrintChar
        lda     #$03            ; Write 03
        jsr     PrintByte
        lda     #$03            ; checksum = 03
        sta     checksum

        ldx     goAddress       ; Send go address
        ldy     goAddress+1
        jsr     PrintAddress

        lda     checksum        ; checksum = checksum + goAaddress high
        clc
        adc     goAddress+1
        clc
        adc     goAddress       ; checksum = checksum + goAddress low
        sta     checksum

        lda     checksum        ; Calculate checksum 1's complement
        eor     #$ff
        jsr     PrintByte       ; Output checksum
        jsr     PrintCR         ; Output line terminator

        rts

; ------------------------------------------------------------------------

reader:
        lda     #0
        sta     checksum        ; Checksum = 0
        sta     bytesRead       ; BytesRead = 0
        sta     byteCount       ; ByteCount = 0
        sta     address         ; Address = 0
        sta     address+1

loop:
        jsr     GetKey          ; Get character
        cmp     #ESC
        bne     notesc
        rts                     ; Return if <ESC>
notesc:
;       jsr     PrintChar       ; Echo the character
        cmp     #CR             ; Ignore if <CR>
        beq     loop
        cmp     #LF             ; Ignore if <LF>
        beq     loop
        cmp     #NUL            ; Ignore if <NUL>
        beq     loop

        cmp     #'S'            ; Should be 'S'
        bne     invalidRecord   ; If not, error

        jsr     GetKey          ; Get record type character
;       jsr     PrintChar       ; Echo the character

        cmp     #'0'            ; Should be '0', '1', '5', '6' or '9'
        beq     validType
        cmp     #'1'
        beq     validType
        cmp     #'5'
        beq     validType
        cmp     #'6'
        beq     validType
        cmp     #'9'
        beq     validType

invalidRecord:
        ldx     #<SInvalidRecord
        ldy     #>SInvalidRecord
        jsr     PrintString     ; Display "Invalid record"
        jsr     PrintCR
        rts                     ; Return

validType:
        sta     recordType      ; Save char as record type '0'..'9'

        jsr     getHexByte      ; Get byte count
        bcs     invalidRecord
        cmp     #3              ; Invalid if byteCount  < 3
        bmi     invalidRecord
        sta     byteCount       ; Save as byte count

        clc
        adc     checksum        ; Add byte count to checksum
        sta     checksum

        lda     recordType      ; If record type is 5 or 9, byte count should be 3
        cmp     #'5'
        beq     checkcnt
        cmp     #'9'
        bne     getadd
checkcnt:
        lda     byteCount
        cmp     #3
        beq     getadd
        bne     invalidRecord

getadd:
        jsr     getHexAddress   ; Get 16-bit start address
        bcs     invalidRecord

        stx     address         ; Save as address
        sty     address+1

        txa
        clc
        adc     checksum        ; Add address bytes to checksum
        sta     checksum
        tya
        clc
        adc     checksum
        sta     checksum

        inc     bytesRead       ; Increment bytesRead by 2 for address field
        inc     bytesRead

readRecord:

        lda     bytesRead       ; If bytesRead+1 = byteCount (have to allow for checksum byte)
        clc
        adc     #1
        cmp     byteCount
        beq     dataend         ; ...break out of loop

        jsr     getHexByte      ; Get two hex digits
        bcs     invalidRecord   ; Exit if invalid

        sta     temp1           ; Save data

        clc
        adc     checksum        ; Add data read to checksum
        sta     checksum

        lda     recordType
        cmp     #'1'            ; Is record type 1?
        bne     nowrite
        lda     temp1           ; Get data back
        ldy     #0
        sta     (address),y     ; Write data to address

; TODO: Could verify data written, but not necessarily an error.

nowrite:
        lda     recordType      ; Only increment address if this is an S1 record
        cmp     #'1'
        bne     nocarry
        inc     address         ; Increment address (low byte)
        bne     nocarry
        inc     address+1       ; Increment address (high byte)
nocarry:
        inc     bytesRead       ; Increment bytesRead
        jmp     readRecord      ; Go back and read more data

dataend:
        jsr     getHexByte      ; Get two hex digits (checksum)
        bcc     okay1
        jmp     invalidRecord
okay1:
        eor     #$FF            ; Calculate 1's complement
        cmp     checksum        ; Compare to calculated checksum
        beq     sumokay         ; branch if matches
        ldx     #<SChecksumError
        ldy     #>SChecksumError
        jsr     PrintString     ; Display "Checksum error"
        jsr     PrintCR
        rts                     ; Return

sumokay:
        lda     recordType      ; Get record type
        cmp     #'9'            ; S9 (end of file)?
        beq     s9
        jmp     writer          ; If not go back and read more records
s9:
        ldx     #<SLoaded
        ldy     #>SLoaded
        jsr     PrintCR
        jsr     PrintString     ; Display "Loaded"
        jsr     PrintCR
        lda     address         ; Start execution if start address = 0
        beq     lowz
highz:
        rts                     ; Otherwise just return
lowz:
        lda     address+1
        beq     highz
        jmp     (address)       ; Start execution at start address

; Read character corresponding to hex number ('0'-'9','A'-'F').
; If valid, return binary value in A and carry bit clear.
; If not valid, return with carry bit set.
getHexChar:
        jsr     GetKey          ; Read character
;       jsr     PrintChar       ; Echo the character
        cmp     #'0'            ; Error if < '0'
        bmi     error1
        cmp     #'9'+1          ; Valid if <= '9'
        bmi     number1
        cmp     #'F'+1          ; Error if > 'F'
        bpl     error1
        cmp     #'A'            ; Error if < 'A'
        bmi     error1
        sec
        sbc     #'A'-10         ; Value is character-('A'-10)
        jmp     good1
number1:
        sec
        sbc     #'0'            ; Value is character-'0'
        jmp     good1
error1:
        sec                     ; Set carry to indicate error
        rts                     ; Return
good1:
        clc                     ; Clear carry to indicate valid
        rts                     ; Return

; Read two characters corresponding to 8-bit hex number.
; If valid, return binary value in A and carry bit clear.
; If not valid, return with carry bit set.
getHexByte:
        jsr     getHexChar      ; Get high nybble
        bcs     bad1            ; Branch if invalid
        asl                     ; Shift return value left to upper nybble
        asl
        asl
        asl
        sta     temp1           ; Save value
        jsr     getHexChar      ; Get low nybble
        bcs     bad1            ; Branch if invalid
        ora     temp1           ; Add (OR) return value to previous value
        rts                     ; Return with carry clear

; Read four characters corresponding to 16-bit hex address.
; If valid, return binary value in X (low) and Y (high) and carry bit clear.
; If not valid, return with carry bit set.
getHexAddress:
        jsr     getHexByte      ; Get high order byte
        bcs     bad1            ; Branch if invalid
        tay                     ; Save value in Y
        jsr     getHexByte      ; Get low order byte
        bcs     bad1            ; Branch if invalid
        tax                     ; Save value in X
        rts                     ; Return with carry clear
bad1:
        rts                     ; Return with carry set

; Strings

SInvalidRecord:
        .asciiz "Invalid record"
SChecksumError:
        .asciiz "Checksum error"
SLoaded:
        .asciiz "Loaded"
S0String:
        .byte   CR, "S0030000FC", CR, 0

; Variables

temp1:
        .res 1                  ; Temporary
checksum:
        .res 1                  ; Calculated checksum
bytesRead:
        .res 1                  ; Number of record bytes read
recordType:
        .res 1                  ; S record type field, e.g '9'
byteCount:
        .res 1                  ; S record byte count field

startAddress:
        .res 2                  ; Start address
endAddress:
        .res 2                  ; End address
goAddress:
        .res 2                  ; Go address
bytesWritten:
        .res 1                  ; Number of record bytes written
