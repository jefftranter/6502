;
; 6502 Instruction Trace
;
; Copyright (C) 2012 by Jeff Tranter <tranter@pobox.com>
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

; Trace Feature
; --------------
; 
; The "." command will single step one instruction at a time showing the
; CPU registers. Starts with the register values listed by the R
; command. Updates them after single stepping.
; 
; The R(egister) shows the current PC and
; disassembles the current instruction. Also allow user to change the PC.
; Pressing <Enter> when prompted for a new register value will keep the
; current value and advance to the next register.
; 
; The G(o) command will be updated to optionally use the PC value if the
; user hits <Enter> instead of an address.
; 
; A breakpoint (BRK instruction) will go to the trace handler, whether
; set using the B command or not.
; 
; The command supports tracing/stepping through ROM as well as RAM.
; 
; e.g.
; 
; ? R
; A-D2 X-00 Y-03 S-017B P-33 ..-BDIZC
; FF00   D8          CLD
; A-00 X-01 Y-02 S-01FF P-00 ........
; PC-FF00
; ? .
; A-D2 X-00 Y-03 S-017B P-33 ..-B.IZC
; FF01   58          CLI   
; ? .
; A-D2 X-00 Y-03 S-017B P-33 ..-B..ZC
; FF02   A0 7F       LDY   #$7F
; ? .
; A-D2 X-00 Y-7F S-017B P-33 ..-B...C
; FF04   8C 12 D0    STY   $D012

; Future enhancements:
; - support for 65C02 instructions
; - support for 65816 instruction

; Variables used (defined in jmon.s):
;
; SAVE_A  - Holds saved values of registers
; SAVE_X  - "
; SAVE_Y  - "
; SAVE_S  - "
; SAVE_P  - "
; SAVE_PC - "
; NEXT_PC - Value of PC after next instruction
; ADDR - instruction address
; OPCODE - instruction op code
; OP - instruction type (OP_*)
; LEN -length of instruction
; IN - input buffer holding operands
; AM - addressing mode (AM_*)
; MNEM - hold three letter mnemonic string used by assembler
; OPERAND - Holds any operands for assembled instruction (2 bytes)

; TRACEINST - buffer holding traced instruction (3 bytes)


; Trace the next instruction using saved registers. Execute the
; instruction, display new registers values. disassemble new current
; instruction, and return.

Trace:

; Get next instruction op code from saved PC location.

        LDA SAVE_PC           ; Get address of instruction of execute (low byte)
        STA ADDR              ; Save in page zero so we can use indirect addressing
        LDA SAVE_PC+1         ; Do the same for the high byte of address
        STA ADDR+1
        LDY #0
        LDA (ADDR),Y          ; Get the instruction opcode
        STA OPCODE            ; And save it
        JSR GetLength         ; Determine instruction length

; Copy next instruction and operands to RAM buffer (can be up to 3 bytes)

        LDY #0
@Copy:
        LDA (ADDR),Y          ; Get the instruction operand from memory
        STA TRACEINST,Y       ; Write it to the buffer where we will execute it
        INY                   ; Increment index
        CPY LEN               ; Did we reach the instruction length?
        BNE @Copy             ; Continue for instruction length

; Now add a jump after the instruction to where we want to go after it is executed

        LDA #$4C              ; JMP ReturnFromTrace
        STA TRACEINST,Y
        INY
        LDA #<ReturnFromTrace
        STA TRACEINST,Y
        INY
        LDA #>ReturnFromTrace
        STA TRACEINST,Y
        
; Calculate new PC value.

         LDA SAVE_PC          ; Existing PC (low byte)
         CLC
         ADC LEN              ; Add length to it
         STA NEXT_PC          ; Save as next PC (low byte)
         LDA SAVE_PC+1        ; High byte
         ADC #0               ; Add any carry
         STA NEXT_PC+1        ; Save as next PC (high byte)

; Special handling for instructions that change flow of control.
; These are not actually executed, they are emulated

;   Bxx - branch instructions (8) - test (saved) flags for condition to determine next PC.
; 
;   BRK - set B=1. Push return address-1. Push P. Next PC is contents of IRQ vector.
; 
;   JMP (2) - Next PC is operand effective address (possibly indirect).
; 
;   JSR - push return address-1. Next PC is operand effective address.
; 
;   RTI - Pop P. Pop PC. Increment PC to get next PC.
; 
;   RTS - Pop PC. Increment PC to get next PC.
; 
;   go to AfterStep
 

; Not a special instruction. we execute it from the buffer.

; Save this program'ss stack pointer so we can restore it later.

        TSX
        STX THIS_S

; Restore registers from saved values.
; The order is critical here and P must be restored last.

        LDX SAVE_S      ; Restore stack pointer
        TXS
        LDA SAVE_P
        PHA             ; Push P
        LDY SAVE_Y      ; Restore Y
        LDX SAVE_X      ; Restore X
        LDA SAVE_A      ; Restore A
        PLP             ; Restore P

; Call instruction in buffer.
; It is followed by a JMP ReturnFromTrace so we get back

         JMP TRACEINST

ReturnFromTrace:

; Save new register values. Opposite order as was restored above.

        PHP
        STA SAVE_A
        STX SAVE_X
        STY SAVE_Y
        PLA
        STA SAVE_P
        TSX
        STX SAVE_S

; Clear D mode in case it is set, otherwise it would mess up our code.

        CLD

; Restore this program's stack pointer so RTS etc. will still work.

        LDX THIS_S
        TXS

AfterStep:

; Set new PC to next PC

        LDA NEXT_PC
        STA SAVE_PC
        LDA NEXT_PC+1
        STA SAVE_PC+1

; Display register values

        JSR PrintRegisters

; Disassemble next instruction (Set ADDR, call DISASM)

        LDA SAVE_PC
        STA ADDR
        LDA SAVE_PC+1
        STA ADDR+1
        JSR DISASM

        RTS                   ; return

; Given an instruction opcode, return the instruction's length.
; On entry opcode is in OPCODE. Length is returned in LEN.
; Also sets opcode type in OP and addressing mode in AM.
; Registers changed: A, X
GetLength:
        LDA OPCODE
        BMI @UPPER            ; if bit 7 set, in upper half of table
        ASL A                 ; double it since table is two bytes per entry
        TAX
        LDA OPCODES1,X        ; get the instruction type (e.g. OP_LDA)
        STA OP                ; store it
        INX
        LDA OPCODES1,X        ; get addressing mode
        STA AM                ; store it
        JMP @AROUND
@UPPER: 
        ASL A                 ; double it since table is two bytes per entry
        TAX
        LDA OPCODES2,X        ; get the instruction type (e.g. OP_LDA)
        STA OP                ; store it
        INX
        LDA OPCODES2,X        ; get addressing mode
        STA AM                ; store it
@AROUND:
        TAX                   ; put addressing mode in X
        LDA LENGTHS,X         ; get instruction length given addressing mode
        STA LEN               ; store it
        RTS                     ; Return
