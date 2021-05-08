; Table III
;
; 16 X 32 Full-performance Cursor:
;
; uP - 6502       Start - /IRQ  Displayed 0200-03FF
; System - KIM-1  End - RTI     Program Space 0100-01df
;
; Input to Parallel Word A  |0|A7|A6|A5|A4|A3|A2|A1| |_| /IRQ
;                                                  ->| | <- 10 us
; Clear - CAN (18)           Cursor Home - SOH (01)
; Carriage Return - CR (0d)  Scroll Up - DC1 (11)
; Cursor Up - VT (0b)        Erase to End - DC2 (12)
; Cursor Down - LF 9 (0A)    Spare Hook - DC3 (13)
;
; Cursor Left - BS (08)      Enter -- All character
; Cursor Right - HT (09)     Ignore -- All other CTRL

        CURSOR   = $00ED        ; Cursor address (two bytes)

        .org    $0100

IRQ:    PHA                     ; Save A
        LDY     #$00            ; Reset Y Index
        LDA     CURSOR+1        ; Get cursor and test for range
        CMP     #$03            ; Is cursor on page 3?

        BEQ     l010d           ; Yes, OK to continue
        CMP     #$02            ; Is cursor on page 2?
        BNE     l0147           ; No, Home cursor
l010d:  LDA     (CURSOR),Y      ; Get old cursored character

        AND     #$7F            ; Erase old cursor
        STA     (CURSOR),Y      ; Replace character without cursor
        LDA     $1700           ; Get new character from A parallel Int.
        CMP     #' '            ; Is it a character to be entered?

        BCS     l0142           ; Yes, go and enter character
        CMP     #$18            ; Clear Screen?
        BEQ     l015e           ; Yes, clear screen
        CMP     #$0D            ; Return Carriage?

        BEQ     l0152           ; Yes, Return carriage
        CMP     #$0B            ; Cursor Up?
        BEQ     l0194           ; Yes, Up Cursor
        CMP     #$0A            ; Cursor Down?

        BEQ     l0166           ; Yes, Down Cursor
        CMP     #$09            ; Cursor Right?
        BEQ     l0158           ; Yes, Right Cursor
        CMP     #$08            ; Cursor Left?

        BEQ     l01a7           ; Yes, Left Cursor
        CMP     #$01            ; Cursor Home?
        BEQ     l0147           ; Yes, Home Cursor
        CMP     #$11            ; Scroll Up?

        BEQ     l0175           ; Yes, Scroll Up
        CMP     #$12            ; Spare Hook?
        BEQ     l014a           ; Ignore--Restore Cursor
        CMP     #$13            ; Erase to EOS?

        BEQ     l01b1           ; Yes, erase to EOS
l0142:  JSR     l01d3           ; /////Enter Character/////
l0145:  BNE     l014a           ; End of Screen?
l0147:  JSR     l01c2           ; Yes, home cursor

l014a:  LDA     (CURSOR),Y      ; ////Restore Cursor/////
        ORA     #$80            ; Add cursor to cursored character
        STA     (CURSOR),Y      ; Replace cursored character
        PLA                     ; Get A

        RTI                     ; Return to scan
l0152:  LDA     CURSOR          ; ////Carriage Return/////
        ORA     #$1F            ; Move cursor to Right End
        STA     CURSOR          ; Restore Cursor

l0158:  JSR     l01d5           ; Increment Cursor
        JMP     l0145           ; Finish
l015e:  JSR     l01c2           ; ////Clear////Home Cursor
        JSR     l01cb           ; Clear Screen

        BEQ     l0147           ; Finish
l0166:  LDA     CURSOR          ; ////Cursor Down//// Get Cursor
        CLC                     ; Clear Carry
        ADC     #$20            ; Move Cursor Down

        STA     CURSOR          ; Restore Cursor
        BCC     l0172           ; Overflow of page?
        JSR     l01d9           ; Yes, increment upper page
l0172:  JMP     l0145           ; Finish

l0175:  JSR     l01c2           ; ////Scroll Up//// Home Cursor
l0178:  LDY     #$20            ; Add offset to index
        LDA     (CURSOR),Y      ; Get Offset Indexed Character
        LDY     #$00            ; Remove Offset from Index

        JSR     l01d3           ; Enter Moved Character and Increment
        BNE     l0178           ; Repeat?
        CLC                     ; Clear Carry
l0184:  LDA     #$01            ; Set A to page 3

        STA     CURSOR+1        ; Set Cursor to Page 3
        LDA     #$E0            ; Set A to start of last line
        STA     CURSOR          ; Set Cursor to Start of last line
        BCS     l014a           ; Finish if carry set.

        JSR     l01cb           ; Clear last line
        SEC                     ; Set Carry
        BCS     l0184           ; Restore Cursor to start of last line
l0194:  LDA     CURSOR          ; ////Cursor Up/////Get Cursor

        SEC                     ; Set Carry
        SBC     #$20            ; Move up one line
        STA     CURSOR          ; Restore Cursor
        BCS     l014a           ; Underflow of page?

l019d:  DEC     CURSOR+1        ; Yes, decrement page
        LDA     #$01            ; Set A to Page 1
        CMP     CURSOR+1        ; Did screen underflow?
        BNE     l014a           ; No, Finish

        BEQ     l0147           ; Yes, Home Cursor
l01a7:  DEC     CURSOR          ; ///Cursor Left////Decrement Cursor
        LDA     #$FF            ; Set A to page underflow
        CMP     CURSOR          ; Test for page underflow

        BEQ     l019d           ; Change Page if off Page
        BNE     l014a           ; Finish if on page
l01b1:  LDA     CURSOR+1        ; ////Erase to EOS///Get Cursor
        PHA                     ; Save Upper cursor location

        LDA     CURSOR          ; Get lower cursor location
        PHA                     ; Save lower cursor location
        JSR     l01cb           ; Clear to End of Screen
        PLA                     ; Get lower cursor location

        STA     CURSOR          ; Restore lower cursor
        PLA                     ; Get upper cursor location
        STA     CURSOR+1        ; Restore upper cursor
        BNE     l014a           ; Finish

l01c2:  LDA     #$00            ; ///SUB//Home Cursor///
        STA     CURSOR          ; Set lower cursor to zero
        LDA     #$02            ; Put page 2 in A
        STA     CURSOR+1        ; Set upper cursor to 0200

        RTS                     ; Return to main program
l01cb:  LDA     #' '            ; ///SUB//Enter Space///
        JSR     l01d3           ; Enter space via Sub
        BNE     l01cb           ; Repeat if not to end

        RTS                     ; Return to main program
l01d3:  STA     (CURSOR),Y      ; ////SUB//Enter,Increment// store
l01d5:  INC     CURSOR          ; Increment Cursor
        BNE     l01df           ; Overflow?

l01d9:  INC     CURSOR+1        ; Yes, increment cursor page to 03
        LDA     #$04            ; Load A with page 4
        CMP     CURSOR+1        ; Test for Overflow
l01df:  RTS                     ; Return to main program

; NOTES:  IRQ vector must be stored in 17FE 00 and 17FF 01.
;
;         Total available stack length is 32 words.  Approximately
;         16 are used by operating system, cursor, and scan program.
;         Stack must be initialized to 01FF as is done in KIM-1
;         operating system.  For 30 additional stack locations,
;         relocate subroutines starting at 01C2 elsewhere.
;
;         To protect page, load 00F3 04.  To enable entry load 00F3 00.
;
;         Cursor address is stored at 00ED low and 00EE high on
;         page zero.
;
;         To display cursor load 014D 80.  To not display cursor
;         load 014D 00.
;
;         * Denotes a relative branch that is program length
;           sensitive.
;
;         ( ) Denotes an absolute address that is program
;         sensitive.
