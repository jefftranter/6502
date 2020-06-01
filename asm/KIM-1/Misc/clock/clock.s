; KIM-1 CLOCK LISTING BY LINDSAY MILLER, KILOBAUD MAGAZINE, FEB 1977 PG 80
; http://bytecollector.com/mos_kim_1.htm

; Clock Displays HHMMSS.
; Key in hours at 0060, minutes at 0061, seconds at 0062.
; Key in 0200, then GO.

        HOURS  = $60
        MINS   = $61
        SECS   = $62

        SCANDS = $1F1F
        DISPZ  = $185C

        .ORG   	$0200

START:  LDX     #$EA            ; SET NO. OF LOOPS FOR 1 SECOND
LOOP:   DEX
        LDA     HOURS           ; STORE HOURS IN Fb
        STA     $FB
        LDA     MINS            ; STORE MIN'S IN FA
        STA     $FA
        LDA     SECS            ; STORE SEC'S IN F9
        STA     $F9
        STX     $63             ; SAVE X
        STY     $64             ; (NOT NECESSARY, FILLER)      HR    MIN    SEC
        JSR     SCANDS          ; "SCANDS" (DISPLAY TIME)     1 0    1 0    0 1
        LDX     $63             ;                             Fb     FA     F9
        LDY     $64             ;                            (0060) (0061) (0062)
        CPX     #$00            ; TO LOOP (TO 0202)
        BNE     LOOP
        SED                     ; SET DECIMAL MODE TO AVOID HEX DIGITS             -|
        SEC                     ; SET CARRY                                         |
        LDA     #$00            ;                                                   |
        ADC     SECS            ; ADD A+C+M-->A (0+1+SEC-->ACC.)                    |_ COUNT
        STA     SECS            ; STORE IN 62 (SEC) (ACC--> 62)                     |  SECONDS
        CLD                     ; CLEAR DECIMAL MODE FOR "SCANDS"                   |
        CMP     #$60            ; TO LOOP (TO 0200) (RESETTING LOOP FOR NEW SECOND) |
        BNE     START           ;                                                  -|
        SED                     ;                                                  -|
        SEC                     ; SAME AS SECONDS                                   |
        LDA     #$00            ;                                                   |
        STA     SECS            ; RESET SEC TO 00                                   |
        ADC     MINS            ; ADD 0+1+MIN-->ACC                                 |_ COUNT
        STA     MINS            ; STORE IN 61 (MIN) (ACC-->61)                      |  MINUTES 
        CLD                     ;                                                   |
        CMP     #$60            ; TO LOOP (TO 0200)                                 |
        BNE     START           ;                                                  -|
        SED                     ; SAME AS MINUTES                                  -|
        SEC                     ;                                                   |
        LDA     #$00            ;                                                   |
        STA     SECS            ; RESET SEC TO 00                                   |_ COUNT
        STA     MINS            ; RESET MIN TO 00                                   |  HOURS
        ADC     HOURS           ; ADD 0+1+HRS-->ACC                                 |
        STA     HOURS           ;                                                   |
        CLD                     ;                         FOR 24 HR CLOCK           |
        CMP     #$13            ;                           47 C9, 24               |
        BNE     START           ;                           4b A9, 00              -|
        LDA     #$01            ; WHEN HOURS REACH 13,      4F C9, 00
        STA     HOURS           ; RESET HOURS TO 1
        CMP     #$01            ; TO LOOP (TO 0200) 
        BEQ     START
        JSR     DISPZ           ; DISPLAY 0000
