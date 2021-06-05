;
; Scungy Video Demonstration Software
;
; Adapted from Fig. 1-14 on page 32 of "Son of Cheap Video" by Don
; Lancaster to run on my 6502 SBC.
;
; Jeff Tranter <tranter@pobox.com
;
; Display specifications:
; - 1.0 MHz CPU
; - 1 usec dot rate
; - 63 us per horizontal line
; - 32 chars per line (columns), 16 character lines (rows) per screen
; - 8 scan lines per character
; - Vertical sync pulse lasts for 3 lines 3x63 = 189 us with no H sync
; - Horizontal sync pulse once per line, 6 usec long
; - 265 lines per field, 1 field per frame (non-interlaced)
; - 1/63 us gives 15,873 Hz horizontal frequency
; - 265 lines gives 59.90 Hz vertical frequency
; - Each line of characters takes 8 scan lines
; - 16 character lines x 8 = 128 scan lines
; - Each line:
;   - H sync pulse:        6 usec
;   - before chars:       12 usec
;   - 32 displayed chars: 32 usec
;   - after chars:        13 usec
;   - Total:              63 usec
; - each field:
;   - blank scans at top:    68
;   - live scans:           128
;   - blank scans at bottom: 69
;   - total:                265
;
; Clock cycles shown in parentheses in comments.
; Uses some 65C02 instructions.
;
; TODO:
; Define constants for magic numbers.
; Initially write some characters to the video memory.
; Make version for 2 MHz CPU clock.


; Macros

.macro NOP1
        .byte   $03             ; 65C02 1 cycle NOP
.endmacro

; Constants

        VIA      = $8000        ; Start address of 6522 VIA
        VIA_DDRA = VIA+3        ; DDRA register
        VIA_ORA  = VIA+1        ; ORA register

; Code

        .org    $1FA0

        .setcpu "65c02"

start:

; Initialize VIA port A ports as outputs (only use 0-3, but needed so we can read back values)

        LDA     #%11111111      ; (2)
        STA     VIA_DDRA        ; (4)

loop:

; Send V sync pulse for 189 us
; Total time: 2 + 4 + 2 + (2 + 3) * 34 - 1 + 6 + 2 + 2 + 2 = 189 us

        LDA     #%00000001      ; (2) Start V sync pulse
        STA     VIA_ORA         ; (4)
        LDY     #34             ; (2) Delay for rest of V sync
vloop:
        DEY                     ; (2)  continued
        BNE     vloop           ; (2+) continued
        DEC     VIA_ORA         ; (6) End V sync pulse
        NOP                     ; (2) Use up 2 cycles
        NOP                     ; (2) Use up 2 cycles
        LDX     #68             ; (2) Number of scans

; Send 68 blank scans
; Total time: 6 + 6 + 2 + (2 + 3) * 9 - 1 + 2 + 3  = 63 us

bloop1:
        INC     VIA_ORA         ; (6) Output 6 usec H sync pulse
        DEC     VIA_ORA         ; (6)
        LDY     #9              ; (2) Delay for rest of scan time
hloop1:
        DEY                     ; (2)  continued
        BNE     hloop1          ; (2+) continued

        DEX                     ; (2) Decrement scan count
        BNE     bloop1          ; (2+) Go back until done
        NOP1                    ; (1) Use up 1 cycle

; Send live scans

; Live Scan Subroutine:
; 128 scan lines.
; Each horizontal scan should be exactly 63 us (clock cycles) in length.
; Total time: 6 + 6 + 6 + 36 + 2 + 4 + 3 = 63

lloop:  INC     VIA_ORA         ; (6) Output H sync pulse
        INC     VIA_ORA         ; (6) Advance row count
        JSR     SCAN            ; (6) Do scan microinstruction
        NOP                     ; (2) Equalize 2 us
        CMP     VIA_ORA         ; (4) Is this the last dot row?
        BNE     lloop           ; (2+) No, do another row of dots
        NOP1                    ; (2) Equalize 1 us

        LDX     #69             ; (2) Number of scans

; Send 69 blank scans
; Total time: 6 + 6 + 2 + (2 + 3) * 9 - 1 + 2 + 3  = 63 us

bloop2:
        INC     VIA_ORA         ; (6) Output 6 usec H sync pulse
        DEC     VIA_ORA         ; (6)
        LDY     #9              ; (2) Delay for rest of scan time
hloop2:
        DEY                     ; (2)  continued
        BNE     hloop2          ; (2+) continued

        DEX                     ; (2) Decrement scan count
        BNE     bloop2          ; (2+) Go back until done
        NOP1                    ; (1) Use up 1 cycle

        BRA     loop            ; (3) Go back and repeat

        .res   $2000-*,$00

; Scan code for Scungy video 1x32 alphanumeric display.
; JSR/RTS method.
; Must start on memory page, e.g. $2000
; Total cycles: 36

SCAN:
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)

        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)

        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)

        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        NOP1                    ; (1)
        RTS                     ; (6) first 2 are part of the scan
