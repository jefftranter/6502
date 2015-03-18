; KIM-1 CLOCK LISTING BY LINDSAY MILLER, KILOBAUD MAGAZINE, FEB 1977 PG 80
; http://bytecollector.com/mos_kim_1.htm

; Clock Displays HHMMSS.
; Key in hours at OO60, minutes at 0061, seconds at 0062.
; Key in 0200, then GO.

        .ORG   	$0200
 
START:  LDX     #$EA            ; SET NO. OF LOOPS FOR 1 SECOND
LOOP:   DEX
        LDA     $60             ; STORE HOURS IN Fb
        STA     $FB
        LDA     $61             ; STORE MIN'S IN FA
        STA     $FA
        LDA     $62             ; STORE SEC'S IN F9
        STA     $F9
        STX     $63             ; SAVE X
        STY     $64             ; (NOT NECESSARY, FILLER)      HR    MIN    SEC
        JSR     $1F1F           ; "SCANDS" (DISPLAY TIME)     1 0    1 0    0 1
        LDX     $63             ;                             Fb     FA     F9
        LDY     $64             ;                            (0060) (0061) (0062)
        CPX     #$00            ; TO LOOP (TO 0202)
        BNE     LOOP
        SED                     ; SET DECIMAL MODE TO AVOID HEX DIGITS             -|
        SEC                     ; SET CARRY                                         |
        LDA     #$00            ;                                                   |
        ADC     $62             ; ADD A+C+M-->A (0+1+SEC-->ACC.)                    |_ COUNT
        STA     $62             ; STORE IN 62 (SEC) (ACC--> 62)                     |  SECONDS
        CLD                     ; CLEAR DECIMAL MODE FOR "SCANDS"                   |
        CMP     #$60            ; TO LOOP (TO 0200) (RESETTING LOOP FOR NEW SECOND) |
        BNE     START           ;                                                  -|
        SED                     ;                                                  -|
        SEC                     ; SAME AS SECONDS                                   |
        LDA     #$00            ;                                                   |
        STA     $62             ; RESET SEC TO 00                                   |
        ADC     $61             ; ADD 0+1+MIN-->ACC                                 |_ COUNT
        STA     $61             ; STORE IN 61 (MIN) (ACC-->61)                      |  MINUTES 
        CLD                     ;                                                   |
        CMP     #$60            ; TO LOOP (TO 0200)                                 |
        BNE     START           ;                                                  -|
        SED                     ; SAME AS MINUTES                                  -|
        SEC                     ;                                                   |
        LDA     #$00            ;                                                   |
        STA     $62             ; RESET SEC TO 00                                   |_ COUNT
        STA     $61             ; RESET MIN TO 00                                   |  HOURS
        ADC     $60             ; ADD 0+1+HRS-->ACC                                 |
        STA     $60             ;                                                   |
        CLD                     ;                         FOR 24 HR CLOCK           |
        CMP     #$13            ;                           47 C9, 24               |
        BNE     START           ;                           4b A9, 00              -|
        LDA     #$01            ; WHEN HOURS REACH 13,      4F C9, 00
        STA     $60             ; RESET HOURS TO 1
        CMP     #$01            ; TO LOOP (TO 0200) 
        BEQ     START
        JSR     $185C           ; DISPLAY 0000 
