; OSI 65U PROM MONITOR MOD 2
;
FLAG=$FB                ; Input device 0=keyboard, non-zero=cassette tape
DAT=$FC                 ; Holds current data byte
PNTL=$FE                ; Holds current address (low byte)
PNTH=$FF                ; Holds current address (high byte)
;
        *=$FE00
VM      LDX     #$28    ; INITIALIZATION (reset vector)
        TXS             ; Initialize stack pointer to $0128
        CLD             ; Clear decimal mode

        NOP             ; Replaces old ACIA code which was removed.
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP

        LDX     #$D4    ; Last page of video memory
        LDA     #$D0    ; First page of video memory
        STA     PNTH    ; Set PNTH/L to $D000 (start of video memory)
        LDA     #0
        STA     PNTL
        STA     FLAG    ; Clear load flag (input from keyboard)
        TAY
        LDA     #' '
VM1     STA     (PNTL),Y ; Clear location on screen
        INY             ; Advance to next location
        BNE     VM1     ; Repeat 255 times
        INC     PNTH    ; Increment high byte of address
        CPX     PNTH    ; Last page of video memory reached?
        BNE     VM1     ; If not, continue
        STY     PNTH
        BEQ     IN      ; Screen cleared, go to user input routine
;
ADDR    JSR     INPUT   ; ADDRESS MODE Get character (from keyboard or cassette)
        CMP     #'/'    ; "/" character indicating data mode?
        BEQ     DATA    ; If so, handle it
        CMP     #'G'    ; G character?
        BEQ     GO      ; If so, handle it
        CMP     #'L'    ; L character?
        BEQ     LOAD    ; If so, handle it
        JSR     LEGAL   ; Should be a hex character
        BMI     ADDR    ; Bad input, ignore and continue
        LDX     #2      ; Shift address 2 nybbles
        JSR     ROLL
IN      LDA     (PNTL),Y ; Get data at current address
        STA     DAT     ; Save it
        JSR     OUTPUT  ; Display current address and data
        BNE     ADDR    ; Go back and get user input
GO      JMP     (PNTL)  ; Jump (note: not JSR) to current address
;
DATA    JSR     INPUT   ; DATA MODE  Get character (from keyboard or cassette)
        CMP     #'.'    ; Is it a dot, indicating address mode?
        BEQ     ADDR    ; If so, go to address mode
        CMP     #$D     ; Is it Return?
        BNE     DAT4    ; Skip if not
        INC     PNTL    ; Increment current address (low byte)
        BNE     DAT3    ; If low byte became zero...
        INC     PNTH    ;   increment high byte too.
DAT3    LDY     #0      
        LDA     (PNTL),Y ; get data from new current address
        STA     DAT     ; save it
        JMP     INNER
DAT4    JSR     LEGAL   ; Check for legal hex digit
        BMI     DATA    ; If invalid, ignore and go back for more input
        LDX     #0
        JSR     ROLL    ; Shift data one nybble to acommodate new one
        LDA     DAT     ; Get data
        STA     (PNTL),Y ; Store it in memory
INNER   JSR     OUTPUT  ; Output current address and data
        BNE     DATA    ; Go back for more user input
;
LOAD    STA     FLAG    ; KICK INPUT DEVICE FLAG (enable input from cassette)
        BEQ     DATA    ; Go back and accept user input
;
OTHER   LDA     $F000   ; SERIAL INPUT SUB
        LSR     A       ; (FOR AUDIO CASSETTE)
        BCC     OTHER   ; Branch until data available
        LDA     $F001   ; Get data from ACIA
        NOP             ; Delay?
        NOP
        NOP
        AND     #$7F    ; Convert to 7-bit ASCII
        RTS             ; and return to caller
;
        .BYTE   0,0,0,0 ; EXCESS ROOM
;
LEGAL   CMP     #'0'    ; IGNORE NON HEX CHAR.
        BMI     FAIL    ; Bad if less than '0'
        CMP     #':'
        BMI     OK      ; Okay if less than ':' (i.e. 0-9)
        CMP     #'A'
        BMI     FAIL    ; Bad if less than 'A'
        CMP     #'G'
        BPL     FAIL    ; Bad if 'G' or higher
        SEC             ; Convert from 'A' to  'F' to $0A to $0F
        SBC     #7      ; by subtracting 7
OK      AND     #$F     ; mask out lower nybble
        RTS             ; and return the value
FAIL    LDA     #$80    ; Return minus value to indicate error
        RTS
;
OUTPUT  LDX     #3      ; OUTPUT LLLL DD on
        LDY     #0      ; ONTO SCREEN
OUI     LDA     DAT,X
        LSR     A
        LSR     A
        LSR     A
        LSR     A
        JSR     DIGIT
        LDA     DAT,X
        JSR     DIGIT
        DEX
        BPL     OUI
        LDA     #' '
        STA     $D0CA
        STA     $D0CB
        RTS
;
DIGIT   AND     #$F     ; OUTPUT 1 DIGIT TO SCREEN
        ORA     #$30
        CMP     #$3A
        BMI     HA1
        CLC
        ADC     #7
HA1     STA     $D0C6,Y
        INY
        RTS
;
ROLL    LDY     #4      ; MOVE LSD IN AC TO
        ASL     A       ; LSD IN 2 BYTE NUM.
        ASL     A
        ASL     A
        ASL     A
R01     ROL     A
        ROL     DAT,X
        ROL     DAT+1,X
        DEY
        BNE     R01
        RTS
INPUT   LDA     FLAG    ; CASSETTE IN?
        BNE     $FE80   ; YES-GO TO ACIA INPUT
        JMP     $FD00   ; NO-GO POLL KB

        .WORD   $FFBA
        .WORD   $FF69
        .WORD   $FF9B
        .WORD   $FF8B
        .WORD   $FF96

        .WORD   $0130   ; NMI VECTOR (Note: on RAM page 1, can be clobbered by stack)
        .WORD   $FE00   ; RESET VECTOR
        .WORD   $1C0    ; IRQ VECTOR (Note: on RAM page 1, can be clobbered by stack)
        .END
