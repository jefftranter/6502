; Extended Woz monitor for 6502 by fsafstrom after Steve Wozniak
; by fsafstrom Mar Wed 14, 2007 12:23 pm
; See http://www.brielcomputers.com/phpBB3/viewtopic.php?f=9&t=197#p888
;
; Ported to the ca65 assembler by Jeff Tranter <tranter@pobox.com>


; The EWoz 1.0 is just the good old Woz mon with a few improvements and extensions so to say. 
;
; It's using ACIA @ 19200 Baud. 
; It prints a small welcome message when started. 
; All key strokes are converted to uppercase. 
; The backspace works so the _ is no longer needed. 
; When you run a program, it's called with an JSR so if the program ends with an RTS, you will be taken back to the monitor. 
; You can load Intel HEX format files and it keeps track of the checksum. 
; To load an Intel Hex file, just type L and hit return. 
; Now just send a Text file that is in the Intel HEX Format just as you would send a text file for the Woz mon. 
; You can abort the transfer by hitting ESC. 
;
; The reason for implementing a loader for HEX files is the 6502 Assembler @ http://home.pacbell.net/michal_k/6502.html 
; This assembler saves the code as Intel HEX format. 
;
; In the future I might implement XModem, that is if anyone would have any use for it... 8) 
;
; Enjoy... 

; EWOZ Extended Woz Monitor.
; Just a few mods to the original monitor.

; START @ $7000

; It performs i/o using the serial port on the Multi Port I/O board for the Briel Replica 1.

ACIA        = $C000
ACIA_CTRL   = ACIA+3
ACIA_CMD    = ACIA+2
ACIA_SR     = ACIA+1
ACIA_DAT    = ACIA

IN          = $0200          ;*Input buffer
XAML        = $24            ;*Index pointers
XAMH        = $25
STL         = $26
STH         = $27
L           = $28
H           = $29
YSAV        = $2A
MODE        = $2B
MSGL        = $2C
MSGH        = $2D
COUNTER     = $2E
CRC         = $2F
CRCCHECK    = $30

            .org $7000
            .export RESET

RESET:      CLD             ;Clear decimal arithmetic mode.
            CLI
            LDA #$1F        ;* Init ACIA to 19200 Baud.
            STA ACIA_CTRL
            LDA #$0B        ;* No Parity.
            STA ACIA_CMD
            LDA #$0D
            JSR ECHO        ;* New line.
            LDA #<MSG1
            STA MSGL
            LDA #>MSG1
            STA MSGH
            JSR SHWMSG      ;* Show Welcome.
            LDA #$0D
            JSR ECHO        ;* New line.
SOFTRESET:  LDA #$9B        ;* Auto escape.
NOTCR:      CMP #$88        ;"<-"? * Note this was chaged to $88 which is the back space key.
            BEQ BACKSPACE   ;Yes.
            CMP #$9B        ;ESC?
            BEQ ESCAPE      ;Yes.
            INY             ;Advance text index.
            BPL NEXTCHAR    ;Auto ESC if >127.
ESCAPE:     LDA #$DC        ;"\"
            JSR ECHO        ;Output it.
GETLINE:    LDA #$8D        ;CR.
            JSR ECHO        ;Output it.
            LDY #$01        ;Initiallize text index.
BACKSPACE:  DEY             ;Backup text index.
            BMI GETLINE     ;Beyond start of line, reinitialize.
            LDA #$A0        ;*Space, overwrite the backspaced char.
            JSR ECHO
            LDA #$88        ;*Backspace again to get to correct pos.
            JSR ECHO
NEXTCHAR:   LDA ACIA_SR     ;*See if we got an incoming char
            AND #$08        ;*Test bit 3
            BEQ NEXTCHAR    ;*Wait for character
            LDA ACIA_DAT    ;*Load char
            CMP #$60        ;*Is it Lower case
            BMI   CONVERT   ;*Nope, just convert it
            AND #$5F        ;*If lower case, convert to Upper case
CONVERT:    ORA #$80        ;*Convert it to "ASCII Keyboard" Input
            STA IN,Y        ;Add to text buffer.
            JSR ECHO        ;Display character.
            CMP #$8D        ;CR?
            BNE NOTCR       ;No.
            LDY #$FF        ;Reset text index.
            LDA #$00        ;For XAM mode.
            TAX             ;0->X.
SETSTOR:    ASL             ;Leaves $7B if setting STOR mode.
SETMODE:    STA MODE        ;$00 = XAM, $7B = STOR, $AE = BLOK XAM.
BLSKIP:     INY             ;Advance text index.
NEXTITEM:   LDA IN,Y        ;Get character.
            CMP #$8D        ;CR?
            BEQ GETLINE     ;Yes, done this line.
            CMP #$AE        ;"."?
            BCC BLSKIP      ;Skip delimiter.
            BEQ SETMODE     ;Set BLOCK XAM mode.
            CMP #$BA        ;":"?
            BEQ SETSTOR     ;Yes, set STOR mode.
            CMP #$D2        ;"R"?
            BEQ RUN         ;Yes, run user program.
            CMP #$CC        ;* "L"?
            BEQ LOADINT     ;* Yes, Load Intel Code.
            STX L           ;$00->L.
            STX H           ; and H.
            STY YSAV        ;Save Y for comparison.
NEXTHEX:     LDA IN,Y       ;Get character for hex test.
            EOR #$B0        ;Map digits to $0-9.
            CMP #$0A        ;Digit?
            BCC DIG         ;Yes.
            ADC #$88        ;Map letter "A"-"F" to $FA-FF.
            CMP #$FA        ;Hex letter?
            BCC NOTHEX      ;No, character not hex.
DIG:        ASL
            ASL             ;Hex digit to MSD of A.
            ASL
            ASL
            LDX #$04        ;Shift count.
HEXSHIFT:   ASL             ;Hex digit left MSB to carry.
            ROL L           ;Rotate into LSD.
            ROL H           ;Rotate into MSD's.
            DEX             ;Done 4 shifts?
            BNE HEXSHIFT    ;No, loop.
            INY             ;Advance text index.
            BNE NEXTHEX     ;Always taken. Check next character for hex.
NOTHEX:     CPY YSAV        ;Check if L, H empty (no hex digits).
            BNE NOESCAPE    ;* Branch out of range, had to improvise...
            JMP ESCAPE      ;Yes, generate ESC sequence.

RUN:        JSR ACTRUN      ;* JSR to the Address we want to run.
            JMP   SOFTRESET ;* When returned for the program, reset EWOZ.
ACTRUN:     JMP (XAML)      ;Run at current XAM index.

LOADINT:    JSR LOADINTEL   ;* Load the Intel code.
            JMP   SOFTRESET ;* When returned from the program, reset EWOZ.

NOESCAPE:   BIT MODE        ;Test MODE byte.
            BVC NOTSTOR     ;B6=0 for STOR, 1 for XAM and BLOCK XAM
            LDA L           ;LSD's of hex data.
            STA (STL, X)    ;Store at current "store index".
            INC STL         ;Increment store index.
            BNE NEXTITEM    ;Get next item. (no carry).
            INC STH         ;Add carry to 'store index' high order.
TONEXTITEM: JMP NEXTITEM    ;Get next command item.
NOTSTOR:    BMI XAMNEXT     ;B7=0 for XAM, 1 for BLOCK XAM.
            LDX #$02        ;Byte count.
SETADR:     LDA L-1,X       ;Copy hex data to
            STA STL-1,X     ;"store index".
            STA XAML-1,X    ;And to "XAM index'.
            DEX             ;Next of 2 bytes.
            BNE SETADR      ;Loop unless X = 0.
NXTPRNT:    BNE PRDATA      ;NE means no address to print.
            LDA #$8D        ;CR.
            JSR ECHO        ;Output it.
            LDA XAMH        ;'Examine index' high-order byte.
            JSR PRBYTE      ;Output it in hex format.
            LDA XAML        ;Low-order "examine index" byte.
            JSR PRBYTE      ;Output it in hex format.
            LDA #$BA        ;":".
            JSR ECHO        ;Output it.
PRDATA:     LDA #$A0        ;Blank.
            JSR ECHO        ;Output it.
            LDA (XAML,X)    ;Get data byte at 'examine index".
            JSR PRBYTE      ;Output it in hex format.
XAMNEXT:    STX MODE        ;0-> MODE (XAM mode).
            LDA XAML
            CMP L           ;Compare 'examine index" to hex data.
            LDA XAMH
            SBC H
            BCS TONEXTITEM  ;Not less, so no more data to output.
            INC XAML
            BNE MOD8CHK     ;Increment 'examine index".
            INC XAMH
MOD8CHK:    LDA XAML        ;Check low-order 'exainine index' byte
            AND #$0F        ;For MOD 8=0 ** changed to $0F to get 16 values per row **
            BPL NXTPRNT     ;Always taken.
PRBYTE:     PHA             ;Save A for LSD.
            LSR
            LSR
            LSR             ;MSD to LSD position.
            LSR
            JSR PRHEX       ;Output hex digit.
            PLA             ;Restore A.
PRHEX:      AND #$0F        ;Mask LSD for hex print.
            ORA #$B0        ;Add "0".
            CMP #$BA        ;Digit?
            BCC ECHO        ;Yes, output it.
            ADC #$06        ;Add offset for letter.
ECHO:       PHA             ;*Save A
            AND #$7F        ;*Change to "standard ASCII"
            STA ACIA_DAT    ;*Send it.
WAIT:       LDA ACIA_SR     ;*Load status register for ACIA
            AND #$10        ;*Mask bit 4.
            BEQ    WAIT     ;*ACIA not done yet, wait.
            PLA             ;*Restore A
            RTS             ;*Done, over and out...

SHWMSG:     LDY #$0
PRINT:      LDA (MSGL),Y
            BEQ DONE
            JSR ECHO
            INY 
            BNE PRINT
DONE:       RTS 


; Load an program in Intel Hex Format.
LOADINTEL:  LDA #$0D
            JSR ECHO      ;New line.
            LDA #<MSG2
            STA MSGL
            LDA #>MSG2
            STA MSGH
            JSR SHWMSG      ;Show Start Transfer.
            LDA #$0D
            JSR ECHO      ;New line.
            LDY #$00
            STY CRCCHECK   ;If CRCCHECK=0, all is good.
INTELLINE:  JSR GETCHAR      ;Get char
            STA IN,Y      ;Store it
            INY            ;Next
            CMP   #$1B      ;Escape ?
            BEQ   INTELDONE   ;Yes, abort.
            CMP #$0D      ;Did we find a new line ?
            BNE INTELLINE   ;Nope, continue to scan line.
            LDY #$FF      ;Find (:)
FINDCOL:    INY
            LDA IN,Y
            CMP #$3A      ; Is it Colon ?
            BNE FINDCOL      ; Nope, try next.
            INY            ; Skip colon
            LDX   #$00      ; Zero in X
            STX   CRC         ; Zero Check sum
            JSR GETHEX      ; Get Number of bytes.
            STA COUNTER      ; Number of bytes in Counter.
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            STA CRC         ; Store it
            JSR GETHEX      ; Get Hi byte
            STA STH         ; Store it
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            STA CRC         ; Store it
            JSR GETHEX      ; Get Lo byte
            STA STL         ; Store it
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            STA CRC         ; Store it
            LDA #$2E      ; Load "."
            JSR ECHO      ; Print it to indicate activity.
NODOT:      JSR GETHEX      ; Get Control byte.
            CMP   #$01      ; Is it a Termination record ?
            BEQ   INTELDONE   ; Yes, we are done.
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            STA CRC         ; Store it
INTELSTORE: JSR GETHEX      ; Get Data Byte
            STA (STL,X)      ; Store it
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            STA CRC         ; Store it
            INC STL         ; Next Address
            BNE TESTCOUNT   ; Test to see if Hi byte needs INC
            INC STH         ; If so, INC it.
TESTCOUNT:  DEC   COUNTER      ; Count down.
            BNE INTELSTORE   ; Next byte
            JSR GETHEX      ; Get Checksum
            LDY #$00      ; Zero Y
            CLC            ; Clear carry
            ADC CRC         ; Add CRC
            BEQ INTELLINE   ; Checksum OK.
            LDA #$01      ; Flag CRC error.
            STA   CRCCHECK   ; Store it
            JMP INTELLINE   ; Process next line.

INTELDONE:  LDA CRCCHECK   ; Test if everything is OK.
            BEQ OKMESS      ; Show OK message.
            LDA #$0D
            JSR ECHO      ;New line.
            LDA #<MSG4      ; Load Error Message
            STA MSGL
            LDA #>MSG4
            STA MSGH
            JSR SHWMSG      ;Show Error.
            LDA #$0D
            JSR ECHO      ;New line.
            RTS

OKMESS:     LDA #$0D
            JSR ECHO      ;New line.
            LDA #<MSG3      ;Load OK Message.
            STA MSGL
            LDA #>MSG3
            STA MSGH
            JSR SHWMSG      ;Show Done.
            LDA #$0D
            JSR ECHO      ;New line.
            RTS

GETHEX:     LDA IN,Y      ;Get first char.
            EOR #$30
            CMP #$0A
            BCC DONEFIRST
            ADC #$08
DONEFIRST:  ASL
            ASL
            ASL
            ASL
            STA L
            INY
            LDA IN,Y      ;Get next char.
            EOR #$30
            CMP #$0A
            BCC DONESECOND
            ADC #$08
DONESECOND: AND #$0F
            ORA L
            INY
            RTS

GETCHAR:    LDA ACIA_SR     ;See if we got an incoming char
            AND #$08        ;Test bit 3
            BEQ GETCHAR     ;Wait for character
            LDA ACIA_DAT    ;Load char
            RTS

MSG1:      .byte "Welcome to EWOZ 1.0.",0
MSG2:      .byte "Start Intel Hex code Transfer.",0
MSG3:      .byte "Intel Hex Imported OK.",0
MSG4:      .byte "Intel Hex Imported with checksum error.",0
