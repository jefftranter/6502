.segment "EXTRA"

MONRDKEY:
        LDA     $D011           ; keyboard status
        BPL     MONRDKEY        ; branch until key pressed
        LDA     $D010           ; keyboard data
        RTS
LOAD:
SAVE:
        RTS     ; not implemented
