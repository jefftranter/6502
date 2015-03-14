Verify Tape
James Van Ornum

     Do you want to verify the cassette tape you just recorded before the
information is lost?  Then follow this simple procedure:

        1.  Manually verify that the starting address ($17F3, $17F6), the
            ending address ($17F7, $17F8) and the block identification
            ($17F9) locations are correct in memory.

        2.  Enter zeros ($00) into CHKL ($17E7) and CHKH ($17E8).

        3.  Enter the following routine:

                 17EC  CD  00  00   VEB     cmp  START
                 17EF  D0  03               bne    failed
                 17F1  4C  0F  19           jmp  LOAD12
                 17F4  4C  29  19   failed  jmp  LOADT9

        4.  Rewind the tape, enter address $188C, press GO and playback
            the tape.  If the tape compares, the LEDs will come back on
            with address $0000.  If there is a discrepancy between memory
            and the tape, the LEDs will come on with address $FFFF.
