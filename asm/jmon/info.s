; Information Routines
;
; Copyright (C) 2012-2021 by Jeff Tranter <tranter@pobox.com>
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;   http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.
;

; iNfo command
;
; Displays information such as: detected CPU type, clock speed,
;   range of RAM and ROM, detected peripheral cards. etc.
;
; Sample Output:
;
;         Computer: Apple //c
;         CPU type: 65C02
;        CPU speed: 2.0 MHZ
;RAM detected from: $0000 TO $7FFF
;       NMI vector: $0F00
;     RESET vector: $FF00
;   IRQ/BRK vector: $0100
;         ACI card: NOT PRESENT
;       CFFA1 card: NOT PRESENT
;   MULTI I/O card: PRESENT
;        BASIC ROM: PRESENT
;     KRUSADER ROM: PRESENT
;       WOZMON ROM: PRESENT
;Slot ID Type
; 1   31 serial or parallel
; 2   31 serial or parallel
; 3   88 80 column card
; 4   20 joystick or mouse
; 5   -- empty or unknown
; 6   -- empty or unknown
; 7   9B Network or bus interface

Info:
        JSR PrintChar           ; Echo command
        JSR PrintCR

        JSR Imprint             ; Display computer type
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "         Computer: "
.elseif .defined(OSI)
        .asciiz "      Computer: "
.endif

.if .defined(APPLE1)
        LDX #<TypeApple1String
        LDY #>TypeApple1String

.elseif .defined(APPLE2)

; Identify model of Apple computer. Algorithm is from Apple //c
; Reference Manual.
; ID1 = FBB3
; ID2 = FBC0
; if (ID1) = 38
;   then id = Apple II
; else if (ID1) = EA
;   then id = Apple II+
; else if (ID1) = 06
;   if (ID2) = EA
;     then id = Apple //e
;   else if (ID2) = 00
;     then id = Apple //c
; else
;   id = Unknown

        ID1 = $FBB3
        ID2 = $FBC0
        LDA ID1
        CMP #$38
        BNE Next1
        LDX #<TypeAppleIIString
        LDY #>TypeAppleIIString
        JMP PrintType
Next1:
        CMP #$EA
        BNE Next2
        LDX #<TypeAppleIIplusString
        LDY #>TypeAppleIIplusString
        JMP PrintType
Next2:
        CMP #$06
        BNE Unknown
        LDA ID2
        CMP #$EA
        BNE Next3
        LDX #<TypeAppleIIeString
        LDY #>TypeAppleIIeString
        JMP PrintType
Next3:
        CMP #$00
        BNE Unknown
        LDX #<TypeAppleIIcString
        LDY #>TypeAppleIIcString
        JMP PrintType
Unknown:
        LDX #<TypeAppleUnknown
        LDY #>TypeAppleUnknown

.elseif .defined(KIM1)
        LDX #<TypeKim1String
        LDY #>TypeKim1String
.elseif .defined(OSI)
        LDX #<TypeOSIString
        LDY #>TypeOSIString
.elseif .defined(SBC)
        LDX #<TypeSBCString
        LDY #>TypeSBCString
 .endif

PrintType:
        JSR PrintString
        JSR PrintCR

        JSR Imprint             ; Display CPU type
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "         CPU type: "
.elseif .defined(OSI)
        .asciiz "      CPU type: "
.endif
        JSR CPUType
        CMP #1
        BNE @Try2
        LDX #<Type6502String
        LDY #>Type6502String
        JMP @PrintCPU
@Try2:
        CMP #2
        BNE @Try3
        LDX #<Type65C02String
        LDY #>Type65C02String
        JMP @PrintCPU
@Try3:
        CMP #3
        BNE @Invalid
        LDX #<Type65816String
        LDY #>Type65816String

@PrintCPU:
        JSR PrintString
        JSR PrintCR

@Invalid:

; Speed test works on Apple 1 with Multi I/O card or Apple II with
; Super Serial Card or Apple //c with on-board serial.

.if .defined(APPLE1) .or .defined (APPLE2)

.ifdef APPLE1
        JSR MultiIOPresent      ; Can only measure clock speed if we have a Multi I/O card
.endif
.ifdef APPLE2
        JSR SerialPresent       ; Can only measure clock speed if we have a serial port
.endif
        BEQ @SkipSpeed
        JSR Imprint
        .asciiz "        CPU speed: "
        JSR MeasureCPUSpeed
        STA BIN+0
        LDA #0
        STA BIN+1
        JSR BINBCD16
        LDA BCD+0               ; Will contain BCD number like $20 for 2.0 MHz
        TAX
        LSR A
        LSR A
        LSR A
        LSR A
        JSR PRHEX
        LDA #'.'
        JSR PrintChar
        TXA
        JSR PRHEX
        JSR Imprint
        .asciiz " MHz"
        JSR PrintCR
.endif

@SkipSpeed:
        JSR Imprint           ; Print range of RAM
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "RAM detected from: $0000 to "
.elseif .defined(OSI)
        .byte "RAM found from: $0000", CR, "            to: ", 0
.endif
        JSR PrintDollar
        JSR FindTopOfRAM
        JSR PrintAddress
        JSR PrintCR

        JSR Imprint           ; Print NMI vector address
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "       NMI vector: $"
.elseif .defined(OSI)
        .asciiz "    NMI vector: $"
.endif
        LDX $FFFA
        LDY $FFFB
        JSR PrintAddress
        JSR PrintCR

        JSR Imprint ; Print reset vector address
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "     RESET vector: $"
.elseif .defined(OSI)
        .asciiz "  RESET vector: $"
.endif
        LDX $FFFC
        LDY $FFFD
        JSR PrintAddress
        JSR PrintCR

        JSR Imprint   ; Print IRQ/BRK vector address
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(KIM1) .or .defined(SBC)
        .asciiz "   IRQ/BRK vector: $"
.elseif .defined(OSI)
        .asciiz "IRQ/BRK vector: $"
.endif
        LDX $FFFE
        LDY $FFFF
        JSR PrintAddress
        JSR PrintCR

.ifdef APPLE1
        JSR Imprint
        .asciiz "         ACI card: "
        JSR ACIPresent
        JSR PrintPresent
        JSR PrintCR

        JSR Imprint
        .asciiz "       CFFA1 card: "
        JSR CFFA1Present
        JSR PrintPresent
        JSR PrintCR

        JSR Imprint
        .asciiz "   Multi I/O Card: "
        JSR MultiIOPresent
        JSR PrintPresent
        JSR PrintCR
.endif

.if .defined(APPLE) .or .defined(OSI)
        JSR Imprint
.if .defined(APPLE1) .or .defined(APPLE2) .or .defined(SBC)
        .asciiz "        BASIC ROM: "
.elseif .defined(OSI)
        .asciiz "     BASIC ROM: "
.endif
        JSR BASICPresent
        JSR PrintPresent
        JSR PrintCR
.endif

.ifdef APPLE1
        JSR Imprint
        .asciiz "     Krusader ROM: "
        JSR KrusaderPresent
        JSR PrintPresent
        JSR PrintCR
.endif

.ifdef APPLE1
        JSR Imprint
        .asciiz "       WozMon ROM: "
        JSR WozMonPresent
        JSR PrintPresent
        JSR PrintCR
.endif

.ifdef APPLE2
; Display IDs of cards in slots. Uses Pascal 1.1 firmware protocol.
; Pseudodode:
; print "Slot ID  Type\n"
; for s in 1..7
;   print " s   "
;   if $Cs05 == $38 and $Cs07 == $18 and $Cn0B == $01
;     id = $Cs0C
;     print "id  "
;     class = ( ID && $F0 ) >> 4
;      switch class:
;        case 0: print "reserved"
;        case 1: print "printer"
;        case 2: print "joystick or mouse"
;        case 3: print "serial or parallel"
;        case 4: print "modem"
;        case 5: print "sound or speech device"
;        case 6: print "clock"
;        case 7: print "mass storage device"
;        case 8: print "80 column card"
;        case 9: print "Network or bus interface"
;        case 10: print "special purpose"
;        default: print "reserved"
;   else
;     print "--  empty or unknown\n"

        JSR Imprint             ; Print table header
        .asciiz "Slot ID Type"
        JSR PrintCR             ; And newline

        LDA #1                  ; Initialize slot number
        STA SLOT
Slots:
        JSR PrintSpace          ; Print a space
        LDA SLOT                ; Print slot number
        JSR PRHEX
        LDX #3                  ; Print three spaces
        JSR PrintSpaces

        LDA SLOT                ; Get slot number
        CLC
        ADC #$C0                ; Calculate $Cs
        STA ADDR+1              ; High byte of address to read

        LDA #$05                ; Want to read $Cs05
        STA ADDR                ; Low byte of address to read
        LDX #0                  ; Read $Cs05
        LDA (ADDR,X)
        CMP #$38                ; Should be $38 for peripheral card
        BEQ OK1
        JMP EmptySlot
OK1:
        LDA #$07                ; Want to read $Cs07
        STA ADDR                ; Low byte of address to read
        LDX #0                  ; Read $Cs07
        LDA (ADDR,X)
        CMP #$18                ; Should be $18 for peripheral card
        BEQ OK2
        JMP EmptySlot
OK2:
        LDA #$0B                ; Want to read $Cs0B
        STA ADDR                ; Low byte of address to read
        LDX #0                  ; Read $Cs0B
        LDA (ADDR,X)
        CMP #$01                ; Should be $01 for peripheral card
        BEQ OK3
        JMP EmptySlot
OK3:
        LDA #$0C                ; Want to read $Cs0C
        STA ADDR                ; Low byte of address to read
        LDX #0                  ; Read $Cs0C
        LDA (ADDR,X)            ; This is the card ID
        PHA                     ; Save A
        JSR PrintByte           ; Print card ID
        JSR PrintSpace          ; Then a space
        PLA                     ; Restore A (Card ID)
        AND #$F0                ; Mask off class portion of ID (upper nybble)
        LSR                     ; Shift into lower nybble
        LSR
        LSR
        LSR
        CMP #$00                ; Is it class 0?
        BNE Try1                ; If not, try next class.
        JSR Imprint             ; Display class
        .asciiz "reserved"
        JSR PrintCR
        JMP NextSlot
Try1:
        CMP #$01
        BNE Try2
        JSR Imprint
        .asciiz "printer"
        JSR PrintCR
        JMP NextSlot
Try2:
        CMP #$02
        BNE Try3
        JSR Imprint
        .asciiz "joystick or mouse"
        JSR PrintCR
        JMP NextSlot
Try3:
        CMP #$03
        BNE Try4
        JSR Imprint
        .asciiz "serial or parallel"
        JSR PrintCR
        JMP NextSlot
Try4:
        CMP #$04
        BNE Try5
        JSR Imprint
        .asciiz "modem"
        JSR PrintCR
        JMP NextSlot
Try5:
        CMP #$05
        BNE Try6
        JSR Imprint
        .asciiz "sound or speech device"
        JSR PrintCR
        JMP NextSlot
Try6:
        CMP #$06
        BNE Try7
        JSR Imprint
        .asciiz "clock"
        JSR PrintCR
        JMP NextSlot
Try7:
        CMP #$07
        BNE Try8
        JSR Imprint
        .asciiz "mass storage device"
        JSR PrintCR
        JMP NextSlot
Try8:
        CMP #$08
        BNE Try9
        JSR Imprint
        .asciiz "80 column card"
        JSR PrintCR
        JMP NextSlot
Try9:
        CMP #$09
        BNE Try10
        JSR Imprint
        .asciiz "network or bus interface"
        JSR PrintCR
        JMP NextSlot
Try10:
        CMP #$0A
        BNE Default
        JSR Imprint
        .asciiz "special purpose"
        JSR PrintCR
        JMP NextSlot
Default:
        JSR Imprint
        .asciiz "future expansion"
        JSR PrintCR
        JMP NextSlot
EmptySlot:
        JSR Imprint
        .asciiz "-- empty or unknown"
        JSR PrintCR
NextSlot:
        LDA SLOT                ; Get current slot
        CLC                     ; Add one
        ADC #1
        STA SLOT
        CMP #8                  ; Are we done?
        BEQ Done                ; Yes, done.
        JMP Slots               ; No, do next slot.
Done:
.endif
        RTS

; Determine type of CPU. Returns result in A.
; 1 - 6502, 2 - 65C02, 3 - 65816.
; Algorithm taken from Western Design Center programming manual.

CPUType:
        SED           ; Trick with decimal mode used
        LDA #$99      ; Set negative flag
        CLC
        ADC #$01      ; Add 1 to get new accumulator value of 0
        BMI O2        ; 6502 does not clear negative flag so branch taken.

; 65C02 and 65816 clear negative flag in decimal mode

        CLC
        .p816         ; Following Instruction is 65816
        XCE           ; Valid on 65816, unimplemented NOP on 65C02
        BCC C02       ; On 65C02 carry will still be clear and branch will be taken.
        XCE           ; Switch back to emulation mode
        .p02          ; Go back to 6502 assembler mode
        CLD
        LDA #3        ; 65816
        RTS
C02:
        CLD
        LDA #2        ; 65C02
        RTS
O2:
        CLD
        LDA #1        ; 6502
        RTS

; Based on the value in A, displays "present" (1) or "not present" (0).

PrintPresent:
        CMP #0
        BNE @Present
        JSR Imprint
        .asciiz "not "
@Present:
        JSR Imprint
        .asciiz "present"
        RTS

; Determines top of installed RAM while trying not to corrupt any other
; program including this one. We assume RAM starts at 0. Returns top
; RAM address in X (low), Y (high).

 LIMIT = $FFFF        ; Highest address we want to test
 TOP   = $00          ; Holds current highest address of RAM (two bytes)

FindTopOfRAM:

        LDA #<$0002         ; Store $0002 in TOP (don't want to change TOP)
        STA TOP
        LDA #>$0002
        STA TOP+1

@Loop:
        LDY #0
        LDA (TOP),Y         ; Read current contents of (TOP)
        TAX                 ; Save in register so we can later restore it
        LDA #0              ; Write all zeroes to (TOP)
        STA (TOP),Y
        CMP (TOP),Y         ; Does it read back?
        BNE @TopFound       ; If not, top of memory found
        LDA #$FF            ; Write all ones to (TOP)
        STA (TOP),Y
        CMP (TOP),Y         ; Does it read back?
        BNE @TopFound       ; If not, top of memory found
        LDA #$AA            ; Write alternating bits to (TOP)
        STA (TOP),Y
        CMP (TOP),Y         ; Does it read back?
        BNE @TopFound       ; If not, top of memory found
        LDA #$55            ; Write alternating bits to (TOP)
        STA (TOP),Y
        CMP (TOP),Y         ; Does it read back?
        BNE @TopFound       ; If not, top of memory found

        TXA                 ; Write original data back to (TOP)
        STA (TOP),Y

        LDA TOP             ; Increment TOP (low,high)
        CLC
        ADC #1
        STA TOP
        LDA TOP+1
        ADC #0              ; Add any carry
        STA TOP+1

;  Are we testing in the range of this code (i.e. the same 256 byte
;  page)? If so, need to skip over it because otherwise the memory
;  test will collide with the code being executed when writing to it.

        LDA TOP+1           ; High byte of page
        CMP #>FindTopOfRAM  ; Same page as this code?
        BEQ @Skip
        BNE @NotUs
@Skip:
        INC TOP+1           ; Skip over this page when testing
        INC TOP+1           ; And the next page in case code extends into next page too

@NotUs:

        LDA TOP+1           ; Did we reach LIMIT? (high byte)
        CMP #>LIMIT
        BNE @Loop           ; If not, keep looping
        LDA TOP             ; Did we reach LIMIT? (low byte)
        CMP #<LIMIT
        BNE @Loop           ; If not, keep looping

@TopFound:
        TXA                 ; Write original data back to (TOP) just in case it is important
        STA (TOP),Y

FindTopOfRAMEnd:            ; End of critical section we don't want to write to during testing

        LDA TOP             ; Decrement TOP by 1 to get last RAM address
        SEC
        SBC #1
        STA TOP
        LDA TOP+1
        SBC #0              ; Subtract any borrow
        STA TOP+1

        LDX TOP             ; Set top of RAM as TOP (X-low Y-high)
        LDY TOP+1

        RTS                 ; Return

; Measure CPU clock speed by sending characters out the serial port of
; a Multi I/O board and counting how many CPU cycles it takes. Returns
; value in A that is approximately CPU speed in MHz * 10.

.if .defined(APPLE1) .or .defined(APPLE2)

MeasureCPUSpeed:

.ifdef APPLE1
; 6551 Chip registers
        TXDATA = $C300
        RXDATA = $C300
        STATUSREG = $C301
        CMDREG = $C302
        CTLREG = $C303
.endif

.ifdef APPLE2
; 6551 Chip registers
        TXDATA = $C098
        RXDATA = $C098
        STATUSREG = $C099
        CMDREG = $C09A
        CTLREG = $C09B
.endif

; Set 1 stop bit, 8 bit data, internal clock, 19200bps
        LDA #%00011111
        STA CTLREG

; Set no parity, no echo, no TX interrupts, RTS low, no RX interrupts, DTR low
       LDA #%00001011
       STA CMDREG

        LDA #'A'  ; Character to send
        LDX #0    ; Counter
        JSR Echo
        JSR Echo
        JSR Echo
        TXA
        RTS

; Send character in A out serial port
Echo:
        PHA
        LDA #$10
TXFULL: INX
        LDY #8          ; Add additional delay
@Delay: DEY
        BNE @Delay
        NOP
        NOP
        BIT STATUSREG ; wait for TDRE bit = 1
        BEQ TXFULL
        PLA
        STA TXDATA
        RTS
.endif
