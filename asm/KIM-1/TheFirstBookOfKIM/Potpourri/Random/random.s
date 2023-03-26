; Random number generator program from p.172 of The First Book of KIM.

; NOTES ON A RANDOM NUMBER GENERATOR  Jim Butterfield
;
; It's not my original idea - I picked it up from a technical
; journal many years ago. Wish I could remember the source,
; so I could credit it.
;
; This program produces reasonably random numbers, and it won't
; "lock up" so that the same number starts coming out over and
; over again. The numbers are scattered over the entire range
; of hexadecimal 00 to FF. A Statistician would observe that
; the numbers aren't completely "unbiased", since a given
; series of numbers will tend to favor odd or even numbers slightly.
; But it's simple, and works well in many applications.
; 
; Here's how it works. Suppose the last five random numbers
; that we have produced were A, B, C, D and E. We'll make a
; new random number by calculating A + B + E + 1. (the one
; at the end is there so we don't get locked up on all zeros).
; When we add all these together, we may get a carry, but
; we just ignore it. That's all. The new "last five" will
; now be B, C, D, E and the new number. To keep everything
; straight, we move all these over one place, so that B goes
; where A uses to be, and so on.
;
; The program:

        .ORG    $0200

        RND    = $12

RAND:   CLD             ; clear decimal if needed
        SEC             ; carry adds value 1
        LDA    RND+1    ; last value (E)
        ADC    RND+4    ; add B (+ carry)
        ADC    RND+5    ; add C
        STA    RND      ; new number
        LDX    #4       ; move 5 numbers
RPL:    LDA    RND,X
        STA    RND+1,X  ; ..move over 1
        DEX
        BPL    RPL      ; all moved?

; The new random number will be in A, and in RND, and in RND+1.
; Note that you must use six values in page zero to hold the
; random string ... I have used 0012 to 0017 in the above coding.
;
; You often don't want a random number that goes all the way
; to 255 (Hexadecimal FF). There are two ways of reducing
; this range. You can AND out the bits you don't want;
; for example, AND #$7 reduces the range to 0-7 only.
; Alternatively, you can write a small divide routine, and
; the *remainder* becomes your random number; examples of this
; can be seen in programs such as BAGELS.
