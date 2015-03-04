; PAGE ZERO LOCATIONS

       NOTE     = $0070         ; Sets frequency of note
       QSEC     = $0080         ; 1/4 second counter
       SECS     = $0081         ; second counter
       MIN      = $0082         ; minute counter
       HR       = $0083         ; hour counter
       DAY      = $0084         ; day counter for AM-PM
       INH      = $00F9
       POINTL   = $00FA
       POINTH   = $00FB

       PBD      = $1702
       PBDD     = $1703
       TIME4    = $1704
       TIME7    = $1707
       TIMEF    = $170F
       SAVE1    = $1C05
       SCANDS   = $1F1F
       GETKEY   = $1F6A

; ESCAPE TO KIM IF 1 ON KIM IS PRESSED

;     This is a subroutine which will return to the KIM monitor routine
; without stopping the real time clock.  It is done by pressing 1 on the
; KIM keyboard.

       .ORG     $0300

KIM:    JSR     GETKEY          ; go back to KIM if
        CMP     #$01            ; KIM keyboard is one
        BNE     ENDR
        JSR     SCANDS          ; delay to make sure
        JSR     GETKEY
        CMP     #$01
        BNE     ENDR
        JMP     SAVE1
ENDR:   RTS

; TWO TONE SOUND TO INDICATE HOURS

;     This is a subroutine which when added to the clock display
; routine will use the real time clock data to produce one sound
; per hour on the hour,  The output is a speaker circuit as shown
; on Pg. 57  of the KIM-1 Manual.  It is hooked to PB0 rather than
; PA0.  The specific notes can be changed by altering 0330 and 033C.

       .RES     11
       .ORG     $0320

BEEP:   LDA     MIN             ; on the hour?
        BNE     END             ; if not return
        LDA     SECS            ;  execute until SEC = HR
        SEC
        SBC     HR
        BPL     END
AGAIN:  LDA     QSEC            ; first 1/4 second?
        BNE     ONE
        LDA     #$1E            ; set high note
        STA     NOTE
        BNE     GO              ; sound note for 1/4 second
ONE:    LDA     #$01            ; second 1/4 second?
        CMP     QSEC
        BNE     END
        LDA     #$28            ; set low note
        STA     NOTE
GO:     LDA     #$01            ; set I/O ports
        STA     PBDD
        INC     PBD             ; toggle speaker
        LDA     NOTE
        TAX                     ; set delay
DECR:   DEX
        BPL     DECR
END:    BMI     AGAIN           ; keep sounding
        RTS

; INTERRUPT ROUTINE

;     This routine uses the NMI to update a clock in zero page
; locations.  Since the crystal may be slightly off one MHz a
; fine adjustment is located at 0366.  NMI pointers must be set
; to the start of this program.

       .RES     16
       .ORG     $0360

       PHA                      ; save A
       TXA
       PHA                      ; save X
       TYA
       PHA                      ; save Y
       LDA      #$83            ; fine adjust timing
       STA      TIME4
TM:    BIT      TIME7           ; test timer
       BPL      TM              ; loop until time out
       INC      QSEC            ; count 1/4 seconds
       LDA      #$04            ; do four times before
       CMP      QSEC            ; updating seconds
       BNE      RTN
       LDA      #$00            ; reset 1/4 second counter
       STA      QSEC
       CLC
       SED                      ; advance clock in decimal
       LDA      SECS
       ADC      #$01            ; advance seconds
       STA      SECS
       CMP      #$60            ; until 60 seconds
       BNE      RTN
       LDA      #$00            ; then start again
       STA      SECS
       LDA      MIN
       CLC
       ADC      #$01            ; and advance minutes
       STA      MIN
       CMP      #$60            ; until 60 minutes
       BNE      RTN
       LDA      #$00            ; then start again
       STA      MIN
       LDA      HR              ; and advance hours
       CLC
       ADC      #$01
       STA      HR
       CMP      #$12            ; until 12 hours
       BNE      TH
       INC      DAY             ; advance 1/2 day
TH:    CMP      #$13            ; if 13 hours
       BNE      RTN             ; start again with one
       LDA      #$01
       STA      HR
RTN:   CLD                      ; go back to hex mode
       LDA      #$F4            ; start timer with interrupt
       STA      TIMEF           ; in 249,856 microseconds
       PLA
       TAY                      ; restore Y
       PLA
       TAX                      ; restore X
       PLA                      ; restore A
       RTI                      ; return from interrupt

; DISPLAY CLOCK ON KIM-1 READOUT

       .RES     5
       .ORG     $03C0

        LDA      #$00           ; reset 1/4 second counter
        STA      QSEC
        LDA      #$F4           ; start timer with interrupt
        STA      TIMEF
DSP:    LDA      SECS           ; start here if clock is running
        STA      INH            ; display clock on KIM
        LDA      MIN
        STA      POINTL
        LDA      HR
        STA      POINTH
        JSR      SCANDS
        JSR      KIM            ; escape to KIM
        JSR      BEEP           ; sound on the hour
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        JMP     DSP
