; Page zero addresses

DCDLO   =       $00             ; Application Address Low
DCDHI   =       $03             ; Application Address High

PARAM0  =       $B0             ; Parameter 0 is usually the COMMAND CODE
PARAM1  =       $B1             ; Parameter 1 is usually DATA
PARAM2  =       $B2             ; Parameter 2 is usually DATA
PARAM3  =       $B3             ; Parameter 3 is usually DATA
ADRLO   =       $B4             ; Low Address pointer for Indirect Address
ADRHI   =       $B5             ; High Address pointer for Indirect Address
PNTR    =       $B6             ; Temporary Pointer Storage
STEPNO  =       $B7             ; Number of NEXT PLEASE Step
STEPLO  =       $B8             ; Low Address of Current PLEASE Step
STEPHI  =       $B9             ; High Address of Current PLEASE Step
TRANLO  =       $BA             ; Temporary Transfer Pointer to PLEASE Function
TRANHI  =       $BB             ; Temporary Transfer Pointer to PLEASE Function
PLACE   =       $BB             ; Alternate name
FUNTBL  =       $BC             ; Low Address of PLEASE Function Table
FUNTBH  =       $BD             ; High Address of PLEASE Function Table
PTEMP0  =       $BE             ; PLEASE Temporary Storage
PTEMP1  =       $BF             ; PLEASE Temporary Storage
TEMP1   =       PTEMP0
TEMP2   =       PTEMP1

THOUS   =       $C0             ; Thousands and Tens of Thousands of Seconds
TENS    =       $C1             ; Tens and Hundreds of Seconds
TENTHS  =       $C2             ; Tenths and Seconds
MILLI   =       $C3             ; Thousandths and hundredths of Seconds
HOUR    =       $C4             ; Hour portion of 24 Hour Clock
MINUTE  =       $C5             ; Minute portion of 24 Hour Clock
SECOND  =       $C6             ; Second portion of 24 Hour Clock
ONESEC  =       $C7             ; Counter for One Second

DSP0    =       $C8             ; Display position 0 (Leftmost Digit)
DSP1    =       $C9             ; Display position 1
DSP2    =       $CA             ; Display position 2
DSP3    =       $CB             ; Display position 3
DSP4    =       $CC             ; Display position 4
DSP5    =       $CD             ; Display position 5 (Rightmost Digit)
DSPLO   =       $CE             ; Low Address of Display Buffer (Usually = DSP0 = C8)
DSPHI   =       $CF             ; High Address of Display Buffer (Usually = DSP0 = 00)

DCONLO  =       $D0             ; Display Conversion Table Low Address
DCONHI  =       $D1             ; Display Conversion Table High Address
DTABLO  =       DCONLO
DTABHI  =       DCONHI
HEXDEC  =       HEXLO
HEXLO   =       $D2             ; Hexadecimal (and Decimal) Conversion Table Low Address = E7
HEXHI   =       $D3             ; Hexadecimal (and Decimal) Conversion Table High Address = 17
ALPHLO  =       $D4             ; Alphabetic Conversion Table Low Address (usually = F0)
ALPHHI  =       $D5             ; Alphabetic Conversion Table High Address (usually = 03)
XTABLE  =       $D6             ; Used by Conversion Routine to Point to HEX or ALPHA Table
TEMP    =       $D7             ; General Purpose Temporary Save Location
LIMIT   =       $D8             ; Uses by Conversion Routine.  General Purposes Register
DSPPOS  =       $D9             ; Executive Pointer to Current Display Position
CURPNT  =       $DA             ; Used by Input Routines as Current Data Pointer.
CHAR    =       $DB             ; Save location for Input Character
CTABLO  =       $DC             ; Command Table Low Address (usually = A0)
CTABHI  =       $DD             ; Command Table High Address (usually = 00)
KEYTST  =       $DE             ; Used by Executive as part of Keyboard Input
KEYVAL  =       $DF             ; Contains Last Character if Input String

BUF0    =       $E0             ; General Purpose Buffer
BUF1    =       $E1
BUF2    =       $E2
BUF3    =       $E3
BUF4    =       $E4
BUF5    =       $E5

ALT0    =       $E6             ; Alternate General Purposes Buffer
ALT1    =       $E7
ALT2    =       $E8
ALT3    =       $E9
ALT4    =       $EA
ALT5    =       $EB

APL0    =       $EC             ; Application General Registers
APL1    =       $ED
APL2    =       $EF
