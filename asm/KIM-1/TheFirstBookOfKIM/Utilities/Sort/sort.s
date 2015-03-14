; 17F5       START LO
; 17F6       START HIGH
; 17F7       END LO
; 17F8       END HI    (NOTE: ENDING ADDRESS IS ONE PAST LAST ITEM)

        .ORG    $0200

SORT:   LDA     $17F5           ; TRANSFER START POINTER
        STA     $00E8           ; TO ZERO PAGE
        STA     $00EA
        LDA     $17F6
        STA     $00E9
        STA     $00EB
        LDA     $17F7           ; TRANSFER END POINTER
        STA     $00EC
        LDA     $17F8
        STA     $00ED
        LDX     #$00            ; INDEX TO ZERO (STAYS THERE)
        CLD
GET:    LDA     ($00E8,X)       ; GET DATA INDIRECT 00E8
        CMP     ($00EA,X)       ; GREATER THAN INDIR. 00EA
        BCS     INCN            ; NO, INCR. POINTER 00EA
SWAP:   LDA     ($00E8,X)       ; SWAP DATA IN POINTER
        STA     $00E7           ; LOCATIONS
        LDA     ($00EA,X)
        STA     ($00E8,X)
        LDA     $00E7
        STA     ($00EA,X)
INCN:   INC     $00EA           ; SET UP NEXT COMPARISON
        BNE     LASTN           ; NO PAGE CHANGE
        INC     $00EB           ; PAGE CHANGE
LASTN:  LDA     $00EA           ; OK FOR LAST ITEM IN PASS
        CMP     $00EC
        BNE     GET             ; NOT YET
        LDA     $00ED           ; IS THIS LAST PASS/LOOP?
        CMP     $00EB
        BNE     GET             ; NO
        INC     $00E8
        BNE     OVER            ; NO PAGE CHANGE
        INC     $00E9           ; PAGE CHANGE
OVER:   LDA     $00E8           ; INIT. VALUE FOR NEXT PASS
        STA     $00EA
        LDA     $00E9
        STA     $00EB
        LDA     $00EA           ; LAST ITEM IN LIST?
        CMP     $00EC
        BNE     GET             ; NO, NOT YET
        LDA     $00E9
        STA     $00EB
        CMP     $00ED           ; LAST PAGE?
        BNE     GET             ; NO
        JMP     $1C4F           ; BACK TO KIM/ DONE
