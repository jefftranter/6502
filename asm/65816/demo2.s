; 65816 Programming Example 2

.org $6000

; Set 65816 mode for assembler
.P816

; Make assembler smart about figuring out 8 versus 16-bit mode.
; Alternatively can use .A16 and .I16 directives.

  .smart

DEMO2:

  CLC
  XCE                   ; switch to native mode

; Set mode for 16 bit accum (bit 5 M=0) and 16 bit XY regs (bit 4 X=0)

  REP  #%00110000       ; clear bits 5 and 4

; Use block move to fill memory with zeroes from $6100-$61FF

  LDA #$0000
  STA $61FE             ; write the first zero word
  LDA #$00FF            ; move 256 bytes of data (put length-1 here)
  LDX #$61FF            ; source address ending address
  LDY #$61FE            ; destination address ending address
  MVP 0,0               ; use bank 0 for source and dest

; Try a block move instruction to copy memory
; Copy $6100-$61FF to $6200-$62FF

  LDA #$00FF            ; move 256 bytes of data (put length-1 here)
  LDX #$61FF            ; source address ending address
  LDY #$62FF            ; destination address ending address
  MVP 0,0               ; use bank 0 for source and dest

; Set mode for 8-bit accum (bit 5 M=1) and 8-bit XY regs (bit 4 X=1)
  SEP  #%00110000   ; set bits 5 and 4

  SEC
  XCE           ; switch to emulation mode

  RTS           ; Return to caller
