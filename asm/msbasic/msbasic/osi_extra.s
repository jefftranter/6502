.segment "EXTRA"

MONRDKEY:
        LDA     $D011           ; keyboard status
        BPL     MONRDKEY        ; branch until key pressed
        LDA     $D010           ; keyboard data
        RTS

; LOAD and SAVE commands will call into CFFA1 flash interface if one
; is present.
LOAD:
SAVE:
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
NoCFFA1:
	RTS
