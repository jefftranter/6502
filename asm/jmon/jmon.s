; JMON - Simple Monitor Program
;
; Fills some gaps missing from Woz monitor.
;
; Jeff Tranter <tranter@pobox.com>
;
; TODO:
; - use CPU type for dissasembly
; - add support for 65816 disassembly
; - implement mini assembler?

; Revision History
; Version Date         Comments
; 0.0     19-Feb-2012  First version started
; 0.1     21-Feb-2012  Initial release
; 0.2     10-Mar-2012  Added search command. Avoid endless loop in PrintString if string too long.
; 0.3     28-Mar-2012  Added Unassemble command.
; 0.4     30-Mar-2012  Added Test and Breakpoint commands.
; 0.5     08-May-2012  Added write delay command for slow EEPROM access
; 0.6     15-May-2012  Support overlapping addresses in copy command
; 0.7     16-May-2012  Prompt whether to continue when Verify detects mismatch or Search finds match.
; 0.8     17-May-2012  Search and Fill commands now use 16 bit patterns.
; 0.9     22-May-2012  Added M command to call CFFA1 menu.
; 0.91    23-May-2012  Now uses smarter "option picker" for commands.
; 0.92    03-Jun-2012  Added ":" command
; 0.93    06-Jun-2012  Added Register command. Former Run command is now Go.
; 0.94    17-Jun-2012  Display error in break handler if interrupt occurred.
;                      Fill command accepts variable length pattern.
;                      Search command accepts variable length pattern.
; 0.95    18-Jun-2012  Use constants for keyboard registers.
;                      Removed reliance on Woz Mon routines.
;                      Go command now does a JSR (or equivalent) so called program can return.
;                      Added = command for simple hex math calculations (add/subtract).
; 0.96    21-Jun-2012  Some refactoring to improve common code.
;                      Improvements to comments.
;                      Added new L command to clear screen.
;                      Moved most variables out of page zero.
;                      Added new E command for ACI cassette interface (untested).
;                      Fill, Search, and ":" commands accept characters as well as hex values.
;                      Type ' to enter a character.
; 0.97   01-Jul-2012   Implemented new options command.

; Constants
  CR      = $0D                 ; Carriage Return
  SP      = $20                 ; Space
  ESC     = $1B                 ; Escape

; Hardware addresses
  KBD     = $D010               ;  PIA.A keyboard input
  KBDCR   = $D011               ;  PIA.A keyboard control register
  DSP     = $D012               ;  PIA.B display output register

; Page Zero locations
; Note: Woz Mon uses $24 through $2B and $0200 through $027F.
; Krusader uses $F8, $F9, $FE, $FF.
; Mini-monitor uses $0F, $10, $11, $E0-$E8, $F0-$F6.
  T1      = $30                 ; Temp variable 1 (2 bytes)
  SL      = $32                 ; Start address low byte
  SH      = $33                 ; Start address high byte
  EL      = $34                 ; End address low byte
  EH      = $35                 ; End address high byte
  DL      = $36                 ; Destination address low byte
  DH      = $37                 ; Destination address high byte
  ADDR    = $38                 ; Instruction address, 2 bytes (low/high)
  ADDRS   = $3A                 ; Memory test - 2 bytes - address of memory
  TEST_PATRN = $3C              ; Memory test - 1 byte - current test pattern
  PASSES  = $3D                 ; Memory test - number of passes
  VECTOR  = $3E                 ; Holds adddress of IRQ/BREAK entry point (2 bytes)
  BPA     = $40                 ; Address of breakpoint (2 bytes * 4 breakpoints)

; Non page zero locations
  IN      = $0200               ; Buffer from $0200 through $027F (shared with Woz Mon)

; External Routines
  BASIC   = $E000               ; BASIC
  KRUSADER = $F000              ; Krusader Assembler
  MINIMON = $FE14               ; Mini monitor entry point (valid for Krusader 6502 version 1.3)
  WOZMON  = $FF00               ; Woz monitor entry point
  BRKVECTOR = $FFFE             ; Break/interrupt vector (2 bytes)   
  MENU    = $9006               ; CFFA1 menu entry point
  ACI     = $C100               ; ACI (Apple Cassette Interface) firmware entry point

; Start address. $0280 works well for running out of RAM. Use start address of $A000 for Multi I/0 Board EEPROM
; .org $A000
  .org $0280

; JMON Entry point
  .export JMON
JMON:
        JMP Start

; Non-Page Zero Variables
T2:       .res 1                ; Temp variable 2
RETOK:    .res 1                ; Sets whether <Return> key is accepted in some input routines
BIN:      .res 1                ; Holds binary value low byte
BINH:     .res 1                ; Holds binary value high byte
BCD:      .res 3                ; Holds BCD decimal number (3 bytes)
LZ:       .res 1                ; Boolean for leading zero suppression
LAST:     .res 1                ; Boolean for leading zero suppression / indicates last byte
OPCODE:   .res 1                ; Instruction opcode
OP:       .res 1                ; Instruction type OP_*
AM:       .res 1                ; Addressing mode AM_*
LEN:      .res 1                ; Instruction length
REL:      .res 2                ; Relative addressing branch offset (2 bytes)
DEST:     .res 2                ; Relative address destination address (2 bytes)
START:    .res 2                ; Memory test- user entered start of memory range. Min is 8 (2 bytes)
END:      .res 2                ; Memory test - user entered end of memory range (2 bytes)
BPD:      .res 4                ; Instruction at breakpoint (1 byte * 4 breakpoints)
SAVE_A:   .res 1                ; Holds saved values of registers
SAVE_X:   .res 1                ; "
SAVE_Y:   .res 1                ; "
SAVE_S:   .res 1                ; "
SAVE_P:   .res 1                ; "
SAVE_PC:  .res 2                ; Holds PC while in BRK handler (2 bytes)
CHAROK:   .res 1                ; Set to 1 if okay to enter characters prefixed by '
CHARMODE: .res 1                ; Set if currently entering in character (ASCII) mode
OWDELAY:   .res 1               ; Delay value when writing (defaults to zero)
OUPPER:   .res 1                ; Set to $FF when only uppercase output is is desired.
OHIGHASCII: .res 1              ; Set to $FF when characters should have high bit set
OCPU:      .res 1               ; CPU type for disassembly

; Save values of registers
Start:
        PHP
        STA SAVE_A
        STX SAVE_X
        STY SAVE_Y
        PLA
        STA SAVE_P
        TSX
        STX SAVE_S

; Initialize some things just in case

        CLD                     ; clear decimal mode
        CLI                     ; clear interrupt disable
        LDX #$80                ; initialize stack pointer to $0180
        TXS                     ; so we are less likely to clobber BRK vector at $0100
        LDA #0
        STA OWDELAY             ; initialize write delay to zero
        STA RETOK               ; Don't accept <Return> by default
        STA CHAROK              ; Don't accept character input by default
        STA CHARMODE            ; Not currently in char input mode
        STA OHIGHASCII          ; Characters should not have high bit set
        LDA #$FF                ; Default to uppercase only mode
        STA OUPPER
        JSR BPSETUP             ; initialization for breakpoints
        JSR ClearScreen

; Display Welcome message
        LDX #<WelcomeMessage
        LDY #>WelcomeMessage
        JSR PrintString

MainLoop:
; Display prompt
        LDX #<PromptString
        LDY #>PromptString
        JSR PrintString

; Get first character of command
        JSR GetKey

; Call option picker to run appropriate command
        JSR OPICK
        JMP MainLoop

; Invalid command
Invalid:
        LDX #<InvalidCommand
        LDY #>InvalidCommand
        JSR PrintString
        RTS

; Display help
Help:
        JSR PrintChar ; echo command
        LDX #<WelcomeMessage
        LDY #>WelcomeMessage
        JSR PrintString
        LDX #<HelpString
        LDY #>HelpString
        JSR PrintString
        RTS

; Call CFFA1 flash interface menu
; The documented way to check for a CFFA1 is to check for two ID bytes.
; The documentation says it is addresses $AFFC and $AFFD but the firmware
; actually uses addresses $AFDC and $AFDD. Further, my CFFA1 board did
; not have these locations programmed even though firmware on CD-ROM did.
; I manually wrote these bytes to my EEPROM.

CFFA1:
        LDA $AFDC               ; First CFFA1 ID byte
        CMP #$CF                ; Should contain $CF
        BNE NoCFFA1
        LDA $AFDD               ; First CFFA1 ID byte
        CMP #$FA                ; Should contain $FA
        BNE NoCFFA1
        JSR MENU                ; Jump to CFFA1 menu, will return when done.
        RTS
NoCFFA1:
        LDX #<NoCFFA1String     ; Display error that no CFFA1 is present.
        LDY #>NoCFFA1String
        JSR PrintString
        RTS

; Call ACI (Apple Cassette Interface) firmware
; First check for the presence of the card by looking for the first two byes of the ROM firmware.

ACIFW:
        LDA ACI                 ; First firmware byte
        CMP #$A9                ; Should contain $A9
        BNE NoACI
        LDA ACI+1               ; Second firmware byte
        CMP #$AA                ; Should contain $AA
        BNE NoACI
        JMP ACI                 ; Jump to ACI firmware, unfortunately jumps to Woz Mon when done rather than returning here.
NoACI:
        LDX #<NoACIString       ; Display error that no ACI is present.
        LDY #>NoACIString
        JSR PrintString
        RTS

; Go to Woz Monitor
Monitor:
        JMP WOZMON

; Go to Krusader Mini Monitor
MiniMonitor:
        JMP MINIMON

; Go to Krusader Assembler
Assembler:
        JMP KRUSADER

; Go to BASIC
Basic:  JMP BASIC

; Handle breakpoint
; B ?                    <- list status of all breakpoints
; B <n> <address>        <- set breakpoint number <n> at address <address>
; B <n> 0000             <- remove breakpoint <n>
; <n> is 0 through 3.
Breakpoint:
        JSR PrintChar           ; echo command
        JSR PrintSpace          ; print space
IGN:    JSR GetKey              ; get breakpoint number
        CMP #'?'                ; ? lists breakpoints
        BEQ LISTB
        CMP #ESC                ; <Escape> cancels
        BNE Num
        JSR PrintCR
        RTS
Num:    CMP #'0'                ; is it 0 through 3?
        BMI IGN                 ; Invalid, ignore and try again
        CMP #'3'+1
        BMI VALIDBP
        JMP IGN
VALIDBP:
        JSR PrintChar           ; echo number
        SEC
        SBC #'0'                ; convert to number
        PHA                     ; save it
        JSR PrintSpace          ; print space
        JSR GetAddress          ; prompt for address
        JSR PrintCR
        PLA                     ; restore BP number
        JSR BPADD
        RTS
LISTB:  JSR PrintCR
        JSR BPLIST
        RTS

; Hex to decimal conversion command
Hex:
        JSR PrintChar           ; echo command
        JSR PrintSpace          ; print space
        JSR GetAddress          ; prompt for address
        STX BIN                 ; store address
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
        RTS

; Run at address
Go:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for address
        STX SL          ; store address
        STY SH

; Restore saved values of registers

        LDX SAVE_S      ; Restore stack pointer
        TXS
        LDA #>(@Return-1) ; Push return address-1 on the stack so an RTS in the called code will return here.
        PHA
        LDA #<(@Return-1)
        PHA
        LDA SAVE_P
        PHA             ; Push P
        LDY SAVE_Y      ; Restore Y
        LDX SAVE_X      ; Restore X
        LDA SAVE_A      ; Restore A
        PLP             ; Restore P
        JMP (SL)        ; jump to address
@Return:

; The stack pointer was changed above and who knows what else, so we
; can't RTS from the caller of this routine. Instead we jump directly
; to the start of JMON.

        JMP JMON

; Copy Memory
Copy:
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

; Check that start address <= end address
        LDA SH
        CMP EH
        BCC @okay1
        BEQ @okay1
        BNE @invalid1
        LDA SL
        CMP EL
        BCC @okay1
        BEQ @okay1
@invalid1:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        RTS

; Separate copy up and down routines to handle avoid overlapping memory

@okay1:
        LDA SH
        CMP DH
        BCC @okayUp             ; copy up
        BNE @okayDown           ; copy down
        LDA SL
        CMP DL
        BCC @okayUp
        BCS @okayDown

@okayUp:
        LDY #0
@copyUp:
        LDA (SL),Y              ; copy from source
        STA (DL),Y              ; to destination
        JSR DELAY               ; delay after writing to EEPROM
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone1
        LDA SL
        CMP EL
        BNE @NotDone
        RTS                     ; done
@NotDone1:
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
        JMP @copyUp

@okayDown:
        LDA EL                 ; Calculate length = End - Start
        SEC
        SBC SL
        STA T1
        LDA EH
        SBC SH
        STA T2
        LDA DL                 ; add length to Destination
        CLC
        ADC T1
        STA DL
        LDA DH
        ADC T2
        STA DH
        LDY #0
@copyDown:
        LDA (EL),Y              ; copy from source
        STA (DL),Y              ; to destination
        JSR DELAY               ; delay after writing to EEPROM
        LDA EH                  ; reached end yet?
        CMP SH
        BNE @NotDone
        LDA EL
        CMP SL
        BNE @NotDone
        RTS                     ; done
@NotDone:
        LDA EL                  ; decrement end address
        SEC
        SBC #1
        STA EL
        BCS @NoBorrow1
        DEC EH
@NoBorrow1:
        LDA DL                  ; decrement destination address
        SEC
        SBC #1
        STA DL
        BCS @NoBorrow2
        DEC DH
@NoBorrow2:
        JMP @copyDown

; Search Memory
Search:
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
        JSR GetHexBytes         ; Get search pattern
        JSR PrintCR
        LDA IN                  ; If length of pattern is zero, return
        BNE @lenokay
        RTS

; Check that start address <= end address
@lenokay:
        LDA SH
        CMP EH
        BCC @StartSearch
        BEQ @StartSearch
        BNE @invalid
        LDA SL
        CMP EL
        BCC @StartSearch
        BEQ @StartSearch
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        RTS

@StartSearch:
        LDX #0                  ; Index into fill pattern
@search:
        LDY #0
        LDA IN+1,X              ; Get byte of pattern data
        CMP (SL),Y              ; compare with memory data
        BNE @NoMatch
        INX
        CPX IN                  ; End of pattern reached?
        BEQ @Match              ; If so, found match
        BNE @PartialMatch                
@NoMatch:
        STX T1                  ; Subtract X from SL,SH
        SEC
        LDA SL
        SBC T1
        STA SL
        LDA SH
        SBC #0
        STA SH
@Continue:
        LDX #0                  ; Reset search to end of pattern
@PartialMatch:
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        LDX #<NotFound
        LDY #>NotFound
        JSR PrintString
        RTS                     ; done
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
        DEC IN                  ; Calculate start address as SL,SH minus (IN - 1)
        LDA SL
        SEC
        SBC IN
        STA SL
        LDA SH
        SBC #0                  ; Includes possible carry
        STA SH
        INC IN
        LDX #<Found
        LDY #>Found
        JSR PrintString
        LDX SL
        LDY SH
        JSR PrintAddress
        JSR PrintCR
        JSR PromptToContinue
        BCC @Continue
        RTS             ; done

; Verify Memory
Verify:
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

; Check that start address <= end address
        LDA SH
        CMP EH
        BCC @verify
        BEQ @verify
        BNE @invalid
        LDA SL
        CMP EL
        BCC @verify
        BEQ @verify
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        RTS
@verify:
        LDY #0
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
        JSR PromptToContinue
        BCS @Done               ; ESC pressed, return
@match: LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
@Done:
        RTS                     ; done
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
Dump:
; echo 'D' and space, wait for start address
        JSR PrintChar
        JSR PrintSpace
        JSR GetAddress          ; Get start address
        STX SL
        STY SH
@line:  JSR PrintCR
        LDX #0
@loop:  JSR DumpLine            ; display line of output
        LDA SL                  ; add 8 to start address
        CLC
        ADC #8
        STA SL
        BCC @NoCarry
        INC SH
@NoCarry:
        INX
        CPX #23                 ; display 23 lines
        BNE @loop
        JSR PromptToContinue
        BCC @line
        RTS

; Unassemble Memory
Unassemble:
; echo 'U' and space, wait for start address
        JSR PrintChar
        JSR PrintSpace
        JSR GetAddress          ; Get start address
        STX ADDR
        STY ADDR+1
@line:  JSR PrintCR
        LDA #23
@loop:  PHA
        JSR DISASM              ; display line of output
        PLA
        SEC
        SBC #1
        BNE @loop
        JSR PromptToContinue
        BCC @line
        RTS

; Test Memory
Test:
        JSR PrintChar           ; echo command
        JSR PrintSpace
        JSR GetAddress          ; get start address
        STX START
        STY START+1
        JSR PrintSpace
        JSR GetAddress          ; get end address
        STX END
        STY END+1
        JSR PrintCR
        LDX #<TestString1
        LDY #>TestString1
        JSR PrintString
        LDX START
        LDY START+1
        JSR PrintAddress
        LDX #<TestString2
        LDY #>TestString2
        JSR PrintString
        LDX END
        LDY END+1
        JSR PrintAddress
        LDX #<TestString3
        LDY #>TestString3
        JSR PrintString
        JSR MEM_TEST
        RTS

; Memory fill command
Fill:
        JSR PrintChar           ; echo command
        JSR PrintSpace
        JSR GetAddress          ; get start address
        STX SL
        STY SH
        JSR PrintSpace
        JSR GetAddress          ; get end address
        STX EL
        STY EH
        JSR PrintSpace
        JSR GetHexBytes         ; Get fill pattern
        JSR PrintCR
        LDA IN                  ; If length of pattern is zero, return
        BNE @lenokay
        RTS

; Check that start address <= end address
@lenokay:
        LDA SH
        CMP EH
        BCC @fill
        BEQ @fill
        BNE @invalid
        LDA SL
        CMP EL
        BCC @fill
        BEQ @fill
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        RTS

@fill:
        LDY #0
        LDX #0                  ; Index into fill pattern
@dofill:
        LDA IN+1,X              ; Get next byte of fill pattern
        STA (SL),Y              ; store data (first byte)
        JSR DELAY               ; delay after writing to EEPROM
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone
        LDA SL
        CMP EL
        BNE @NotDone
        RTS                     ; done
@NotDone:
        LDA SL                  ; increment address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry
        INC SH
@NoCarry:
        INX                     ; increment index into pattern
        CPX IN                  ; end of pattern reached?
        BNE @dofill             ; if not, go back
        LDX #0                  ; Otherwise go back to start of pattern
        JMP @dofill
        
; Do setup so we can support breakpoints
BPSETUP:
        LDA BRKVECTOR           ; get address of BRK vector
        STA VECTOR              ; and save in page zero
        LDA BRKVECTOR+1
        STA VECTOR+1
        LDA #$4C                ; JMP instruction
        LDY #0          
        STA (VECTOR),Y          ; store at IRQ/BRK vector
        CMP (VECTOR),Y          ; if we don't read back what we wrote
        BNE VNOTINRAM           ; then vector address is not writable (user may have put it in ROM)
        LDA #<BRKHANDLER        ; handler address low byte
        INY
        STA (VECTOR),Y          ; write it after JMP
        LDA #>BRKHANDLER        ; handler address low byte
        INY
        STA (VECTOR),Y          ; write it after JMP
        LDA #0                  ; Mark all breakpoints as cleared (BPA and BPD set to 0)
        LDX #0
        LDY #0
CLEAR:
        STA BPA,Y
        STA BPA+1,Y
        STA BPD,X
        INY
        INY
        INX
        CPX #4
        BNE CLEAR
        RTS
VNOTINRAM:
        LDX #<VNotRAMString
        LDY #>VNotRAMString
        JSR PrintString
        RTS
BNOTINRAM:
        LDX #<BNotRAMString
        LDY #>BNotRAMString
        JSR PrintString
        RTS

; List breakpoints, e.g.
; "BREAKPOINT n AT $nnnn"
BPLIST:
        LDX #0
LIST:
        TXA
        PHA
        LDX #<KnownBPString1
        LDY #>KnownBPString1
        JSR PrintString
        PLA
        PHA
        LSR A                   ; divide by 2
        JSR PRHEX
        LDX #<KnownBPString2
        LDY #>KnownBPString2
        JSR PrintString
        PLA
        PHA
        TAX
        LDA BPA,X
        INX
        LDY BPA,X
        TAX
        JSR PrintAddress
        JSR PrintCR
        PLA
        TAX
        INX
        INX
        CPX #8
        BNE LIST
        RTS

; Return 1 in A if breakpoint number A exists, otherwise return 0.
BPEXISTS:
        ASL A                   ; need to multiply by 2 to get offset in array
        TAX
        LDA BPA,X
        BNE EXISTS
        LDA BPA+1,X
        BNE EXISTS
        LDA #0
        RTS
EXISTS:
        LDA #1
        RTS

; Add breakpoint number A at address in X,Y
BPADD:
        STX T1
        STY T2
        PHA
        JSR BPEXISTS            ; if breakpoint already exists, remove it first
        BEQ ADDIT
        PLA
        PHA
        JSR BPREMOVE            ; remove it
ADDIT:
        PLA
        TAY
        ASL A                   ; need to multiply by 2 to get offset in array
        TAX
        LDA T1
        STA BPA,X               ; save address of breakpoint
        LDA T2
        STA BPA+1,X
        LDA (BPA,X)             ; get instruction at breakpoint address
        STA BPD,Y               ; save it
        LDA #0                  ; BRK instruction
        STA (BPA,X)             ; write breakpoint over code
        CMP (BPA,X)             ; If we don't read back what we wrote
        BNE BNOTINRAM           ; then address is not writable (user may have put it in ROM)
        RTS

; Remove breakpoint number A
BPREMOVE:
        PHA
        JSR BPEXISTS
        BNE OK  
        LDX #<NOBPString
        LDY #>NOBPString
        JSR PrintString
        PLA
        RTS
OK:
        PLA
        TAY
        ASL A                   ; multiply by 2 because table entries are two bytes
        TAX
        LDA BPD,Y               ; get original instruction
        STA (BPA,X)             ; restore instruction at breakpoint address
        LDA #0                  ; set BPA to address$0000 to clear breakpoint
        STA BPA,X
        STA BPA+1,X
        STA BPD,Y               ; and clear BPD
        RTS

; Breakpoint handler
BRKHANDLER:
        STA SAVE_A              ; save registers
        STX SAVE_X
        STY SAVE_Y
        PLA                     ; P is on stack
        STA SAVE_P
        PHA                     ; put P back on stack
        LDA  #%00010000         ; position of B bit
        BIT  SAVE_P             ; is B bit set, indicating BRK and not IRQ?
        BNE  BREAK              ; If so, got to break handler
        JSR  PrintCR            ; Otherwise print message that we got an interrupt
        LDX  #<IntString        
        LDY  #>IntString
        JSR  PrintString
        LDY  SAVE_Y
        LDX  SAVE_X             ; Restore registers and return from interrupt
        LDA  SAVE_A
        RTI
BREAK:
        TSX                     ; get stack pointer
        SEC                     ; subtract 2 from return address to get actual instruction address
        LDA $0102,X
        SBC #2
        STA $0102,X             ; put original instruction address back on stack
        STA SAVE_PC             ; also save it for later reference
        LDA $0103,X
        SBC #0
        STA $0103,X
        STA SAVE_PC+1
        LDX #0
CHECKADDR:
        LDA SAVE_PC             ; see if PC matches address of a breakpoint
        CMP BPA,X
        BNE TRYNEXT
        LDA SAVE_PC+1
        CMP BPA+1,X
        BEQ MATCHES
TRYNEXT:
        INX
        INX
        CPX #8                  ; last breakpoint reached
        BNE CHECKADDR
UNKNOWN:
        JSR PrintCR
        LDX #<UnknownBPString
        LDY #>UnknownBPString
        JSR PrintString
        LDX SAVE_PC
        LDY SAVE_PC+1
        JSR PrintAddress
        JMP RESTORE
MATCHES:
        TXA
        PHA
        JSR PrintCR
        LDX #<KnownBPString1
        LDY #>KnownBPString1
        JSR PrintString
        PLA                      ; get BP # x2
        PHA                      ; save it again
        LSR A                    ; divide by 2 to get BP number
        JSR PRHEX
        LDX #<KnownBPString2
        LDY #>KnownBPString2
        JSR PrintString
        LDX SAVE_PC
        LDY SAVE_PC+1
        JSR PrintAddress
        PLA
        LSR A
        JSR BPREMOVE
RESTORE:
        LDA SAVE_P              ; restore registers
        PHA
        LDA SAVE_A
        LDX SAVE_X
        LDY SAVE_Y
        PLP
        JMP MINIMON             ; go to the mini monitor

; Memory write command.
; Format:
; : <addr> <bb> <bb> ... <Enter> or <Esc> (up to 255 chars)
; eg:
; : A000 12 34 56 78
Memory:
        JSR PrintChar           ; Echo command
        JSR PrintCR
        JSR GetAddress          ; Get start address (ESC will exit)
        STX SL
        STY SH
        LDA #1
        STA CHAROK              ; Set flag to accept character input
writeLoop:
        JSR PrintSpace          ; Echo space
        JSR GetByte             ; Get data byte (ESC will exit)
        LDY #0
        STA (SL),Y              ; write data to address
        CMP (SL),Y
        BEQ Okay
        LDX #<ReadString        ; Display message that same data not written back
        LDY #>ReadString
        JSR PrintString
        LDY #0
        LDA (SL),Y
        JSR PrintByte
        JSR PrintSpace
Okay:
        CLC                     ; increment address
        LDA SL
        ADC #1
        STA SL
        BCC nocarry
        INC SH
nocarry:
        LDA #$07                ; Is address a multiple of 8?
        BIT SL
        BNE writeLoop           ; If not, keep getting data
        JSR PrintCR             ; Otherwise start new line
        LDX SL
        LDY SH
        JSR PrintAddress        ; Display current address
        JMP writeLoop           ; Input more data

; Register change command.
; Displays and sets values of registers
; Values are set when JMON is entered.
; Uses values with Go command.
;
; R A-D2 X-00 Y-04 S-01FE P-FF NVBDIZC
;   A-?? X-00 Y-00 S-0180 P-01
;
; Displays saved value of registers
; Prompts for new value for each register.
; <Esc> cancels at any time.

Registers:
        JSR PrintChar           ; Echo command
        JSR PrintSpace
        LDA #'A'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA SAVE_A
        JSR PrintByte
        JSR PrintSpace
        LDA #'X'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA SAVE_X
        JSR PrintByte
        JSR PrintSpace
        LDA #'Y'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA SAVE_Y
        JSR PrintByte
        JSR PrintSpace
        LDA #'S'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA #01
        JSR PrintByte
        LDA SAVE_S
        JSR PrintByte
        JSR PrintSpace
        LDA #'P'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA SAVE_P
        JSR PrintByte
        JSR PrintSpace
        JSR OUTP
        JSR PrintCR

        LDX #4
        JSR PrintSpaces
        LDA #'A'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        JSR GetByte
        STA SAVE_A
        JSR PrintSpace
        LDA #'X'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        JSR GetByte
        STA SAVE_X
        JSR PrintSpace
        LDA #'Y'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        JSR GetByte
        STA SAVE_Y
        JSR PrintSpace
        LDA #'S'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        LDA #$01
        JSR PrintByte
        JSR GetByte
        STA SAVE_S
        JSR PrintSpace
        LDA #'P'
        JSR PrintChar
        LDA #'-'
        JSR PrintChar
        JSR GetByte
        STA SAVE_P
        JSR PrintSpace
        JSR OUTP
        JSR PrintCR
        RTS

; Prompt user to change program options
Options:
        LDX #<OptionsString
        LDY #>OptionsString
        JSR PrintString
        LDX #<UppercaseString
        LDY #>UppercaseString
        JSR PrintString
@Retry:
        JSR GetKey
        CMP #ESC
        BEQ @Return
        CMP #'Y'
        BEQ @Yes
        CMP #'N'
        BEQ @No
        BNE @Retry
@Return:
        JSR PrintCR             ; new line
        RTS
@Yes:
        JSR PrintChar           ; echo command
        LDA #$FF
        STA OUPPER
        BNE @Next
@No:
        JSR PrintChar           ; echo command
        LDA #0
        STA OUPPER
@Next:
        JSR PrintCR             ; new line

; Add a delay after all writes to accomodate slow EEPROMs.
; Applies to COPY, FILL, and TEST commands.
; Depending on the manufacturer, anywhere from 0.5ms to 10ms may be needed.
; Value of $20 works well for me (approx 1.5ms delay with 2MHz clock).
; See routine WAIT for details.
        LDX #<WriteDelayString
        LDY #>WriteDelayString
        JSR PrintString
        JSR GetByte
        STA OWDELAY
        JSR PrintCR             ; new line

        LDX #<HighBitString
        LDY #>HighBitString
        JSR PrintString
@Retry1:
        JSR GetKey
        CMP #ESC
        BEQ @Return
        CMP #'Y'
        BEQ @Yes1
        CMP #'N'
        BEQ @No1
        BNE @Retry
@Yes1:
        JSR PrintChar           ; echo command
        LDA #$FF
        STA OHIGHASCII
        BNE @Next1
@No1:
        JSR PrintChar           ; echo command
        LDA #0
        STA OHIGHASCII
@Next1:
        JSR PrintCR             ; new line

        LDX #<CPUTypeString
        LDY #>CPUTypeString
        JSR PrintString
@Retry2:
        JSR GetKey
        CMP #ESC
        BEQ @Return
        CMP #'1'
        BEQ @Okay
        CMP #'2'
        BEQ @Okay
        CMP #'3'
        BEQ @Okay
        CMP #'4'
        BEQ @Okay
        BNE @Retry2
@Okay:
        JSR PrintChar           ; echo command
        AND #%00000011          ; Convert ASCII number to binary number
        STA OCPU
        JSR PrintCR             ; new line
        RTS

; Math command. Add or substract two 16-bit hex numbers.
; Format: = <ADDRESS> +/- <ADDRESS>
; e.g.
; = 1234 + 0077 = 12AB
; = FF00 - 0002 = FEFE
Math:
        JSR PrintChar           ; Echo command
        JSR PrintSpace
        JSR GetAddress          ; Get first number
        STX SL
        STY SH
        JSR PrintSpace
@PlusOrMinus:
        JSR GetKey
        CMP #'+'                ; Is it plus?
        BEQ @Okay
        CMP #'-'                ; Is it minus?
        BEQ @Okay
        JMP @PlusOrMinus        ; If not, try again
@Okay:
        STA OP
        JSR PrintChar
        JSR PrintSpace
        JSR GetAddress          ; Get second number
        STX EL
        STY EH
        JSR PrintSpace
        LDA #'='
        JSR PrintChar
        JSR PrintSpace
        LDA OP
        CMP #'-'
        BEQ @Sub                ; Branch if operation is subtract

        CLC                     ; Calculate DL,DH = SL,SH + EL,EH
        LDA SL
        ADC EL
        STA DL
        LDA SH
        ADC EH
        STA DH
        JMP @PrintResult

@Sub:
        SEC                     ; Calculate DL,DH = SL,SH - EL,EH
        LDA SL
        SBC EL
        STA DL
        LDA SH
        SBC EH
        STA DH

@PrintResult:
        LDX DL                  ; Print the result
        LDY DH
        JSR PrintAddress
        JSR PrintCR
        RTS

; -------------------- Utility Functions --------------------

; Generate one line of output for the dump command.
; Displays 8 bytes of memory
; Starting address in SL,SH.
; Registers changed: None
DumpLine:
        PHA                     ; save A
        TXA
        PHA                     ; Save X
        TYA
        PHA                     ; Save Y
        LDX SL                  ; Get start address
        LDY SH
        JSR PrintAddress        ; Display address
        JSR PrintSpace          ; and then a space
        LDY #0
@loop1: LDA (SL),Y              ; Get byte of data from memory
        JSR PrintByte           ; Display it in hex
        JSR PrintSpace          ; Followed bv space
        INY
        CPY #8                  ; Print 8 bytes per line
        BNE @loop1
        JSR PrintSpace
        LDY #0
@loop2: LDA (SL),Y              ; Now get the same data
        JSR PrintAscii          ; Display it in ASCII
        INY
        CPY #8                  ; 8 characters per line
        BNE @loop2
        JSR PrintCR             ; new line
        PLA                     ; Restore Y
        TAY
        PLA                     ; Restore X
        TAX
        PLA                     ; Restore A
        RTS

; Get character from keyboard
; Returns character in A
; Clears high bit to be valid ASCII
; Registers changed: A
GetKey:
        LDA KBDCR               ; Read keyboard control register
        BPL GetKey              ; Loop until key pressed (bit 7 goes high)
        LDA KBD                 ; Get keyboard data
        AND #%01111111          ; Clear most significant bit to convert to standard ASCII
        RTS

; Gets a hex digit (0-9,A-F). Echoes character as typed.
; ESC key cancels command and goes back to command loop.
; If RETOK is zero, ignore Return key.
; If RETOK is non-zero, pressing Return will cause it to return with A=0 and carry set.
; If CHAROK is non-zero, pressing a single quote allows entering a character.
; Ignores invalid characters. Returns binary value in A
; Registers changed: A
GetHex:
        JSR GetKey
        CMP #ESC                ; ESC key?
        BNE @checkRet
        JSR PrintCR
        PLA                     ; pop return address on stack
        PLA
        LDA #0
        STA CHAROK              ; Clear flag to accept character input
        JMP MainLoop            ; Abort command
@checkRet:
        CMP #CR                 ; Return key?
        BNE @next
        LDA RETOK               ; Flag set to check for return?
        BEQ GetHex              ; If not, ignore Return key
        LDA #0
        SEC                     ; Carry set indicates Return pressed
        RTS
@next:
        CMP #'''                ; Single quote for character input?
        BNE @next1
        LDA CHAROK              ; Are we accepting character input?
        BEQ GetHex              ; If not, ignore character
        LDA #'''                ; Echo a quote
        JSR PrintChar
        LDA #1                  ; Set flag that we are in character input mode
        STA CHARMODE
        JSR GetKey              ; Get a character

        BIT OHIGHASCII          ; If OHIGHASCII option is on, set high bit of character
        BPL @NoConv
        ORA #%10000000
@NoConv:
        JSR PrintChar           ; Echo it
        PHA                     ; Save the character
        LDA #'''                ; Echo a quote
        JSR PrintChar
        PLA                     ; Restore the character
        CLC                     ; Normal return
        RTS
@next1:
        CMP #'0'
        BMI GetHex              ; Invalid, ignore and try again
        CMP #'9'+1
        BMI @Digit
        CMP #'A'
        BMI GetHex              ; Invalid, ignore and try again
        CMP #'F'+1
        BMI @Letter
        JMP GetHex              ; Invalid, ignore and try again
@Digit:
        JSR PrintChar           ; echo
        SEC
        SBC #'0'                ; convert to value
        CLC
        RTS
@Letter:
        JSR PrintChar           ; echo
        SEC
        SBC #'A'-10             ; convert to value
        CLC
        RTS

; Get Byte as 2 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns byte in A
; If RETOK is zero, ignore Return key.
; If RETOK is non-zero, pressing Return as first character will cause it to return with A=0 and carry set.
; If CHAROK is non-zero, pressing a single quote allows entering a character.
; Registers changed: A
GetByte:
        JSR GetHex
        BCC @NotRet
        RTS                     ; <Return> was pressed, so return
@NotRet:
        PHA                     ; Save character
        LDA CHARMODE            ; Are we in character input mode?
        BEQ @Normal
        LDA #0                  ; If so, we got our byte as a character. Clear charmode.
        STA CHARMODE
        CLC
        PLA                     ; Restore character
        RTS                     ; Normal return
@Normal:
        PLA
        ASL
        ASL
        ASL
        ASL
        STA T1                  ; Store first nybble
        LDA CHAROK              ; Get value of CHAROK
        STA T2                  ; Save it
        LDA #0
        STA CHAROK              ; Disable char input for second nybble of a byte
@IgnoreRet:
        JSR GetHex
        BCS @IgnoreRet          ; If <Return> pressed, ignore it and try again
        CLC
        ADC T1                  ; Add second nybble
        STA T1                  ; Save it
        LDA T2                  ; Restore value of CHAROK
        STA CHAROK
        LDA T1                  ; Get value to return
        RTS

; Get Address as 4 chars 0-9,A-F
; Echoes characters as typed.
; Ignores invalid characters
; Returns address in X (low), Y (high)
; Registers changed: X, Y
GetAddress:
        PHA                     ; Save A
        JSR GetByte             ; Get the first (most significant) hex byte
        TAY                     ; Save in Y
        JSR GetByte             ; Get the second (least significant) hex byte
        TAX                     ; Save in X
        PLA                     ; Restore A
        RTS

; Print 16-bit address in hex
; Pass byte in X (low) and Y (high)
; Registers changed: None
PrintAddress:
        PHA                     ; Save A
        TYA                     ; Get low byte
        JSR PRBYTE              ; Print it
        TXA                     ; Get high byte
        JSR PRBYTE              ; Print it
        PLA                     ; Restore A
        RTS

; Print byte in hex
; Pass byte in A
; Registers changed: None
PrintByte:
        JSR PRBYTE              ; Just call PRBYTE routine
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
        PHA                     ; save for lower nybble
        AND #$F0                ; mask out upper nybble
        LSR                     ; shift into lower nybble
        LSR
        LSR
        LSR
        CLC
        ADC #'0'
        JSR PrintCharLZ
        PLA                     ; restore value
        AND #$0F                ; mask out lower nybble
        CLC
        ADC #'0'
        JSR PrintCharLZ
        RTS

; Print character but suppress 0 if LZ it not set.
; Sets LZ when non-zero printed.
; Pass char in A
PrintCharLZ:
        CMP #'0'                ; is it 0?
        BNE @notzero            ; if not, print it normally
        PHA
        LDA LZ                  ; is LZ zero?
        BNE @print
        PLA
        RTS                     ; suppress leading zero
@print: PLA
        JSR PrintChar
        RTS
@notzero:
        JSR PrintChar           ; print it
        LDA #1                  ; set LZ to 1
        STA LZ
        RTS

; Print byte as ASCII character or "."
; Pass character in A.
; Registers changed: None
PrintAscii:
        CMP #$20                ; first printable character (space)
        BMI NotAscii
        CMP #$7E+1              ; last printable character (~)
        BPL NotAscii
        JSR PrintChar
        RTS
NotAscii:
        PHA                     ; save A
        LDA #'.'
        JSR PrintChar
        PLA                     ; restore A
        RTS

; Print a carriage return
; Registers changed: None
PrintCR:
        PHA
        LDA #CR
        JSR PrintChar
        PLA
        RTS

; Print a space
; Registers changed: None
PrintSpace:
        PHA
        LDA #SP
        JSR PrintChar
        PLA
        RTS

; Print a string
; Pass address of string in X (low) and Y (high).
; String must be terminated in a null (zero).
; Registers changed: None
;
PrintString:
        PHA             ; Save A
        TYA
        PHA             ; Save Y
        STX T1          ; Save in page zero so we can use indirect addressing
        STY T1+1
        LDY #0          ; Set offset to zero
@loop:  LDA (T1),Y      ; Read a character
        BEQ done        ; Done if we get a null (zero)
        JSR PrintChar   ; Print it
        CLC             ; Increment address
        LDA T1          ; Low byte
        ADC #1
        STA T1
        BCC @nocarry
        INC T1+1        ; High byte
@nocarry:
        JMP @loop       ; Go back and print next character
done:   
        PLA
        TAY             ; Restore Y
        PLA             ; Restore A
        RTS

; Print byte as two hex chars.
; Taken from Woz Monitor PRBYTE routine ($FFDC).
; Pass byte in A
; Registers changed: A
PRBYTE:
        PHA             ; Save A for LSD.
        LSR
        LSR
        LSR             ; MSD to LSD position.
        LSR
        JSR PRHEX       ; Output hex digit.
        PLA             ; Restore A.
                        ; Falls through into PRHEX routine

; Print nybble as one hex digit.
; Take from Woz Monitor PRHEX routine ($FFE5).
; Pass byte in A
; Registers changed: A
PRHEX:
        AND #$0F        ; Mask LSD for hex print.
        ORA #'0'+$80    ; Add "0".
        CMP #$BA        ; Digit?
        BCC PrintChar   ; Yes, output it.
        ADC #$06        ; Add offset for letter.
                        ; Falls through into PrintChar routine

; Output a character
; Pass byte in A
; Based on Woz Monitor ECHO routine ($FFEF).
; Registers changed: none
PrintChar:
        PHP             ; Save status
        PHA             ; Save A as it may be changed
@Loop:
        BIT DSP         ; bit (B7) cleared yet?
        BMI @Loop       ; No, wait for display.

; If option is set, convert lower case character to upper case

        BIT OUPPER      ; Check value of option
        BPL @NotLower   ; Skip conversion if not set

        CMP #'a'        ; Is it 'a' or higher?
	BMI @NotLower
	CMP #'z'+1      ; Is is 'x' or lower?
	BPL @NotLower
	AND #%11011111  ; Convert to upper case by clearing bit 5
@NotLower:
        STA DSP         ; Output character. Sets DA.
        PLA             ; Restore A
        PLP             ; Restore status
        RTS             ; Return.

; Print a dollar sign
; Registers changed: None
PrintDollar:
        PHA
        LDA #'$'
        JSR PrintChar
        PLA
        RTS

; Print ",X"
; Registers changed: None
PrintCommaX:
        PHA
        LDA #','
        JSR PrintChar
        LDA #'X'
        JSR PrintChar
        PLA
        RTS

; Print ",Y"
; Registers changed: None
PrintCommaY:
        PHA
        LDA #','
        JSR PrintChar
        LDA #'Y'
        JSR PrintChar
        PLA
        RTS

; Print ",S"
; Registers changed: None
PrintCommaS:
        PHA
        LDA #','
        JSR PrintChar
        LDA #'S'
        JSR PrintChar
        PLA
        RTS

; Print "($"
; Registers changed: None
PrintLParenDollar:
        PHA
        LDA #'('
        JSR PrintChar
        LDA #'$'
        JSR PrintChar
        PLA
        RTS

; Print "[$"
; Registers changed: None
PrintLBraceDollar:
        PHA
        LDA #'['
        JSR PrintChar
        LDA #'$'
        JSR PrintChar
        PLA
        RTS

; Print a right parenthesis
; Registers changed: None
PrintRParen:
        PHA
        LDA #')'
        JSR PrintChar
        PLA
        RTS

; Print a right brace
; Registers changed: None
PrintRBrace:
        PHA
        LDA #']'
        JSR PrintChar
        PLA
        RTS

; Print several space characters.
; X contains number of spaces to print.
; Registers changed: X
PrintSpaces:
        PHA                     ; save A
        LDA #' '
        JSR PrintChars
        PLA                     ; restore A
        RTS

; Output a character multiple times
; A contains character to print.
; X contains number of times to print.
; Registers changed: X
PrintChars:
        JSR PrintChar
        DEX
        BNE PrintChars
        RTS

; Ask user whether to continue or not. Returns with carry clear if
; user selected <space> to continue, carry set if user selected <ESC>
; to stop.
; Registers changed: none

PromptToContinue:
        PHA                     ; save registers
        TXA
        PHA
        TYA
        PHA
        LDX #<ContinueString
        LDY #>ContinueString
        JSR PrintString
@SpaceOrEscape:
        JSR GetKey
        CMP #' '
        BEQ @Cont
        CMP #ESC
        BNE @SpaceOrEscape
        SEC                     ; carry set indicates ESC pressed
        BCS @Ret
@Cont:
        CLC
@Ret:
        JSR PrintCR
        PLA                     ; restore registers
        TAY
        PLA
        TAX
        PLA        
        RTS
        
; Delay. Calls routine WAIT using delay constant in OWDELAY.
DELAY:
        LDA OWDELAY
        BEQ NODELAY
        JMP WAIT
NODELAY:
        RTS

; Option picker. Adapted from "Assembly Cookbook for the Apple II/IIe" by Don Lancaster.
; Call with command letter in A.
; Registers affected: X
OPICK:
        TAY                     ; save A
        LDX #MATCHN             ; Get legal number of matches
SCAN:   CMP MATCHFL,X           ; Search for a match
        BEQ GOTMCH              ; Found
        DEX                     ; Try next
        BPL SCAN

GOTMCH: INX                     ; Makes zero a miss
        TXA                     ; Get jump vector
        ASL A                   ; Double pointer
        TAX
        LDA JMPFL+1,X           ; Get page address first!
        PHA                     ; and force on stack
        LDA JMPFL,X             ; Get position address
        PHA                     ; and force on stack
        TYA                     ; restore A
        RTS                     ; Jump via forced subroutine return

; Matchn holds the number of matches.
; Matchfl holds the legal characters.
; JMPFL holds the jump vectors (minus 1).

        MATCHN = JMPFL-MATCHFL

MATCHFL:
        .byte "$?ABCDEFGHIKLMORSTUV:="

JMPFL:
        .word Invalid-1
        .word Monitor-1
        .word Help-1
        .word Assembler-1
        .word Breakpoint-1
        .word Copy-1
        .word Dump-1
        .word ACIFW-1
        .word Fill-1
        .word Go-1
        .word Hex-1
        .word Basic-1
        .word MiniMonitor-1
        .word ClearScreen-1
        .word CFFA1-1
        .word Options-1
        .word Registers-1
        .word Search-1
        .word Test-1
        .word Unassemble-1
        .word Verify-1
        .word Math-1

; String input routine.
; Enter characters from the keyboard terminated in <Return> or <ESC>.
; Characters are echoed.
; Can be up to 127 characters.
; Returns:
;   Length stored at IN (doesn't include zero byte).
;   Characters stored starting at IN+1 ($0201-$027F, same as Woz Monitor)
;   String is terminated in a 0 byte.
;   Carry set if user hit <Esc>, clear if used <Enter> or max string length reached.
; Registers changed: A, X
GetLine:
        LDX #0                  ; Initialize index into buffer
loop:
        JSR GetKey              ; Get character from keyboard
        CMP #CR                 ; <Enter> key pressed?
        BEQ EnterPressed        ; If so, handle it
        CMP #ESC                ; <Esc> key pressed?
        BEQ EscapePressed       ; If so, handle it
        JSR PrintChar           ; Echo the key pressed
        STA IN+1,X              ; Store character in buffer (skip first length byte)
        INX                     ; Advance index into buffer
        CPX #$7E                ; Buffer full?
        BEQ EnterPressed        ; If so, return as if <Enter> was pressed
        BNE loop                ; Always taken
EnterPressed:
        CLC                     ; Clear carry to indicate <Enter> pressed and fall through
EscapePressed:
        LDA #0
        STA IN+1,X              ; Store 0 at end of buffer
        STX IN                  ; Store length of string
        RTS                     ; Return

; Variable length hex number input routine.
; Enter hex bytes from the keyboard terminated in <Return> or <ESC>.
; Characters are echoed.
; Can be up to 127 bytes.
; Returns:
;   Length stored at IN.
;   Characters stored starting at IN+1 ($0201-$027F, same as Woz Monitor)
; Registers changed: A, X

GetHexBytes:
        LDA #1
        STA RETOK               ; Set flag to accept <Return> key
        STA CHAROK              ; Set flag to accept character input
        LDX #0                  ; Initialize index into buffer
@loop:
        JSR GetByte             ; get hex number from keyboard (byte)
        BCS @Return             ; Branch if key was <Return>
        STA IN+1,X              ; Store character in buffer (skip first length byte)
        INX                     ; Advance index into buffer
        CPX #$7E                ; Buffer full?
        BNE @loop               ; If not, go back and get more input
@Return:
        STX IN                  ; Store length of string
        LDA #0
        STA RETOK               ; Clear flag to accept <Return> key
        STA CHAROK              ; Clear flag to accept character input
        RTS                     ; Return

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
BINBCD16:    SED                ; Switch to decimal mode
        LDA #0                  ; Ensure the result is clear
        STA BCD+0
        STA BCD+1
        STA BCD+2
        LDX #16                 ; The number of source bits
CNVBIT: ASL BIN+0               ; Shift out one bit
        ROL BIN+1
        LDA BCD+0               ; And add into result
        ADC BCD+0
        STA BCD+0
        LDA BCD+1               ; propagating any carry
        ADC BCD+1
        STA BCD+1
        LDA BCD+2               ; ... thru whole result
        ADC BCD+2
        STA BCD+2
        DEX                     ; And repeat for next bit
        BNE CNVBIT
        CLD                     ; Back to binary
        RTS                     ; All Done.

; Display processor flags
; Based on code at http://6502org.wikidot.com/software-output-flags

OUTP:
        LDA SAVE_P
P1:     LDX #7
@1:     ASL
        PHA
        LDA @3,X
        BCS @2
        LDA #'.'
@2:     JSR PrintChar
        PLA
        DEX
        BPL @1
        RTS
@3: .byte "CZIDB-VN"

; Clear screen by printing 24 carriage returns.
; Registers changed: none
ClearScreen:
        PHA             ; save A
        TXA             ; save X
        PHA
        LDA #CR
        LDX #24
        JSR PrintChars
        PLA             ; restore X
        TAX
        PLA             ; restore A
        RTS

; Strings

WelcomeMessage:
        .byte CR,"JMON monitor 0.97 by Jeff Tranter",CR,0

PromptString:
        .asciiz "? "

InvalidCommand:
        .byte "Invalid command. Type '?' for help",CR,0

; Help string.
HelpString:
        .byte "Assembler   A",CR
        .byte "Breakpoint  B <n or ?> <address>",CR
        .byte "Copy        C <start> <end> <dest>",CR
        .byte "Dump        D <start>",CR
        .byte "ACI menu    E",CR
        .byte "Fill        F <start> <end> <data>...",CR
        .byte "Go          G <address>",CR
        .byte "Hex to dec  H <address>",CR
        .byte "BASIC       I",CR
        .byte "Mini mon    K",CR
        .byte "Clr screen  L",CR
        .byte "CFFA1 menu  M",CR
        .byte "Options     O",CR
        .byte "Registers   R",CR
        .byte "Search      S <start> <end> <data>...",CR
        .byte "Test        T <start> <end>",CR
        .byte "Unassemble  U <start>",CR
        .byte "Verify      V <start> <end> <dest>",CR
        .byte "Woz mon     $",CR
        .byte "Write       : <address> <data>...",CR
        .byte "Math        = <address> +/- <address>",CR
        .byte "Help        ?",CR
        .byte 0

ContinueString:
        .asciiz "  <Space> to continue, <ESC> to stop"

InvalidRange:
        .byte "Error: start must be <= end",CR,0

NotFound:
        .byte "Not found",CR,0

Found:
        .asciiz "Found at: "

MismatchString:
        .asciiz "Mismatch: "

TestString1:
        .asciiz "Testing memory from $"

TestString2:
        .asciiz " to $"

TestString3:
        .byte CR,"Press any key to stop",CR,0

VNotRAMString:
  .byte "BRK vector not in RAM!",CR,0

BNotRAMString:
  .byte "Breakpoint not in RAM!",CR,0

NOBPString:
  .byte "Breakpoint not set!",CR,0

IntString:
  .byte "Interrupt ?",CR,0

UnknownBPString:
  .asciiz "Breakpoint ? at $"

KnownBPString1:
  .asciiz "Breakpoint "

KnownBPString2:
  .asciiz " at $"

NoCFFA1String:
  .byte "No CFFA1 card found!",CR,0

NoACIString:
  .byte "No ACI card found!",CR,0

ReadString:
  .byte " Read: ",0

OptionsString:
  .byte "Options",CR,0

UppercaseString:
  .byte "All uppercase output (Y/N)?",0

WriteDelayString:
  .byte "Write delay (00-FF)?",0

HighBitString:
  .byte "Set high bit in characters (Y/N)?",0

CPUTypeString:
  .byte "CPU type (1-6502 2-Rockwell 65C02",CR,"3-WDC 65C02 4-65816)?",0

  .include "disasm.s"
  .include "memtest4.s"
  .include "delay.s"
