CLOCK
- Charles Parsons

     This clock routine uses KIM's built in interval timer with the
interrupt option.  It works by loading $F4 into the timer (/1024) each
time the Non-Maskable Interrupt (NMI) occurs.  This theoretically pro-
duce a time of 249,856 microseconds or just under 1/4 second.  The adjust-
ment to 1/4 second is done with the timer (/1) in the interrupt routine.
A fine adjustment of the clock can be made by modifying the value in
location $0366.  Only two subroutines will be documented here (ESCAPE
TO KIM & HOUR CHIME) but many more can be added by simply replacing
the NOP codes starting at $03DE with jumps to your own subroutines.
For instance, a home control system could be set up using the clock
program.

     The escape to KIM allows KIM to run without stopping the clock.
This means that you can run other programs simultaneously with the
clock program unless your program also needs to use the NMI (such as
single step operation) or if there could be a timing problem (such as
with the audio tape operation).  Pressing the KIM GO button will get
you out of the KIM loop.

     To start the clock:

          1.  Connect PB7 (A-15) to NMI (E-6).
          2.  Initialize NMI pointer (17FA, 17FB) with 60 and 03.
          3.  Set up the time and AM-PM counter locations in page
              zero.
          4.  Go to address $03C0 and press GO.

     To get back into the clock display mode if the clock is run-
ning - start at location $03C9.

     NOTE:  These routines are not listed in any particular order
so be watchful of the addresses when you load them.
