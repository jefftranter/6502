;
; JMon - Simple Monitor Program
;
; Fills some gaps missing from Woz monitor.
;
; Jeff Tranter <tranter@pobox.com>
;
; Revision History
; Version Date         Comments
; 0.0     19-Feb-2012  First version started
; 0.1     21-Feb-2012  Initial release
; 0.2     10-Mar-2012  Added search command.
;                      Avoid endless loop in PrintString if string too long.

;  This version uses the serial port on the Multi I/O board.

 .include "6551.inc"

; Constants
  CR  = $0D ; Carriage Return
  SP  = $20 ; Space
  ESC = $1B ; Escape

; Page Zero locations
  T1   = $35      ; temp variable 1
  T2   = $36      ; temp variable 2
  SL   = $37      ; start address low byte
  SH   = $38      ; start address high byte
  EL   = $39      ; end address low byte
  EH   = $3A      ; end address high byte
  DA   = $3F      ; fill data byte
  DL   = $40      ; destination address low byte
  DH   = $41      ; destination address high byte
  BIN  = $42      ; holds binary value low byte
  BINH = $43      ; holds binary value high byte
  BCD  = $44      ; holds BCD decimal number
  BCD2 = $45      ; holds BCD decimal number
  BCD3 = $46      ; holds BCD decimal number
  LZ   = $47      ; boolean for leading zero suppression
  LAST = $48      ; boolean for leading zero suppression / indicates last byte

; External Routines
  WOZMON   = $FF00 ; Woz monitor entry point
  MINIMON  = $FE14 ; Mini monitor entry point (valid for 6502 version 1.3)
  KRUSADER = $F000 ; Krusader Assembler
  BASIC    = $E000 ; BASIC
;  PRBYTE   = $FFDC ; Woz monitor print byte as two hex chars

; Use start address of $A000 for Multi I/0 Board EEPROM
;  .org $A000

; JMon Entry point
  .export JMON
JMON:
; Initialize some things just in case
  CLD ; clear decimal mode
  CLI ; clear interrupt disable
  LDX #0
  TXS ; initialize stack pointer to $0100

; Set 1 stop bit, 8 bit data, internal clock, 19200bps
  LDA #%00011111
  STA CTLREG

; Set no parity, no echo, no TX interrupts, RTS low, no RX interrupts, DTR low  
  LDA #%00001011
  STA CMDREG

; Display Welcome message
  LDX #<WelcomeMessage
  LDY #>WelcomeMessage
  JSR PrintString

MainLoop:
; Display prompt
  LDX #<PromptString
  LDY #>PromptString
  JSR PrintString

;  Get first character of command
  JSR GetKey

; ?
  CMP #'?'
  BEQ DoHelp

; H
  CMP #'H'
  BEQ DoHex

; $
  CMP #'$'
  BNE @TryF
  JMP DoMon

; F
@TryF:
  CMP #'F'
  BNE @TryC
  JMP DoFill

; C
@TryC:
  CMP #'C'
  BNE @TryV
  JMP DoCopy

; V
@TryV:
  CMP #'V'
  BNE @TryS
  JMP DoVerify

; S
@TryS:
  CMP #'S'
  BNE @TryK
  JMP DoSearch

; K
@TryK:
  CMP #'K'
  BNE @TryA
  JMP DoMiniMonitor

; A
@TryA:
  CMP #'A'
  BNE @TryB
  JMP DoAssembler

; B
@TryB:
  CMP #'B'
  BNE @TryR
  JMP DoBasic

; R
@TryR:
  CMP #'R'
  BNE @TryD
  JMP DoRun

; D
@TryD:
  CMP #'D'
  BNE @Invalid
  JMP DoDump

; Invalid command
@Invalid:
  LDX #<InvalidCommand
  LDY #>InvalidCommand
  JSR PrintString
  JMP MainLoop

; Display help
DoHelp:
  JSR PrintChar ; echo command
  JSR PrintCR
  LDX #<HelpString1
  LDY #>HelpString1
  JSR PrintString
  LDX #<HelpString2
  LDY #>HelpString2
  JSR PrintString
  JMP MainLoop

; Go to Woz Monitor
DoMon:  JMP WOZMON

; Go to Krusader Mini Monitor
DoMiniMonitor:  JMP MINIMON

; Go to Krusader Assembler
DoAssembler:  JMP KRUSADER

; Go to BASIC
DoBasic:  JMP BASIC

; Hex to decimal conversion command
DoHex:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for address
        STX BIN         ; store address
        STY BINH
        JSR PrintSpace
        LDA #'='
        JSR PrintChar
        JSR PrintSpace

; If value as 16-bit signed is negative (high bit set) display a minus
; signed and convert to 2's complement.

        LDA BINH        ; MS byte
        BPL @plus       ; not negative
        EOR #$FF        ; complement the bits
        STA BINH
        LDA BIN         ; LS byte
        EOR #$FF        ; complement the bits
        STA BIN
        CLC
        ADC #1         ; add one with possible carry
        STA BIN
        LDA BINH
        ADC #0
        STA BINH
        LDA #'-'
        JSR PrintChar
@plus:
        JSR BINBCD16
        LDA #0
        STA LZ
        STA LAST
        LDA BCD+2
        JSR PrintByteLZ
        LDA BCD+1
        JSR PrintByteLZ
        LDA #1                  ; no leading zero suppression for last digit
        STA LAST
        LDA BCD
        JSR PrintByteLZ
        JSR PrintCR
        JMP MainLoop

; Run at address
DoRun:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for address
        STX SL          ; store address
        STY SH
        JMP (SL)        ; jump to address

; Copy Memory
DoCopy:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for start address
        STX SL          ; store address
        STY SH
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for end address
        STX EL          ; store address
        STY EH
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for destination address
        STX DL          ; store address
        STY DH
        JSR PrintCR

; Check that start address < end address
        LDA SH
        CMP EH
        BCC @okay1
        BNE @invalid1
        LDA SL
        CMP EL
        BCC @okay1
@invalid1:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        JMP MainLoop

; Check that start address < dest address to avoid overlapping memory issues

@okay1:
        LDA SH
        CMP DH
        BCC @okay2
        BNE @invalid2
        LDA SL
        CMP DL
        BCC @okay2
@invalid2:
        LDX #<OverlappingRange
        LDY #>OverlappingRange
        JSR PrintString
        JMP MainLoop

@okay2:
        LDY #0
@copy:  LDA (SL),Y              ; copy from source
        STA (DL),Y              ; to destination

        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        JMP MainLoop            ; done
@NotDone:
        LDA SL                  ; increment start address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry1
        INC SH
@NoCarry1:

        LDA DL                  ; increment destination address
        CLC
        ADC #1
        STA DL
        BCC @NoCarry2
        INC DH
@NoCarry2:
        JMP @copy

; Search Memory
DoSearch:
        JSR PrintChar   ; echo command
        JSR PrintSpace
        JSR GetAddress  ; get start address
        STX SL
        STY SH
        JSR PrintSpace
        JSR GetAddress  ; get end address
        STX EL
        STY EH
        JSR PrintSpace
        JSR GetByte   ; Get data
        STA DA
        JSR PrintCR
; Check that start address < end address
        LDA SH
        CMP EH
        BCC @okay
        BNE @invalid
        LDA SL
        CMP EL
        BCC @okay
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        JMP MainLoop
@okay:
        LDY #0
@search:
        LDA DA
        CMP (SL),Y              ; compare with memory data
        BEQ @Match              ; found match
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        LDX #<NotFound
        LDY #>NotFound
        JSR PrintString
        JMP MainLoop            ; done
@NotDone:
        LDA SL                  ; increment address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry
        INC SH
@NoCarry:
        JMP @search
@Match:
        LDX #<Found
        LDY #>Found
        JSR PrintString
        LDX SL
        LDY SH
        JSR PrintAddress
        JSR PrintCR
        JMP MainLoop            ; done

; Verify Memory
DoVerify:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for start address
        STX SL          ; store address
        STY SH
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for end address
        STX EL          ; store address
        STY EH
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for destination address
        STX DL          ; store address
        STY DH
        JSR PrintCR

; Check that start address < end address
        LDA SH
        CMP EH
        BCC @okay
        BNE @invalid
        LDA SL
        CMP EL
        BCC @okay
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        JMP MainLoop
@okay:
        LDY #0
@verify:
        LDA (SL),Y              ; compare source
        CMP (DL),Y              ; to destination
        BEQ @match
        LDX #<MismatchString    ; report mismatch
        LDY #>MismatchString
        JSR PrintString
        LDX SL
        LDY SH
        JSR PrintAddress
        LDA #':'
        JSR PrintChar
        JSR PrintSpace
        LDY #0
        LDA (SL),Y
        JSR PrintByte
        JSR PrintSpace
        LDX DL
        LDY DH
        JSR PrintAddress
        LDA #':'
        JSR PrintChar
        JSR PrintSpace
        LDY #0
        LDA (DL),Y
        JSR PrintByte
        JSR PrintCR
@match: LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        JMP MainLoop            ; done
@NotDone:
        LDA SL                  ; increment start address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry1
        INC SH
@NoCarry1:
        LDA DL                  ; increment destination address
        CLC
        ADC #1
        STA DL
        BCC @NoCarry2
        INC DH
@NoCarry2:
        JMP @verify

; Dump Memory
DoDump:
; echo 'D' and space, wait for start address
        JSR PrintChar
        JSR PrintSpace
        JSR GetAddress  ; Get start address
        STX SL
        STY SH
@line:  JSR PrintCR
        LDX #0
@loop:  JSR DumpLine    ; display line of output
        LDA SL          ; add 8 to start address
        CLC
        ADC #8
        STA SL
        BCC @NoCarry
        INC SH
@NoCarry:
        INX
        CPX #23 ; display 23 lines
        BNE @loop
        LDX #<ContinueString
        LDY #>ContinueString
        JSR PrintString
@SpaceOrEscape:
        JSR GetKey
        CMP #' '
        BEQ @line
        CMP #ESC
        BNE @SpaceOrEscape
        JSR PrintCR
        JMP MainLoop

; Memory fill command
DoFill:
        JSR PrintChar   ; echo command
        JSR PrintSpace
        JSR GetAddress  ; get start address
        STX SL
        STY SH
        JSR PrintSpace
        JSR GetAddress  ; get end address
        STX EL
        STY EH
        JSR PrintSpace
        JSR GetByte   ; Get data
        STA DA
        JSR PrintCR
; Check that start address < end address
        LDA SH
        CMP EH
        BCC @okay
        BNE @invalid
        LDA SL
        CMP EL
        BCC @okay
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        JMP MainLoop
@okay:
        LDY #0
@fill:  LDA DA
        STA (SL),Y              ; store data
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        JMP MainLoop            ; done
@NotDone:
        LDA SL                  ; increment address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry
        INC SH
@NoCarry:
        JMP @fill

; -------------------- Utility Functions --------------------

; Generate one line of output for the dump command.
; Displays 8 bytes of memory
; Starting address in SL,SH.
; Registers changed: None
DumpLine:
        PHA
        TXA
        PHA
        TYA
        PHA
        LDX SL
        LDY SH
        JSR PrintAddress        ; Display address
        JSR PrintSpace
        LDY #0
@loop1: LDA (SL),Y              ; Display hex
        JSR PrintByte
        JSR PrintSpace
        INY
        CPY #8
        BNE @loop1
        JSR PrintSpace
        LDY #0
@loop2: LDA (SL),Y              ; Display ASCII
        JSR PrintAscii
        INY
        CPY #8
        BNE @loop2
        JSR PrintCR
        PLA
        TAY
        PLA
        TAX
        PLA
        RTS

; Output a character
; Calls Woz monitor ECHO routine
; Registers changed: none
PrintChar:
        JSR ECHO
        RTS

; Gets a hex digit (0-9,A-F). Echoes character as typed.
; ESC key cancels command and goes back to command loop.
; Ignors invalid characters. Returns binary value in A
; Registers changed: A
GetHex:
        JSR GetKey
        CMP #ESC        ; ESC key?
        BNE @next
        JSR PrintCR
        PLA             ; pop return address on stack
        PLA
        JMP MainLoop    ; Abort command
@next:
        CMP #'0'
        BMI GetHex      ; Invalid, ignore and try again
        CMP #'9'+1
        BMI @Digit
        CMP #'A'
        BMI GetHex      ; Invalid, ignore and try again
        CMP #'F'+1
        BMI @Letter
        JMP GetHex      ; Invalid, ignore and try again
@Digit:
        JSR PrintChar   ; echo
        SEC
        SBC #'0'        ; convert to value
        RTS
@Letter:
        JSR PrintChar   ; echo
        SEC
        SBC #'A'-10     ; convert to value
        RTS

; Get Byte as 2 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns byte in A
; Registers changed: A
GetByte:
        JSR GetHex
        ASL
        ASL
        ASL
        ASL
        STA T1 ; Store first nybble
        JSR GetHex
        CLC
        ADC T1; Add second nybble
        RTS

; Get Address as 4 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns address in X (low), Y (high)
; Registers changed: X, Y
GetAddress:
        PHA
        JSR GetByte
        TAY
        JSR GetByte
        TAX
        PLA
        RTS

; Print 16-bit address in hex
; Pass byte in X (low) and Y (high)
; Registers changed: None
PrintAddress:
        PHA
        TYA
        JSR PRBYTE
        TXA
        JSR PRBYTE
        PLA
        RTS

; Print byte in hex
; Pass byte in A
; Registers changed: None
PrintByte:
        JSR PRBYTE
        RTS

; Print byte in BCD with leading zero suppression
; Pass byte in A
; Registers changed: None
; Call first time with LZ cleared
PrintByteLZ:
; Check for special case: number is $00, LZ is 0, LAST is 1
; Last 0 should not be suppressed since it is the final one in $0000
        CMP #$00
        BNE @normal
        PHA
        LDA LZ
        BNE @pull
        LDA LAST
        BEQ @pull
        LDA #'0'
        JSR PrintChar
        PLA
        RTS
@pull: PLA
@normal:
        PHA             ; save for lower nybble
        AND #$F0        ; mask out upper nybble
        LSR             ; shift into lower nybble
        LSR
        LSR
        LSR
        CLC
        ADC #'0'
        JSR PrintCharLZ
        PLA             ; restore value
        AND #$0F        ; mask out lower nybble
        CLC
        ADC #'0'
        JSR PrintCharLZ
        RTS

; Print character but suppress 0 if LZ it not set.
; Sets LZ when non-zero printed.
; Pass char in A
PrintCharLZ:
        CMP #'0'        ; is it 0?
        BNE @notzero    ; if not, print it normally
        PHA
        LDA LZ          ; is LZ zero?
        BNE @print
        PLA
        RTS             ; suppress leading zero
@print: PLA
        JSR PrintChar
        RTS
@notzero:
        JSR PrintChar   ; print it
        LDA #1          ; set LZ to 1
        STA LZ
        RTS

; Print byte as ASCII character or "."
; Pass character in A.
; Registers changed: None
PrintAscii:
        CMP #$20 ; first printable character (space)
        BMI NotAscii
        CMP #$7E+1 ; last printable character (~)
        BPL NotAscii
        JSR PrintChar
        RTS
NotAscii:
        PHA     ; save A
        LDA #'.'
        JSR PrintChar
        PLA     ; restore A
        RTS

; Print a carriage return
; Registers changed: None
PrintCR: PHA
         LDA #CR
         JSR PrintChar
         PLA
         RTS

; Print a space
; Registers changed: None
PrintSpace: PHA
         LDA #SP
         JSR PrintChar
         PLA
         RTS

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated with a null.
; Cannot be longer than 256 characters.
; Registers changed: A, Y
;
PrintString:
        STX T1
        STY T1+1
        LDY #0
@loop:  LDA (T1),Y
        BEQ done
        JSR PrintChar
        INY
        BNE @loop       ; if doesn't branch, string is too long
done:   RTS

; Below came from
; http://www.6502.org/source/integers/hex2dec-more.htm
; Convert an 16 bit binary value to BCD
;
; This function converts a 16 bit binary value into a 24 bit BCD. It
; works by transferring one bit a time from the source and adding it
; into a BCD value that is being doubled on each iteration. As all the
; arithmetic is being done in BCD the result is a binary to decimal
; conversion. All conversions take 915 clock cycles.
;
; See BINBCD8 for more details of its operation.
;
; Andrew Jacobs, 28-Feb-2004
BINBCD16:    SED        ; Switch to decimal mode
        LDA #0          ; Ensure the result is clear
        STA BCD+0
        STA BCD+1
        STA BCD+2
        LDX #16        ; The number of source bits
CNVBIT: ASL BIN+0    ; Shift out one bit
        ROL BIN+1
        LDA BCD+0    ; And add into result
        ADC BCD+0
        STA BCD+0
        LDA BCD+1    ; propagating any carry
        ADC BCD+1
        STA BCD+1
        LDA BCD+2    ; ... thru whole result
        ADC BCD+2
        STA BCD+2
        DEX        ; And repeat for next bit
        BNE CNVBIT
        CLD        ; Back to binary
        RTS        ; All Done.

PRBYTE: PHA
        LSR
        LSR
        LSR
        LSR
        JSR PRHEX
        PLA
PRHEX:  AND #$0F
        ORA #$30
        CMP #$3A
        BCC ECHO
        ADC #$06

; Send character in A out serial port
ECHO:
        PHA
        LDA #$10
TXFULL: BIT STATUSREG ; wait for TDRE bit = 1
        BEQ TXFULL
        PLA
        STA TXDATA
        RTS

; Read character from serial port and return in A
GetKey:
        LDA #$08
RXFULL: BIT STATUSREG
        BEQ RXFULL
        LDA RXDATA
        AND #%01111111
        RTS

; Strings

WelcomeMessage:
        .byte CR,CR,"JMON MONITOR V0.2 BY JEFF TRANTER",CR,0

PromptString:
        .asciiz "? "

InvalidCommand:
        .byte "INVALID COMMAND. TYPE '?' FOR HELP",CR,$00

; Help string. Split in two because >255 characters
HelpString1:
        .byte "COMMANDS:",CR
        .byte "DUMP:      D <START>",CR
        .byte "FILL:      F <START> <END> <DATA>",CR
        .byte "COPY:      C <START> <END> <DEST>",CR
        .byte "VERIFY:    V <START> <END> <DEST>",CR
        .byte "SEARCH:    S <START> <END> <DATA>",CR
        .byte "HEX TO DEC H <ADDRESS>",CR
        .byte "RUN:       R <ADDRESS>",CR
        .byte "WOZ MON:   $",CR
        .byte "MINI MON:  K",CR
        .byte "ASSEMBLER: A",CR,0
HelpString2:
        .byte "BASIC:     B",CR
        .byte "HELP:      ?",CR,0

ContinueString:
        .asciiz "  <SPACE> TO CONTINUE, <ESC> TO STOP"

InvalidRange:
        .byte "ERROR: START MUST BE < END",CR,0

OverlappingRange:
        .byte "ERROR: START MUST BE < DEST",CR,0
NotFound:
        .byte "NOT FOUND",CR,0
Found:
        .asciiz "FOUND AT: "

MismatchString:
        .asciiz "MISMATCH: "
