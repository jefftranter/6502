; Example of programmming real-time clock using a real-time clock
; module based on the Dallas Semiconductor DS1302 timekeeping chip
; connected to the 6522 VIA.
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
; You will also need a pullup resistor connected from PB1 to VCC;
; suggested value 10Kohms.
;
; Notes:
; 1. See the DS1302 datasheet for details.
; 2. No support yet for RAM functions.
; 3. No support yet for burst mode.

; Constants

        VIA     = $8000         ; 6522 VIA base address
        ORB     = VIA+0         ; ORB register
        DDRB    = VIA+2         ; DDRB register

        .org    $1000           ; Start address

        RST     = $01           ; Reset bit in VIA
        CLK     = $02           ; CLK bit in VIA
        DAT     = $04           ; DAT bit in VIA

        PRBYTE  = $EC8F         ; Print A in hex
        MONCOUT = $FF3B         ; Output char in A
        MONRDKEY = $FF4A        ; Console in routine

; Code

; Enable code below if you want to initially set the date.

.if 1

START:  lda     #$07            ; Select register 7 (control)
        sta     REGNUM
        lda     #$00            ; Turn off write protect
        sta     REGDATA
        jsr     WRITE           ; Call write routine
        lda     #$06            ; Select register 6 (year)
        sta     REGNUM
        lda     #$23            ; Year 2023
        sta     REGDATA
        jsr     WRITE           ; Call write routine
        lda     #$04            ; Select register 4 (month)
        sta     REGNUM
        lda     #$03            ; Month 03
        sta     REGDATA
        jsr     WRITE           ; Call write routine
        lda     #$03            ; Select register 3 (day)
        sta     REGNUM
        lda     #$13            ; Day 13
        sta     REGDATA
        jsr     WRITE           ; Call write routine

        lda     #$02            ; Select register 2 (hours)
        sta     REGNUM
        lda     #$22            ; Hour 22
        sta     REGDATA
        jsr     WRITE           ; Call write routine

        lda     #$01            ; Select register 1 (minutes)
        sta     REGNUM
        lda     #$30            ; Minutes 30
        sta     REGDATA
        jsr     WRITE           ; Call write routine

        lda     #$00            ; Select register 0 (seconds)
        sta     REGNUM
        lda     #$00            ; Seconds 0
        sta     REGDATA
        jsr     WRITE           ; Call write routine

.endif

DISP:   lda     #$02            ; Select register 2 (hours)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        and     #$3F            ; Mask out hours
        jsr     PRBYTE          ; Print it
        lda     #':'
        jsr     MONCOUT
        lda     #$01            ; Select register 1 (minutes)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        jsr     PRBYTE          ; Print it
        lda     #':'
        jsr     MONCOUT
        lda     #$00            ; Select register 1 (seconds)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        jsr     PRBYTE          ; Print it
        lda     #' '
        jsr     MONCOUT
        lda     #$03            ; Select register 3 (date)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        jsr     PRBYTE          ; Print it
        lda     #'/'
        jsr     MONCOUT
        lda     #$04            ; Select register 4 (month)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        jsr     PRBYTE          ; Print it
        lda     #'/'
        jsr     MONCOUT
        lda     #$06            ; Select register 6 (year)
        sta     REGNUM
        jsr     READ            ; Call read routine
        lda     REGDATA         ; Get data read
        jsr     PRBYTE          ; Print it
        lda     #$0D            ; Print CR
        jsr     MONCOUT
        lda     #$0A            ; Print LF
        jsr     MONCOUT
        ldy     #$00            ; Delay between reads
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
        jsr     MONRDKEY        ; Key pressed?
        bcs     retn            ; If so, branch
        jmp     DISP            ; Otherwise keep looping
retn:   brk                     ; Return to monitor

; Read data in register REGNUM and return in REGDAT. Changes value of
; REGNUM.

READ:   lda     #RST|CLK|DAT    ; Set RST, CLK, and DAT as outputs, others as inputs
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
s0:     ora     #RST            ; Always want RST high
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        dex                     ; Decrement bit count
        bne     nxt             ; Continue sending bits if not done
        lda     #$00            ; Set DAT line to 1 for RAM or 0 for clock register
        ora     #RST
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        lda     #DAT            ; Set DAT line to 1
        ora     #RST
        ora     #CLK            ; Toggle CLK high and then low
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
        rts                     ; Done

; Write data stored in REGDAT to register REGNUM. Changes value of
; REGNUM.

WRITE:  lda     #RST|CLK|DAT    ; Set RST, CLK, and DAT as outputs, others as inputs
        sta     DDRB            ; Write to DDRB
        lda     #$00            ; Set CLK and RST low
        sta     ORB
        nop                     ; Short delay
        lda     #RST            ; Set RST high
        sta     ORB             ; Note that DAT line is set to 0 (write)
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
ws0:    ora     #RST            ; Always want RST high
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        dex                     ; Decrement bit count
        bne     wnxt            ; Continue sending bits if not done
        lda     #$00            ; Set DAT line to 1 for RAM or 0 for clock register
        ora     #RST
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        lda     #DAT            ; Set DAT line to 1
        ora     #RST
        ora     #CLK            ; Toggle CLK high and then low
        sta     ORB
        eor     #CLK
        sta     ORB
        ldx     #8              ; Number of bits to write
        lda     #RST|CLK        ; Toggle CLK high
wrl:    lsr     REGDATA         ; Shift bit into carry
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
