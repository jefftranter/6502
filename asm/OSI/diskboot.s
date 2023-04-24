; This listing and commentary on how the ROM disk boot routine works was
; taken from an article in Peek[65] magazine, July 1983, Vol. 4 No. 7.
;
; THE WORKINGS OF THE CIP DISK BOOT ROUTINE
; By: Jim McConkey
; 7304 Centennial Rd.
; Rockville, MD 20855
;
; When you answer the D/C/W/M? prompt with a "D" the processor jumps
; to the disk boot routine at $FC00. The JSR at $FC00 goes to the main
; disk boot routine at $FC0C which reads a starting address from the
; disk and places this address in $FD,$FE. The number of 256 byte
; sectors is then fetched and placed in $FF. The code on track 0 is then
; loaded starting at the address specified by $FD, $FE and is then run
; by the indirect jump at $FC03.
;
; Data communication to and from the disk is made through a 6850
; asynchronous communications interface adapter (ACIA) which is located
; at $C010-$C011. $C010 functions as both a write-only control register
; and a read-only status register. Data is passed via $C011.
;
; Control signals are sent to and received from the disk drive via a
; 6B21 peripheral interface adapter (PIA) located at $C000-$C003. The
; PIA provides two 8-bit I/O ports and actually contains 6 registers.
; How can 6 registers be accessed when the device only occupies 4 memory
; locations you ask? Each port has associated with it 3 registers; a
; control register, a data direction register and a data register. When
; bit 2 of the control register ($C001,$C003) is set, $C000 and $C002
; act as data direction registers. When this bit is reset, they act as
; data registers. By setting bits in the data direction registers to 1,
; the corresponding data bits are configured as outputs. Likewise, by
; reseting data direction register bits, the corresponding data bits are
; configured as inputs. An I/O word thus programmed need not be all
; inputs or all outputs but may be mixed.
;
; The code from $FC0C to $FC19 configures PA0-PA7 of the PIA to be all
; inputs and PB0-PB7 to be all outputs. The STY at $FC23 resets all the
; control lines, after which a jump is made to $FC33. The code from here
; to $FC4C moves the head, in this case toward the spindle. The
; (unconditional) branch at $FC4B goes back to $FC2A which examines the
; TRACK 0 signal from the drive. If it is not zero, meaning that the
; head is not at track 0, the direction is reversed and the head is
; moved outward toward track 0.
;
; If the head is at track 0, control is passed to the code at $FC4D,
; where the signal is given for the head to be loaded. (Yes, you heard
; it right! Why the disk boot loads the head but OS-65D doesn't is
; beyond me.) The JSR at $FC52 executes a subroutine at $FC91-$FC9B,
; which is a simple time delay whose time can be set via the X register.
; In this case, the delay is set for about 158 msec which allows the head
; to settle after being loaded.
;
; Upon returning to $FC55 the INDEX signal from the drive is looked for,
; marking the beginning of the index hole. Once the hole is found, the
; code from $FC5A to $FC5E waits for it to pass.
;
; The code from $FC61 to $FC68 then rests the ACIA and configures
; it for 8 bits + 1 stop bit with even parity.
;
; The JSR at $FC69 goes to a subroutine at $FC9C-$FCA5 which waits till
; the ACIA data register is full (as indicated by the status register)
; and then gets the byte of data from the data register and returns with
; the data in A.
;
; The first two bytes of data fetched from track 0 indicate the address
; at which the data fetched from the disk should be stored. The address
; is stored in $FD,$FE. The third byte fetched is the number of 256 byte
; sectors of data stored on track 0. This number is stored in $FF.
;
; The LDY at $FC79 initializes the byte counter. A byte is fetched and
; stored by the indirect indexed STA at $FC7E. The BNE at $FC81 checks
; if all 256 bytes of the current sector have been fetched. If not, the
; code loops back to $FC7B to get another byte. When the sector fetching
; is complete, control passes to $FC83 which increments the sector
; pointer and checks if all sectors have been fetched. Again, the
; program loops until all sectors have been completely fetched.
;
; Finally. the starting is restored by the 5TX at $FC89 and the ACIA is
; reset by $FC8B-$FC8F. The RTS at $FC90 returns to $FC03 where the code
; that was just loaded from track 0 is executed by the indirect JMP. In
; the case of HEXDOS, the code from track 0 comprises the entire
; operating system. For OS-65D I imagine the code is a more extensive
; disk boot which allows for a multiple track load.


KBD     = $DF00         ;polled keyboard
VM      = $FE00         ;machine language monitor
ACIA    = $F000         ;serial console

CRA     = $C001         ;control register for PA0-PA7
DDRA    = $C000         ;data direction register for PA0-PA7
DRA     = $C000         ;data register for PA0-PA7
CRB     = $C003         ;control register for PB0-PB7
DDRB    = $C002         ;data direction register for PB0-PB7
DRB     = $C002         ;data register for PB0-PB7
ACR     = $C010         ;ACIA control register
ASR     = $C010         ;ACIA status register
ADR     = $C011         ;ACIA data register

        *=$FC00

DISK    JSR BOOT        ;load track 0
        JMP ($FD)       ;run
        JSR BOOT        ;reload track 0
        JMP VM          ;goto ML monitor
BOOT    LDY #$00
        STY CRA         ;address DDR A
        STY DDRA        ;PA0-PA7 all inputs
        LDX #$04
        STX CRA         ;address DR A
        STY CRB         ;address DDR B
        DEY             ;Y=11111111
        STY DDRB        ;PB0-PB7 all outputs
        STX CRB         ;address DR B
        STY DRB         ;reset all control lines
        LDA #$FB        ;mask for step-in
        BNE MOVEHD      ;goto MOVEHD
CKTRK   LDA #$02        ;mask from TRACK0
        BIT DRA         ;check TRACK 0
        BEQ TRK0        ;track 0
SEEKTK0 LDA #$FF        ;another track
MOVEHD  STA DRB         ;set direction controls
        JSR RET         ;waste 12usec
        AND #$F7        ;set step flag
        STA DRB         ;step
        JSR RET         ;waste 12usec
        ORA #$08
        STA DRB         ;reset all controls
        LDX #$18        ;set delay time
        JSR DELAY       ;waste 30msec to allow
                        ;head to settle
        BEQ CKTRK       ;goto CKTRK
TRK0    LDX #$7F
        STX DRB         ;load head
        JSR DELAY       ;let head settle
INDEX   LDA DRA         ;check for index hole
        BMI INDEX       ;if not found, keep looking
HOLE    LDA DRA
        BPL HOLE        ;wait till end of hole
        LDA #$03
        STA ACR         ;reset ACIA
        LDA #$58        ;configure ACIA
        STA ACR
        JSR FETCH       ;get high byte
        STA $FE         ;and store
        TAX             ;save also in X
        JSR FETCH       ;get low byte
        STA $FD         ;and save
        JSR FETCH       ;get number of sectors
        STA $FF         ;and save
        LDY #$00        ;init byte counter
ANOTHER JSR FETCH       ;get a byte
        STA ($FD),Y     ;store
        INY             ;done yet?
        BNE ANOTHER     ;no, get some more
        INC $FE         ;yes, point to next sector
        DEC $FF         ;done yet?
        BNE ANOTHER     ;no, get next sector
        STX $FE         ;yes, restore address
        LDA #$FF
        STA DRB         ;reset all controls
        RTS
DELAY   LDY #$F8        ;init inner loop count
LOOP    DEY             ;inner loop done yet?
        BNE LOOP        ;no, keep looping
        EOR $FF,X       ;yes
        DEX             ;outer loop done yet?
        BNE DELAY       ;no, wait some_more
        RTS             ;yes, done.

FETCH   LDA ASR         ;look at ACIA status
        LSR A           ;C=data buffer full
        BCC FETCH       ;not full yet, try again
        LDA ADR         ;ready, get byte
RET     RTS             ;return


; Below routines are in the same ROM but are not related to disk boot.

        LDA #$03
        STA ACIA
        LDA #$11
        STA ACIA
        RTS

        PHA
LFCB2:  LDA ACIA
        LSR A
        LSR A
        BCC LFCB2
        PLA
        STA ACIA+1
        RTS

        EOR #$FF
        STA KBD
        EOR #$FF
        RTS

        PHA
        JSR LFCCF
        TAX
        PLA
        DEX
        INX
        RTS

LFCCF:  LDA KBD
        EOR #$FF
        RTS

        .RES $FD00-*,$FF
