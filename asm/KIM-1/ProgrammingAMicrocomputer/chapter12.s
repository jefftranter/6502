; Code for Elevator Control Program. Chapter 12.

        .ORG    $0000

STOP    = $1C00
NMIV    = $17FA
PORTA   = $1700
DIRA    = $1701
PORTB   = $1702
DIRB    = $1703

; For starters we need to set the stop key, the stack pointer, make
; port B be output and set the car to be idle with an open door on
; floor 0. Also we clear all requests.

        LDA     #<STOP
        STA     NMIV
        LDA     #>STOP
        STA     NMIV+1
        LDX     #$FF
        TXS                     ; Set stack pointer
        STX     DIRB
        LDA     #$F0            ; Set port A to be 4 output
        STA     DIRA            ; and 4 input bits
        LDX     #$00            ; Set floor to "floor 0"
        LDA     #$01
        STA     PORTB
        LDA     #$00
        STA     UP
        STA     DOWN
        STA     KAR

; Here is the main idle routine where the elevator waits for business.
; Using the SCAN subroutine (which examines the up, down, and car re-
; quests) we see if there are any up-requests or down-requests.

IDLE:   JSR     SCAN
        LDA     UPREQ
        BNE     MOVUP
        LDA     DWNREQ
        BNE     MOVDWN

; Now delay .1 sec and do input from the keys. Then go back to IDLE.

        LDY     #$0A
        JSR     DELAY
        JMP     IDLE

; MOVUP and MOVDWN are two entry points to the same routine. They set
; a flag in UPDWN to *zero* for up and *one* for down. This flag is usu-
; ally kept in Y but sometimes we have to refresh it from UPDWN. When
; we get to MOV we have a request to go somewhere. Assume we are
; going up. We clear upward corridor requests for the current floor
; and on-board (KAR) requests for this floor:

MOVUP:  LDY     #$00
        JMP     P1
MOVDWN: LDY     #$01
P1:     STY     UPDWN
MOV:    LDY     UPDWN           ; UP=0 means Up. UP=1 means
        LDA     CLEARI,X        ; down.
        AND     UP,Y
        STA     UP,Y
        LDA     CLEARI,X
        AND     KAR
        STA     KAR

; Close the door, set the direction light and turn off the "door open"
; light:

        LDA     #$00
        STA     DOOR
        LDA     PORTB
        AND     #$0F
        ORA     GOUP,Y          ; GOUP0=uplight, GOUP1=downlight
        STA     PORTB

; Wait for 3 seconds, then turn off the current floor light, change
; floors by + or - one. Then turn on new floor light and again wait
; 3 seconds.

         LDY    #$20
         JSR    DELAY
         LDY    UPDWN
         LDA    PORTB
         AND    CLEARI,X        ; Has 0 this floor, one
         STA    PORTB           ;  elsewhere
         TXA
         CLC
         ADC    UNIT,Y          ; UNIT(0)=+1 UNIT(1)=-1
         TAX
         LDA    PORTB
         ORA    YESI,X
         STA    PORTB
         LDY    #$20
         JSR    DELAY

; We are moving up about to pass floor i. We look to see if any up
; requests from the corridor or any on-board requests for floor i. If
; so we will stop. Otherwise we will sail right on past if there are
; any requests above us.

         LDY    UPDWN
         LDA    UP,Y
         ORA    KAR             ; Combine requests
         AND    YESI,X          ; Clear all except this floor
         BNE    LSTOP           ; Stop if any calls
         JSR    SCAN            ; See if higher floors have
                                ;  requests
         LDA    UPREQ,Y         ; Get upreq or downreq
         BNE    MOV             ; No calls here but a higher
                                ;  calling

; Either by request or because no higher calling was found (that
; shouldn't happen, of course) we come to a STOP which marks the door
; open, does a delay, then a scan and finally tests to see if any more
; requests in the current direction. If not we turn off the direction
; light and go back to idle.

LSTOP:   LDA    #$80
         STA    DOOR
         LDY    #$20
         JSR    DELAY
         JSR    SCAN
         LDY    UPDWN
         LDA    UPREQ,Y
         BNE    MOV             ; Have more requests
         LDA    PORTB
         AND    #$0F            ; Turn off direction lights
         STA    PORTB
         JMP    IDLE            ; Go back to idle

; Here follows the three subroutines we need to make this program
; work. DELAY is a double loop timer including some calls to GET to
; find out which keys are pushed:

DELAY:   STY    COUNT
LOOP:    LDA    #$00            ; Set up inner loop
ROUND:   LDY    #$00
         JSR    GET             ; Up buttons
         INY
         JSR    GET             ; Down buttons
         INY
         JSR    GET             ; On-board buttons
         DEC    INNER
         BNE    ROUND           ; -inner loop-
         DEC    COUNT
         BNE    LOOP            ; -outer loop-
         RTS

; GET looks at the buttons to see who, if anybody, is calling. We
; enter with Y containing 0, 1, or 2 meaning UP, DOWN, and ONBOARD.
; We get BANK which contains a one to select the proper bank of but-
; tons and then sample the lower four bits and put it in UP, DOWN, or
; KAR.

GET:     LDA    BANK,Y
         ORA    DOOR
         STA    PORTA
         LDA    PORTA
         ORA    UP,Y
         STA    UP,Y
         RTS
BANK:    .BYTE  $20, $40, $10

; Skip to $0200 so we don't put code in page 1 where the stack is located.
        .RES    $0200-*

; Scan is the third subroutine. What is does is combine KAR requests
; with uprequests and then select only those at a higher floor than
; we are currently at. Then it does the same for down requests:

SCAN:    PHA
         LDA    UP
         ORA    DOWN
         AND    UPMASK,X
         STA    UPREQ
         LDA    UP
         ORA    DOWN
         ORA    KAR
         AND    DWNMASK,X
         STA    DWNREQ
         PLA
         RTS

UPMASK:  .BYTE  $0E, $0C, $08, $00
DWNMASK: .BYTE  $00, $01, $03, $07

; Other constants not associated with subroutines are:

CLEARI:  .BYTE  $0E, $0C, $0B, $07

YESI:    .BYTE  $01, $02, $04, $08

GOUP:    .BYTE  $20
GODWN:   .BYTE  $10
UNIT:    .BYTE  $01, $FF

; Variables are:

UP:      .BYTE  $00             ; Record of unanswered button pushes
DOWN:    .BYTE  $00
KAR:     .BYTE  $00
UPDWN:   .BYTE  $00             ; Tell the system which way the car is moving
UPREQ:   .BYTE  $00             ; Is non-zero if somebody upstairs or I want
                                ; to go up
DWNREQ:  .BYTE  $00             ; Same for the other way
INNER:   .BYTE  $00             ; Counts for
COUNT:   .BYTE  $00             ;            the delay
DOOR:    .BYTE  $00a            ; Is the door open or closed?
