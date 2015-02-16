
; minimal monitor for EhBASIC and 6502 simulator V1.05

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

	.include "basic.asm"

; put the IRQ and MNI code in RAM so that it can be changed

SAVE_X = $DE		; For saving registers
SAVE_Y = $DF		; For saving registers

IRQ_vec	= VEC_SV+2		; IRQ code vector
NMI_vec	= IRQ_vec+$0A	; NMI code vector

; setup for the 6502 simulator environment

IO_AREA	= $F000		; set I/O area for this monitor

;ACIAsimwr	= IO_AREA+$01	; simulated ACIA write port
;ACIAsimrd	= IO_AREA+$04	; simulated ACIA read port

KBD             = $DF00    ; OSI polled keyboard register

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

;	*=	$FF80			; pretend this is in a 1/8K ROM

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

        LDA #$65                        ; Set OSI ROM cursor position to home
        STA $0200

LAB_signon
	LDA	LAB_mess,Y		; get byte from sign on message
	BEQ	LAB_nokey		; exit loop if done

	JSR	V_OUTP		        ; output character
	INY				; increment index
	BNE	LAB_signon		; loop, branch always

LAB_nokey
	JSR	V_INPT                  ; call scan input device
	BCC	LAB_nokey		; loop if no key

	AND	#$DF			; mask xx0x xxxx, ensure upper case

	CMP	#'W'			; compare with [W]arm start
	BEQ	LAB_dowarm		; branch if [W]arm start

	CMP	#'C'			; compare with [C]old start
	BNE	RES_vec		        ; loop if not [C]old start

	JMP	LAB_COLD		; do EhBASIC cold start

LAB_dowarm
	JMP	LAB_WARM		; do EhBASIC warm start

; byte out to simulated ACIA

ACIAout
        STX     SAVE_X                  ; Preserve X register
        STY     SAVE_Y                  ; Preserve Y register
	JSR	$BF2D   		; OSI character out routine
        LDX     SAVE_X                  ; Restore X
        LDY     SAVE_Y                  ; Restore Y
	RTS

; byte in from simulated ACIA

ACIAin
        STX     SAVE_X                  ; Preserve X register
        STY     SAVE_Y                  ; Preserve Y register
                                        ; First see if a key was pressed
        LDA     #%11111110              ; Select first keyboard row
scan:
        STA     KBD                     ; Select keyboard row
        TAX                             ; Save A
        LDA     KBD                     ; Read keyboard columns
        ORA     #$01                    ; Mask out lsb (Shift Lock), since we ignore it
        CMP     #$FF                    ; No keys pressed?
        BNE     keypressed
        TXA                             ; Restore A
        SEC                             ; Want to shift in ones
        ROL     A                       ; Rotate row select to next bit position
        CMP     #$FF                    ; Done?
        BNE     scan                    ; If not, continue

        ldx     #'N'
        stx     $D0A5

        LDX     SAVE_X                  ; Restore X
        LDY     SAVE_Y                  ; Restore Y
        CLC                             ; Indicate key not pressed
        RTS                             ; And return
keypressed:
        JSR     $FD00                   ; OSI character in routine

        ldx     #'Y'
        stx     $D0A5

        LDX     SAVE_X                  ; Restore X
        LDY     SAVE_Y                  ; Restore Y
        SEC                             ; Indicate key was pressed
        RTS                             ; And return

no_load				        ; empty load vector for EhBASIC
no_save				        ; empty save vector for EhBASIC
	RTS

; vector tables

LAB_vec
	.word	ACIAin                  ; byte in from simulated ACIA
	.word	ACIAout		        ; byte out to simulated ACIA
	.word	no_load		        ; null load vector for EhBASIC
	.word	no_save		        ; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
	PHA				; save A
	LDA	IrqBase		        ; get the IRQ flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	IrqBase		        ; OR the original back in
	STA	IrqBase		        ; save the new IRQ flag byte
	PLA				; restore A
	RTI

; EhBASIC NMI support

NMI_CODE
	PHA				; save A
	LDA	NmiBase		        ; get the NMI flag byte
	LSR				; shift the set b7 to b6, and on down ...
	ORA	NmiBase		        ; OR the original back in
	STA	NmiBase		        ; save the new NMI flag byte
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
