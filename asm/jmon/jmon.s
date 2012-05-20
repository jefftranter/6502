;
; JMON - Simple Monitor Program
;
; Fills some gaps missing from Woz monitor.
;
; Jeff Tranter <tranter@pobox.com>
;
; TODO:
; - allow 8 or 16 bit data patterns in fill, search commands
;
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

; Constants
  CR  = $0D        ; Carriage Return
  SP  = $20        ; Space
  ESC = $1B        ; Escape

; Page Zero locations
; Note: Woz Mon uses $24 through $2B and $0200 through $027F.
; Krusader uses $F8, $F9, $FF, $FF.
; Mini-monitor uses $0F, $10, $11, $E0-$E8, $F0-$F6.
  T1   = $35       ; temp variable 1
  T2   = $36       ; temp variable 2
  SL   = $37       ; start address low byte
  SH   = $38       ; start address high byte
  EL   = $39       ; end address low byte
  EH   = $3A       ; end address high byte
  DA   = $3E       ; fill/search data (2 bytes)
  DL   = $40       ; destination address low byte
  DH   = $41       ; destination address high byte
  BIN  = $42       ; holds binary value low byte
  BINH = $43       ; holds binary value high byte
  BCD  = $44       ; holds BCD decimal number
  BCD2 = $45       ; holds BCD decimal number
  BCD3 = $46       ; holds BCD decimal number
  LZ   = $47       ; boolean for leading zero suppression
  LAST = $48       ; boolean for leading zero suppression / indicates last byte
  ADDR = $49       ; instruction address, 2 bytes (low/high)
  OPCODE = $4B     ; instruction opcode
  OP   = $4C       ; instruction type OP_*
  AM   = $4D       ; addressing mode AM_*
  LEN  = $4E       ; instruction length
  WDELAY = $4F     ; delay value when writing (defaults to zero)
  REL  = $50       ; relative addressing branch offset (2 bytes)
  DEST = $52       ; relative address destination address (2 bytes)
  START = $54      ; USER ENTERS START OF MEMORY RANGE min is 8 (2 bytes)
  END  = $556      ; USER ENTERS END OF MEMORY RANGE (2 bytes)
  ADDRS = $58      ; 2 BYTES - ADDRESS OF MEMORY
  TEST_PATRN = $5A ; 1 BYTE - CURRENT TEST PATTERN
  PASSES = $5B     ; NUMBER of PASSES
  BPA     = $60    ; address of breakpoint (2 bytes * 4 breakpoints)
  BPD     = $68    ; instruction at breakpoint (1 byte * 4 breakpoints)
  SAVE_A  = $70    ; holds saved values of registers
  SAVE_X  = $71    ; "
  SAVE_Y  = $72    ; "
  SAVE_P  = $73    ; "
  SAVE_PC = $74    ; holds PC while in BRK handler (2 bytes)
  VECTOR  = $76    ; holds adddress of IRQ/BREAK entry point

; External Routines
  BASIC     = $E000  ; BASIC
  KRUSADER  = $F000  ; Krusader Assembler
  MINIMON   = $FE14  ; Mini monitor entry point (valid for Krusader 6502 version 1.3)
  WOZMON    = $FF00  ; Woz monitor entry point
  PRBYTE    = $FFDC  ; Woz monitor print byte as two hex chars
  PRHEX     = $FFE5  ; Woz monitor print nybble as hex digit
  ECHO      = $FFEF  ; Woz monitor ECHO routine
  BRKVECTOR = $FFFE  ; and $FFFF (2 bytes)   

; Use start address of $A000 for Multi I/0 Board EEPROM
; .org $A000

; JMON Entry point
  .export JMON
JMON:
; Initialize some things just in case
  CLD                  ; clear decimal mode
  CLI                  ; clear interrupt disable
  LDX #$80             ; initialize stack pointer to $0180
  TXS                  ; so we are less likely to clobber BRK vector at $0100
  LDA #0
  STA  WDELAY          ; initialize write delay to zero
  JSR  BPSETUP         ; initialization for breakpoints

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
  BNE @TryMon
  JMP DoHex

; $
@TryMon:
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
  BNE @TryI
  JMP DoBreakpoint

; I
@TryI:
  CMP #'I'
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
  BNE @TryT
  JMP DoDump

; T
@TryT:
  CMP #'T'
  BNE @TryU
  JMP DoTest

; U
@TryU:
  CMP #'U'
  BNE @TryW
  JMP DoUnassemble

; W
@TryW:
  CMP #'W'
  BNE @Invalid
  JMP DoWriteDelay

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

; Add a delay after all writes to accomodate slow EEPROMs.
; Applies to COPY, FILL, and TEST commands.
; Depending on the manufacturer, anywhere from 0.5ms to 10ms may be needed.
; Value of $20 works well for me (approx 1.5ms delay with 2MHz clock).
; See routine WAIT for details.
DoWriteDelay:
        JSR PrintChar   ; echo command
        JSR PrintSpace
        JSR GetByte     ; get delay value
        STA WDELAY
        JSR PrintCR
        JMP MainLoop

; Go to Woz Monitor
DoMon:  JMP WOZMON

; Go to Krusader Mini Monitor
DoMiniMonitor:  JMP MINIMON

; Go to Krusader Assembler
DoAssembler:  JMP KRUSADER

; Go to BASIC
DoBasic:  JMP BASIC

; Handle breakpoint
; B ?                    <- list status of all breakpoints
; B <n> <address>        <- set breakpoint number <n> at address <address>
; B <n> 0000             <- remove breakpoint <n>
; <n> is 0 through 3.
DoBreakpoint:
        JSR PrintChar   ; echo command
        JSR PrintSpace  ; print space
IGN:    JSR GetKey      ; get breakpoint number
        CMP #'?'        ; ? lists breakpoints
        BEQ LISTB
        CMP #'0'        ; is it 0 through 3?
        BMI IGN         ; Invalid, ignore and try again
        CMP #'3'+1
        BMI VALIDBP
        JMP IGN
VALIDBP:
        JSR PrintChar   ; echo number
        SEC
        SBC #'0'        ; convert to number
        PHA             ; save it
        JSR PrintSpace  ; print space
        JSR GetAddress  ; prompt for address
        JSR PrintCR
        PLA             ; restore BP number
        JSR BPADD
        JMP MainLoop
LISTB:  JSR PrintCR
        JSR BPLIST
        JMP MainLoop

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
        JMP MainLoop

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
@copyUp: LDA (SL),Y             ; copy from source
        STA (DL),Y              ; to destination
        JSR DELAY               ; delay after writing to EEPROM
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone1
        LDA SL
        CMP EL
        BNE @NotDone
        JMP MainLoop            ; done
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
        LDA  EL                 ; Calculate length = End - Start
        SEC
        SBC  SL
        STA  T1
        LDA  EH
        SBC  SH
        STA  T2
        LDA  DL                 ; add length to Destination
        CLC
        ADC  T1
        STA  DL
        LDA  DH
        ADC  T2
        STA  DH
        LDY  #0
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
        JMP MainLoop            ; done
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
        JSR GetAddress  ; Get data (16-bit)
        STY DA
        STX DA+1
        JSR PrintCR
; Check that start address <= end address
        LDA SH
        CMP EH
        BCC @search
        BEQ @search
        BNE @invalid
        LDA SL
        CMP EL
        BCC @search
        BEQ @search
@invalid:
        LDX #<InvalidRange
        LDY #>InvalidRange
        JSR PrintString
        JMP MainLoop
@search:
        LDY #0
        LDA DA
        CMP (SL),Y              ; compare with memory data (first byte)
        BNE @Cont
        INY
        LDA DA+1                ; compare with memory data (second byte)
        CMP (SL),Y
        BEQ @Match              ; found match
@Cont:
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
        JSR PromptToContinue
        BCC @Cont
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
        JMP MainLoop
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
        JSR PromptToContinue
        BCC @line
        JMP MainLoop

; Unassemble Memory
DoUnassemble:
; echo 'U' and space, wait for start address
        JSR PrintChar
        JSR PrintSpace
        JSR GetAddress  ; Get start address
        STX ADDR
        STY ADDR+1
@line:  JSR PrintCR
        LDA #23
@loop:  PHA
        JSR DISASM    ; display line of output
        PLA
        SEC
        SBC #1
        BNE @loop
        JSR PromptToContinue
        BCC @line
        JMP MainLoop

; Test Memory
DoTest:
        JSR PrintChar   ; echo command
        JSR PrintSpace
        JSR GetAddress  ; get start address
        STX START
        STY START+1
        JSR PrintSpace
        JSR GetAddress  ; get end address
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
        JSR GetAddress  ; Get data (16 bits)
        STY DA
        STX DA+1
        JSR PrintCR
; Check that start address <= end address
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
        JMP MainLoop
@fill:
        LDY #0
        LDA DA
        STA (SL),Y              ; store data (first byte)
        JSR DELAY               ; delay after writing to EEPROM
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone1
        LDA SL
        CMP EL
        BNE @NotDone1
        JMP MainLoop            ; done
@NotDone1:
        LDA SL                  ; increment address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry1
        INC SH
@NoCarry1:
        LDA DA+1
        STA (SL),Y              ; store data (second byte)
        JSR DELAY               ; delay after writing to EEPROM
        LDA SH                  ; reached end yet?
        CMP EH
        BNE @NotDone2
        LDA SL
        CMP EL
        BNE @NotDone2
        JMP MainLoop            ; done
@NotDone2:
        LDA SL                  ; increment address
        CLC
        ADC #1
        STA SL
        BCC @NoCarry2
        INC SH
@NoCarry2:
        JMP @fill
        
; Do setup so we can support breakpoints
BPSETUP:
  LDA  BRKVECTOR      ; get address of BRK vector
  STA  VECTOR         ; and save in page zero
  LDA  BRKVECTOR+1
  STA  VECTOR+1
  LDA  #$4C           ; JMP instruction
  LDY  #0          
  STA  (VECTOR),Y     ; store at IRQ/BRK vector
  CMP  (VECTOR),Y     ; if we don't read back what we wrote
  BNE  VNOTINRAM      ; then vector address is not writable (user may have put it in ROM)
  LDA  #<BRKHANDLER   ; handler address low byte
  INY
  STA  (VECTOR),Y     ; write it after JMP
  LDA  #>BRKHANDLER   ; handler address low byte
  INY
  STA  (VECTOR),Y     ; write it after JMP
  LDA  #0             ; Mark all breakpoints as cleared (BPA and BPD set to 0)
  LDX  #0
  LDY  #0
CLEAR:
  STA  BPA,Y
  STA  BPA+1,Y
  STA  BPD,X
  INY
  INY
  INX
  CPX #4
  BNE CLEAR
  RTS
VNOTINRAM:
  LDX  #<VNotRAMString
  LDY  #>VNotRAMString
  JSR  PrintString
  RTS
BNOTINRAM:
  LDX  #<BNotRAMString
  LDY  #>BNotRAMString
  JSR  PrintString
  RTS

; List breakpoints, e.g.
; "BREAKPOINT n AT $nnnn"
BPLIST:
  LDX  #0
LIST:
  TXA
  PHA
  LDX  #<KnownBPString1
  LDY  #>KnownBPString1
  JSR  PrintString
  PLA
  PHA
  LSR  A                   ; divide by 2
  JSR  PRHEX
  LDX  #<KnownBPString2
  LDY  #>KnownBPString2
  JSR  PrintString
  PLA
  PHA
  TAX
  LDA  BPA,X
  INX
  LDY  BPA,X
  TAX
  JSR  PrintAddress
  JSR  PrintCR
  PLA
  TAX
  INX
  INX
  CPX  #8
  BNE  LIST
  RTS

; Return 1 in A if breakpoint number A exists, otherwise return 0.
BPEXISTS:
  ASL  A        ; need to multiply by 2 to get offset in array
  TAX
  LDA  BPA,X
  BNE  EXISTS
  LDA  BPA+1,X
  BNE  EXISTS
  LDA  #0
  RTS
EXISTS:
  LDA  #1
  RTS

; Add breakpoint number A at address in X,Y
BPADD:
  STX  T1
  STY  T2
  PHA
  JSR  BPEXISTS   ; if breakpoint already exists, remove it first
  BEQ  ADDIT
  PLA
  PHA
  JSR  BPREMOVE  ; remove it
ADDIT:
  PLA
  TAY
  ASL  A         ; need to multiply by 2 to get offset in array
  TAX
  LDA  T1
  STA  BPA,X     ; save address of breakpoint
  LDA T2
  STA  BPA+1,X
  LDA  (BPA,X)   ; get instruction at breakpoint address
  STA  BPD,Y     ; save it
  LDA  #0        ; BRK instruction
  STA  (BPA,X)   ; write breakpoint over code
  CMP  (BPA,X)   ; If we don't read back what we wrote
  BNE  BNOTINRAM ; then address is not writable (user may have put it in ROM)
  RTS

; Remove breakpoint number A
BPREMOVE:
  PHA
  JSR  BPEXISTS
  BNE  OK  
  LDX  #<NOBPString
  LDY  #>NOBPString
  JSR  PrintString
  PLA
  RTS
OK:
  PLA
  TAY
  ASL  A          ; multiply by 2 because table entries are two bytes
  TAX
  LDA  BPD,Y      ; get original instruction
  STA  (BPA,X)    ; restore instruction at breakpoint address
  LDA  #0         ; set BPA to address$0000 to clear breakpoint
  STA  BPA,X
  STA  BPA+1,X
  STA  BPD,Y      ; and clear BPD
  RTS

; Breakpoint handler
BRKHANDLER:
  STA  SAVE_A    ; save registers
  STX  SAVE_X
  STY  SAVE_Y
  PHP
  PLA
  STA  SAVE_P
;  LDA  #%00010000 ; position of B bit
;  BIT  SAVE_P     ; is B bit set, indicating BRK and not IRQ?
;  BNE  BREAK
;  JSR  PrintCR
;  LDX  #<IntString
;  LDY  #>IntString
;  JSR  PrintString
;BREAK:
  TSX           ; get stack pointer
  SEC           ; subtract 2 from return address to get actual instruction address
  LDA  $0102,X
  SBC  #2
  STA  $0102,X   ; put original instruction address back on stack
  STA  SAVE_PC   ; also save it for later reference
  LDA  $0103,X
  SBC  #0
  STA  $0103,X
  STA  SAVE_PC+1
  LDX  #0
CHECKADDR:
  LDA  SAVE_PC          ; see if PC matches address of a breakpoint
  CMP  BPA,X
  BNE  TRYNEXT
  LDA  SAVE_PC+1
  CMP  BPA+1,X
  BEQ  MATCHES
TRYNEXT:
  INX
  INX
  CPX  #8               ; last breakpoint reached
  BNE  CHECKADDR
UNKNOWN:
  JSR  PrintCR
  LDX  #<UnknownBPString
  LDY  #>UnknownBPString
  JSR  PrintString
  LDX  SAVE_PC
  LDY  SAVE_PC+1
  JSR  PrintAddress
  JMP  RESTORE
MATCHES:
  TXA
  PHA
  JSR  PrintCR
  LDX  #<KnownBPString1
  LDY  #>KnownBPString1
  JSR  PrintString
  PLA                      ; get BP # x2
  PHA                      ; save it again
  LSR  A                   ; divide by 2 to get BP number
  JSR  PRHEX
  LDX  #<KnownBPString2
  LDY  #>KnownBPString2
  JSR  PrintString
  LDX  SAVE_PC
  LDY  SAVE_PC+1
  JSR  PrintAddress
  PLA
  LSR  A
  JSR BPREMOVE
RESTORE:
  LDA  SAVE_P      ; restore registers
  PHA
  LDA SAVE_A
  LDX SAVE_X
  LDY SAVE_Y
  PLP
  JMP MINIMON     ; go to the mini monitor

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

; Get character from keyboard
; Returns in A
; Clears high bit to be valid ASCII
; Registers changed: A
GetKey:
        LDA $D011 ; Keyboard CR
        BPL GetKey
        LDA $D010 ; Keyboard data
        AND #%01111111
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
; String must be terminated in a null.
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

;------------------------------------------------------------------------
;
; Utility functions

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

; Print a right parenthesis
; Registers changed: None
PrintRParen:
  PHA
  LDA #')'
  JSR PrintChar
  PLA
  RTS

; Print number of spaces in X
; Registers changed: X
PrintSpaces:
  PHA
  LDA #SP
@LOOP:
  JSR ECHO
  DEX
  BNE @LOOP
  PLA
  RTS

; Ask user whether to continue or not. Returns with carry clear if
; user selected <space> to continue, carry set if user selected <ESC>
; to stop.
; Registers changed: none

PromptToContinue:
        PHA			; save registers
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
        
; Delay. Calls routine WAIT using delay constant in WDELAY.
DELAY:
  LDA WDELAY
  BEQ NODELAY
  JMP WAIT
NODELAY:
RTS

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

; Strings

WelcomeMessage:
        .byte CR,CR,"JMON MONITOR V0.8 BY JEFF TRANTER",CR,0

PromptString:
        .asciiz "? "

InvalidCommand:
        .byte "INVALID COMMAND. TYPE '?' FOR HELP",CR,$00

; Help string. Split in two because >255 characters
HelpString1:
        .byte "COMMANDS:",CR
        .byte "ASSEMBLER:  A",CR
        .byte "BREAKPOINT: B <N OR ?> <ADDRESS>",CR
        .byte "COPY:       C <START> <END> <DEST>",CR
        .byte "DUMP:       D <START>",CR
        .byte "FILL:       F <START> <END> <DATA>",CR
        .byte "HEX TO DEC  H <ADDRESS>",CR
        .byte "BASIC:      I",CR,0
HelpString2:
        .byte "MINI MON:   K",CR
        .byte "RUN:        R <ADDRESS>",CR
        .byte "SEARCH:     S <START> <END> <DATA>",CR
        .byte "TEST:       T <START> <END>",CR
        .byte "UNASSEMBLE: U <START>",CR
        .byte "VERIFY:     V <START> <END> <DEST>",CR
        .byte "WRITE DELAY W <DATA>",CR
        .byte "WOZ MON:    $",CR
        .byte "HELP:       ?",CR,0

ContinueString:
        .asciiz "  <SPACE> TO CONTINUE, <ESC> TO STOP"

InvalidRange:
        .byte "ERROR: START MUST BE <= END",CR,0

NotFound:
        .byte "NOT FOUND",CR,0

Found:
        .asciiz "FOUND AT: "

MismatchString:
        .asciiz "MISMATCH: "

TestString1:
        .asciiz "TESTING MEMORY FROM $"

TestString2:
        .asciiz " TO $"

TestString3:
        .byte CR,"PRESS ANY KEY TO STOP",CR,0

VNotRAMString:
  .byte "BRK VECTOR NOT IN RAM!",CR,0

BNotRAMString:
  .byte "BREAKPOINT NOT IN RAM!",CR,0

NOBPString:
  .byte "BREAKPOINT NOT SET!",CR,0

IntString:
  .byte "INTERRUPT ?",CR,0

UnknownBPString:
  .asciiz "BREAKPOINT ? AT $"

KnownBPString1:
  .asciiz "BREAKPOINT "

KnownBPString2:
  .asciiz " AT $"

  .include "disasm.s"
  .include "memtest4.s"
  .include "delay.s"
