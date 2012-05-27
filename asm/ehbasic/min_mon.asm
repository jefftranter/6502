
; minimal monitor for EhBASIC and 6502 simulator V1.05
; Modified to support the Replica 1 by Jeff Tranter <tranter@pobox.com>

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

	.include "basic.asm"

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

IO_AREA	= $F000		; set I/O area for this monitor

ACIAsimwr	= IO_AREA+$01	; simulated ACIA write port
ACIAsimrd	= IO_AREA+$04	; simulated ACIA read port

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

;	.org	$FF80			; pretend this is in a 1/8K ROM

; reset vector points here

RES_vec
	CLD				; clear decimal mode
	LDX	#$FF			; empty stack
	TXS				; set the stack

; set up vectors and interrupt code, copy them to page 2

	LDY	#END_CODE-LAB_vec	; set index/count
LAB_stlp
	LDA	LAB_vec-1,Y		; get byte from interrupt code
	STA	VEC_IN-1,Y		; save to RAM
	DEY				; decrement index/count
	BNE	LAB_stlp		; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
	LDA	LAB_mess,Y		; get byte from sign on message
	BEQ	LAB_nokey		; exit loop if done

	JSR	V_OUTP		; output character
	INY				; increment index
	BNE	LAB_signon		; loop, branch always

LAB_nokey
	JSR	V_INPT		; call scan input device
	BCC	LAB_nokey		; loop if no key

	AND	#$DF			; mask xx0x xxxx, ensure upper case
	CMP	#'W'			; compare with [W]arm start
	BEQ	LAB_dowarm		; branch if [W]arm start

	CMP	#'C'			; compare with [C]old start
	BNE	RES_vec		; loop if not [C]old start

	JMP	LAB_COLD		; do EhBASIC cold start

LAB_dowarm
	JMP	LAB_WARM		; do EhBASIC warm start

; byte out to Replica 1/Apple 1 screen

ACIAout
	BIT	$D012
	BMI	ACIAout
	STA	$D012
	RTS

; byte in from Replica 1/Apple 1 keyboard

ACIAin
	LDA	$D011
	BPL	LAB_nobyw		; branch if no byte waiting

	LDA	$D010
	AND	#$7F			; clear high bit
	SEC				; flag byte received
	RTS

LAB_nobyw
	CLC				; flag no byte received
        RTS

; LOAD and SAVE commands will call into CFFA1 flash interface if one
; is present. Not sure how to determine range of memory to save and
; load. For now, can save from Ram_base to Ram_top. Future enhancement
; would be to pass filename on command line and call read/write
; routines in CFFA1.
LOAD
SAVE

; Call CFFA1 flash interface menu
; The documented way to check for a CFFA1 is to check for two ID bytes.
; The documentation says it is addresses $AFFC and $AFFD but the firmware
; actually uses addresses $AFDC and $AFDD. Further, my CFFA1 board did
; not have these locations programmed even though firmware on CD-ROM did.
; I manually wrote these bytes to my EEPROM.

        LDA     $AFDC                   ; First CFFA1 ID byte
        CMP     #$CF                    ; Should contain $CF
        BNE     NoCFFA1
        LDA     $AFDD                   ; First CFFA1 ID byte
        CMP     #$FA                    ; Should contain $FA
        BNE     NoCFFA1
        JSR     $9006                   ; Jump to CFFA1 menu, will return when done.
NoCFFA1
	RTS

; vector tables

LAB_vec
	.word	ACIAin		; byte in from simulated ACIA
	.word	ACIAout		; byte out to simulated ACIA
	.word	LOAD		; load vector for EhBASIC
	.word	SAVE		; save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	PHA				; save A
	LDA	IrqBase		; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		; OR the original back in
	STA	IrqBase		; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE
	PHA				; save A
	LDA	NmiBase		; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		; OR the original back in
	STA	NmiBase		; save the new NMI flag byte
	PLA				; restore A
	RTI

END_CODE

LAB_mess
	.byte	$0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
					; sign on string

; system vectors

	.org	$FFFA

	.word	NMI_vec		; NMI vector
	.word	RES_vec		; RESET vector
	.word	IRQ_vec		; IRQ vector

