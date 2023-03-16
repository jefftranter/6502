; Example of programming real-time clock using a real-time clock
; module based on the Dallas Semiconductor DS1302 timekeeping chip
; connected to the 6522 VIA.
;
; Optionally sets date and time.
; Displays clock and RAM values continuously until a key is pressed, e.g.
; Clock: 08:30:00 14/03/2023
; RAM: AA 55 00 FF FE 5A 90 FF E3 0F 34 FA 7F EF FC 16 E6 FA 71 3F EF BE 72 DA FF DE 6F F7 EE CB 62
;
; Jeff Tranter <tranter@pobox.com>
;
; Hardware connections between 6522 VIA (via the parallel port
; connector H3) and DS1302 clock module:
;
; SBC  DS1302
; ---  ------
; VCC  VCC
; GND  GND
; PB0  RST
; PB1  CLK
; PB2  DAT
;
; You need to use a clock module that is 5V tolerant. You will also
; need a pullup resistor connected from PB1 to VCC; suggested value
; 10Kohms.
;
; Notes:
; 1. See the DS1302 datasheet for details.
; 2. No support for burst mode.
; 3. Could potentially use 6522 shift register and handshaking pins, but
;    this was done with bit-banging to keep it more portable and generic.

; Constants

        VIA     = $8000         ; 6522 VIA base address
        ORB     = VIA+0         ; ORB register
        DDRB    = VIA+2         ; DDRB register

        .org    $1000           ; Start address

        RST     = $01           ; Reset bit in VIA
        CLK     = $02           ; CLK bit in VIA
        DAT     = $04           ; DAT bit in VIA

        CR      = $0D           ; Carriage Return
        LF      = $0A           ; Line Feed

        PRBYTE  = $EC8F         ; Print A in hex
        MONCOUT = $FF3B         ; Output char in A
        MONRDKEY = $FF4A        ; Console in routine
        IMPRINT  = $EC5E        ; Embedded string printer

; Code

START:  cld                     ; Ensure in binary mode
        ldx     #$FF            ; Set up stack
        txs

; Enable code below if you want to initially set the date and time (to
; the values below).

.if 0
        ldx     #$07            ; Select register 7 (control)
        lda     #$00            ; Turn off write protect
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$06            ; Select register 6 (year)
        lda     #$23            ; Year 2023
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$04            ; Select register 4 (month)
        lda     #$03            ; Month 03
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$03            ; Select register 3 (day)
        lda     #$14            ; Day 14
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$02            ; Select register 2 (hours)
        lda     #$17            ; Hour 17
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$01            ; Select register 1 (minutes)
        lda     #$00            ; Minutes 0
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$00            ; Select register 0 (seconds)
        lda     #$00            ; Seconds 0
        clc                     ; Select clock register
        jsr     WRITE           ; Call write routine

        ldx     #$00            ; Select RAM location 0
        lda     #$AA            ; Data to write
        sec                     ; Select RAM
        jsr     WRITE           ; Call write routine

        ldx     #$01            ; Select RAM location 1
        lda     #$55            ; Data to write
        sec                     ; Select RAM
        jsr     WRITE           ; Call write routine

        ldx     #$02            ; Select RAM location 2
        lda     #$00            ; Data to write
        sec                     ; Select RAM
        jsr     WRITE           ; Call write routine

        ldx     #$03            ; Select RAM location 3
        lda     #$FF            ; Data to write
        sec                     ; Select RAM
        jsr     WRITE           ; Call write routine

.endif

DISP:   jsr     IMPRINT
        .byte   "Clock: ", 0
        ldx     #$02            ; Select register 2 (hours)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        and     #$3F            ; Mask out hours
        jsr     PRBYTE          ; Print it
        lda     #':'
        jsr     MONCOUT
        ldx     #$01            ; Select register 1 (minutes)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        lda     #':'
        jsr     MONCOUT
        ldx     #$00            ; Select register 1 (seconds)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        lda     #' '
        jsr     MONCOUT
        ldx     #$03            ; Select register 3 (date)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        lda     #'/'
        jsr     MONCOUT
        ldx     #$04            ; Select register 4 (month)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        lda     #'/'
        jsr     MONCOUT
        lda     #'2'            ; Print first two fixed digits of year
        jsr     MONCOUT
        lda     #'0'
        jsr     MONCOUT
        ldx     #$06            ; Select register 6 (year)
        clc                     ; Select clock register
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        lda     #CR             ; Print CR
        jsr     MONCOUT
        lda     #LF             ; Print LF
        jsr     MONCOUT

        jsr     IMPRINT
        .byte   "RAM:", 0
        ldx     #0              ; Initial register number
rlp:    lda     #' '
        jsr     MONCOUT
        txa                     ; Save X
        pha
        jsr     READ            ; Call read routine
        jsr     PRBYTE          ; Print it
        pla                     ; Restore X
        tax
        inx                     ; Increment register number
        cpx     #31             ; Last register? (Note 31, not 32 RAM locations)
        bne     rlp

        lda     #CR             ; Print CR
        jsr     MONCOUT
        lda     #LF             ; Print LF
        jsr     MONCOUT

        jsr     DELAY           ; Delay between updates
        jsr     MONRDKEY        ; Key pressed?
        bcs     retn            ; If so, branch
        jmp     DISP            ; Otherwise keep looping
retn:   brk                     ; Return to monitor


; DELAY: Fixed delay of approx. 1 sec (2 MHz clock).

DELAY:  ldy     #$00
outer:  ldx     #$00
inner:  nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        dex
        bne     inner
        dey
        bne     outer
        rts


; READ: Read data in clock register. Pass register number in X. Set
; carry bit to read RAM, clear to read clock register. Returns
; register data in A.

READ:   stx     REGNUM          ; Save values passed to routine
        bcs     ram1
        lda     #$00
        beq     nxt1            ; Branch always
ram1:   lda     #DAT
nxt1:   sta     RAMCLK
        lda     #RST|CLK|DAT    ; Set RST, CLK, and DAT as outputs, others as inputs
        sta     DDRB            ; Write to DDRB
        lda     #$00            ; Set CLK and RST low
        sta     ORB
        nop                     ; Short delay
        lda     #RST            ; Set RST high
        sta     ORB
        nop                     ; Short delay
        ora     #DAT            ; Set DAT line to 1 (read)
        sta     ORB
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        ldx     #5              ; Number of address bits to send
nxt:    and     #<~DAT          ; Clear data bit
        lsr     REGNUM          ; Shift bit into carry
        bcc     s0              ; Branch to send 0, fall through to send 1
        ora     #DAT            ; Set data bit to 1
s0:     ora     #RST|CLK        ; Always want RST high. Toggle CLK high and then low.
        sta     ORB
        eor     #CLK
        sta     ORB
        dex                     ; Decrement bit count
        bne     nxt             ; Continue sending bits if not done
        lda     RAMCLK          ; Set DAT bit for RAM or clock mode
        ora     #RST|CLK        ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        lda     #DAT            ; Set DAT line to 1
        ora     #RST|CLK        ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        lda     #RST|CLK        ; Now set DAT as input
        sta     DDRB            ; Write to DDRB
        lda     #$00
        sta     REGDATA         ; Initially clear read data
        ldx     #8              ; Number of bits to read
rl:     lsr     REGDATA         ; Shift previous value
        lda     #RST|CLK        ; Toggle CLK high
        sta     ORB
        lda     #DAT            ; Read data bit 0 on DAT line
        bit     ORB             ; Is data bit set?
        beq     r0              ; Branch if zero
        lda     #$80
        ora     REGDATA         ; Set bit
        sta     REGDATA
r0:     lda     #RST            ; Toggle CLK low
        sta     ORB
        dex                     ; Decrement bit count
        bne     rl              ; Do next bit if not done
        lda     #CLK|RST        ; Toggle CLK high
        sta     ORB
        lda     #CLK            ; Set RST low
        sta     ORB
        lda     REGDATA         ; Return value
        rts                     ; Done


; WRITE: Write data to clock register. Pass register number in X and
; register data in A. Set carry bit to write RAM, clear to write clock
; register.

WRITE:  stx     REGNUM          ; Save values passed to routine
        sta     REGDATA
        bcs     ram2
        lda     #$00
        beq     nxt2            ; Branch always
ram2:   lda     #DAT
nxt2:   sta     RAMCLK
        lda     #RST|CLK|DAT    ; Set RST, CLK, and DAT as outputs, others as inputs
        sta     DDRB            ; Write to DDRB
        lda     #$00            ; Set CLK and RST low
        sta     ORB
        nop                     ; Short delay
        lda     #RST            ; Set RST high, DAT line low (write)
        sta     ORB
        nop                     ; Short delay
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        ldx     #5              ; Number of address bits to send
wnxt:   and     #<~DAT          ; Clear data bit
        lsr     REGNUM          ; Shift bit into carry
        bcc     ws0             ; Branch to send 0, fall through to send 1
        ora     #DAT            ; Set data bit to 1
ws0:    ora     #RST|CLK        ; Always want RST high. Toggle CLK high and then low.
        sta     ORB
        eor     #CLK
        sta     ORB
        dex                     ; Decrement bit count
        bne     wnxt            ; Continue sending bits if not done
        lda     RAMCLK          ; Set DAT bit for RAM or clock mode
        ora     #RST|CLK        ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        lda     #DAT            ; Set DAT line to 1
        ora     #RST|CLK        ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        ldx     #8              ; Number of bits to write
wrl:    lda     #RST|CLK        ; Toggle CLK high
        and     #<~DAT          ; Clear data bit
        lsr     REGDATA         ; Shift bit into carry
        bcc     w0
        ora     #DAT            ; Set data bit
w0:     sta     ORB
        eor     #CLK            ; Toggle CLK low
        sta     ORB
        dex                     ; Decrement bit count
        bne     wrl             ; Do next bit if not done
        lda     #CLK|RST        ; Toggle CLK high
        sta     ORB
        lda     #CLK            ; Set RST low
        sta     ORB
        rts                     ; Done

; Variables

REGNUM:
        .res    1               ; Register to read/write
REGDATA:
        .res    1               ; Register data to read/write
RAMCLK:
        .res    1               ; Set to 1 to read/write RAM, 0 for clock registers
