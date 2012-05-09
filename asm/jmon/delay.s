; Delay routine. Taken from the Apple II ROM routine at $FCA8.
; Delay in clock cycles is 13 + 27/2 * A + 5/2 * A * A
; Changes registers: A
; Also see: chapter 3 of "Assembly Cookbook for the Apple II/IIe.

WAIT:    SEC
WAIT2:   PHA
WAIT3:   SBC   #$01
         BNE   WAIT3
         PLA              ; (13+27/2*A+5/2*A*A)
         SBC   #$01
         BNE   WAIT2
         RTS
