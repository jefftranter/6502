; Information Routines
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

; iNfo command
;
; Displays information such as: detected CPU type, clock speed,
;   range of RAM and ROM, detected peripheral cards. etc.
;
; Sample Output:
;
;         CPU type: 65C02
;      Clock speed: 1 MHz
;RAM detected from: $0000 to $7FFF
;     RESET vector: $FF00
;   IRQ/BRK vector: $0100
;       NMI vector: $0000
;       WOZMON ROM: present
;        BASIC ROM: present
;     Krusader ROM: not present
;       CFFA1 card: present
;         AC1 card: not present


Info:
        JSR PrintChar           ; Echo command
        JSR PrintCR
        LDX #<CPUString         ; Display CPU type
        LDY #>CPUString
        JSR PrintString
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
        RTS

CPUString:
        .asciiz "         CPU Type: "

Type6502String:
        .asciiz "6502"

Type65C02String:
        .asciiz "65C02"

Type65816String:
        .asciiz "65816"


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
