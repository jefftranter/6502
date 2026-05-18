TXTCLR    =     $C050
MIXCLR    =     $C052
HISCR     =     $C055
HIRES     =     $C057

         .ORG   $101A

         LDY    #$00             ; "LDY" using the immediate mode.
         STY    TXTCLR           ; Clear location TXTCLR.
         STY    MIXCLR           ; Clear location MIXCLR.
         STY    HIRES            ; Clear location HIRES.
         STY    HISCR            ; Clear location HISCR.
         TYA                     ; Clear the accumulator.
         BRK                     ; Return to the monitor.
