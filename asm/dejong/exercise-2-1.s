TXTCLR    =     $C050
MIXCLR    =     $C052
HISCR     =     $C055
HIRES     =     $C057

         .org   $101A

         ldy    #$00             ; "LDY" using the immediate mode.
         sty    TXTCLR           ; Clear location TXTCLR.
         sty    MIXCLR           ; Clear location MIXCLR.
         sty    HIRES            ; Clear location HIRES.
         sty    HISCR            ; Clear location HISCR.
         tya                     ; Clear the accumulator.
         brk                     ; Return to the monitor.
