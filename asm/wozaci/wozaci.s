;-------------------------------------------------------------------------
;
; The WOZ Apple Cassette Interface for the Apple 1
; Written by Steve Wozniak somewhere around 1976
;
;-------------------------------------------------------------------------

        .org $C100

;-------------------------------------------------------------------------
; Memory declaration
;-------------------------------------------------------------------------

        HEX1L = $24             ; End address of dump block
        HEX1H = $25
        HEX2L = $26             ; Begin address of dump block
        HEX2H = $27
        SAVEINDEX = $28         ; Save index in input buffer
        LASTSTATE = $29         ; Last input state

        IN = $0200              ; Input buffer
        FLIP = $C000            ; Output flip-flop
        TAPEIN = $C081          ; Tape input
        KBD = $D010             ; PIA.A keyboard input
        KBDCR = $D011           ; PIA.A keyboard control register
        ESCAPE = $FF1A          ; Escape back to monitor
        ECHO = $FFEF            ; Echo character to terminal

;-------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------

        CR = $8D                ; Carriage Return
        ESC = $9B               ; ASCII ESC

;-------------------------------------------------------------------------
; Let’s get started
;-------------------------------------------------------------------------

.export WOZACI
WOZACI: LDA #$AA                ; Print the Tape prompt '*'
        JSR ECHO
        LDA #CR                 ; And drop the cursor one line
        JSR ECHO

        LDY #<-1                ; Reset the input buffer index
NEXTCHAR: INY
KBDWAIT: LDA KBDCR              ; Wait for a key
        BPL KBDWAIT             ; Still no key!

        LDA KBD                 ; Read key from keyboard
        STA IN,Y                ; Save it into buffer
        JSR ECHO                ; And type it on the screen
        CMP #ESC
        BEQ WOZACI              ; Start from scratch if ESC!
        CMP #CR
        BNE NEXTCHAR            ; Read keys until CR

        LDX #<-1                ; Initialize parse buffer pointer

;-------------------------------------------------------------------------
; Start parsing first or a new tape command
;-------------------------------------------------------------------------

NEXTCMD: LDA #0                 ; Clear begin and end values
        STA HEX1L
        STA HEX1H
        STA HEX2L
        STA HEX2H

NEXTCHR: INX                    ; Increment input pointer
        LDA IN,X                ; Get next char from input line
        CMP #$D2                ; Read command? 'R'
        BEQ READ                ; Yes!
        CMP #$D7                ; Write command? 'W'
        BEQ WRITE               ; Yes! (note: CY=1)
        CMP #$AE                ; Separator?'.'
        BEQ SEP                 ; Yes!
        CMP #CR                 ; End of line?
        BEQ GOESC               ; Escape to monitor! We’re done
        CMP #$A0                ; Ignore spaces: ' '
        BEQ NEXTCHR
        EOR #$B0                ; Map digits to 0-9 '0'
        CMP #9+1                ; Is it a decimal digit?
        BCC DIG                 ; Yes!
        ADC #$88                ; Map letter 'A'-'F' to $FA-$FF
        CMP #$FA                ; Hex letter?
        BCC WOZACI              ; No! Character not hex!

DIG:    ASL                     ; Hex digit to MSD of A
        ASL
        ASL
        ASL

        LDY #4                  ; Shift count
HEXSHIFT: ASL                   ; Hex digit left, MSB to carry
        ROL HEX1L               ; Rotate into LSD
        ROL HEX1H               ; Rotate into MSD
        DEY                     ; Done 4 shifts?
        BNE HEXSHIFT            ; No! Loop
        BEQ NEXTCHR             ; Handle next character

;-------------------------------------------------------------------------
; Return to monitor, prints \ first
;-------------------------------------------------------------------------

GOESC: JMP ESCAPE               ; Escape back to monitor

;-------------------------------------------------------------------------
; Separating . found. Copy HEX1 to Hex2. Doesn’t clear HEX1!!!
;-------------------------------------------------------------------------

SEP:    LDA HEX1L               ; Copy hex value 1 to hex value 2
        STA HEX2L
        LDA HEX1H
        STA HEX2H
        BCS NEXTCHR             ; Always taken!

;-------------------------------------------------------------------------
; Write a block of memory to tape
;-------------------------------------------------------------------------

WRITE:  LDA #64                 ; Write 10 second header
        JSR WHEADER

WRNEXT: DEY                     ; Compensate timing for extra work
        LDX #0                  ; Get next byte to write
        LDA (HEX2L,X)

        LDX #8*2                ; Shift 8 bits (decremented twice)
WBITLOOP: ASL                   ; Shift MSB to carry
        JSR WRITEBIT            ; Write this bit
        BNE WBITLOOP            ; Do all 8 bits!

        JSR INCADDR             ; Increment address
        LDY #30                 ; Compensate timer for extra work
        BCC WRNEXT              ; Not done yet! Write next byte

RESTIDX: LDX SAVEINDEX          ; Restore index in input line
        BCS NEXTCMD             ; Always taken!

;-------------------------------------------------------------------------
; Read from tape
;-------------------------------------------------------------------------

READ:   JSR FULLCYCLE           ; Wait until full cycle is detected
        LDA #22                 ; Introduce some delay to allow
        JSR WHEADER             ; the tape speed to stabilize
        JSR FULLCYCLE           ; Synchronize with full cycle

NOTSTART: LDY #31               ; Try to detect the much shorter
        JSR CMPLEVEL            ; start bit
        BCS NOTSTART            ; Start bit not detected yet!

        JSR CMPLEVEL            ; Wait for 2nd phase of start bit

        LDY #58                 ; Set threshold value in middle
RDBYTE: LDX #8                  ; Receiver 8 bits
RDBIT:  PHA
        JSR FULLCYCLE           ; Detect a full cycle
        PLA
        ROL                     ; Roll new bit into result
        LDY #57                 ; Set threshold value in middle
        DEX                     ; Decrement bit counter
        BNE RDBIT               ; Read next bit!
        STA (HEX2L,X)           ; Save new byte

        JSR INCADDR             ; Increment address
        LDY #53                 ; Compensate threshold with workload
        BCC RDBYTE              ; Do next byte if not done yet!
        BCS RESTIDX             ; Always taken! Restore parse index

FULLCYCLE: JSR CMPLEVEL         ; Wait for two level changes
CMPLEVEL: DEY                   ; Decrement time counter
        LDA TAPEIN              ; Get Tape In data
        CMP LASTSTATE           ; Same as before?
        BEQ CMPLEVEL            ; Yes!
        STA LASTSTATE           ; Save new data

        CPY #128                ; Compare threshold
        RTS

;-------------------------------------------------------------------------
; Write header to tape
;
; The header consists of an asymmetric cycle, starting with one phase of
; approximately (66+47)x5=565us, followed by a second phase of
; approximately (44+47)x5=455us.
; Total cycle duration is approximately 1020us ~ 1kHz. The actual
; frequency will be a bit lower because of the additional workload between
; the two loops.
; The header ends with a short phase of (30+47)x5=385us and a normal
; phase of (44+47)x5=455us. This start bit must be detected by the read
; routine to trigger the reading of the actual data.
;-------------------------------------------------------------------------

WHEADER: STX SAVEINDEX          ; Save index in input line
HCOUNT: LDY #66                 ; Extra long delay
        JSR WDELAY              ; CY is constantly 1, writing a 1
        BNE HCOUNT              ; Do this 64 * 256 time!
        ADC #<-2                ; Decrement A (CY=1 all the time)
        BCS HCOUNT              ; Not all done!
        LDY #30                 ; Write a final short bit (start)
;
;-------------------------------------------------------------------------
; Write a full bit cycle
;
; Upon entry Y contains a compensated value for the first phase of 0
; bit length. All subsequent loops don’t have to be time compensated.
;-------------------------------------------------------------------------

WRITEBIT: JSR WDELAY            ; Do two equal phases
        LDY #44                 ; Load 250us counter - compensation

WDELAY: DEY                     ; Delay 250us (one phase of 2kHz)
        BNE WDELAY
        BCC WRITE1              ; Write a '1' (2kHz)

        LDY #47                 ; Additional delay for '0' (1kHz)
WDELAY0: DEY                    ; (delay 250us)
        BNE WDELAY0

WRITE1: LDY FLIP,X              ; Flip the output bit
        LDY #41                 ; Reload 250us cntr (compensation)
        DEX                     ; Decrement bit counter
        RTS

;-------------------------------------------------------------------------
; Increment current address and compare with last address
;-------------------------------------------------------------------------

INCADDR: LDA HEX2L              ; Compare current address with
        CMP HEX1L               ; end address
        LDA HEX2H
        SBC HEX1H
        INC HEX2L               ; And increment current address
        BNE NOCARRY             ; No carry to MSB!
        INC HEX2H
NOCARRY: RTS

;-------------------------------------------------------------------------
