CRAPS
BY JIM BUTTERFIELD

DESCRIPTION -
      SET ADDRESS 0200, THEN HOLD "GO" DOWN .. YOU'LL SEE:
          - 2 DICE "ROLLING" ON THE LEFT
          - $10 BALANCE ON THE RIGHT
      LET "GO" ... THE DICE WILL STOP ROLLING, AND YOU'LL GET:
          - A WIN ON A TOTAL OF 7 OR 11; YOU'LL SEE YOUR DOLLAR
            BALANCE RISE; OR
          - A LOSS ON TOTALS OF 2,3, OR 12; YOUR DOLLAR BALANCE
            WILL DROP; OR
          - A "POINT" - THE CENTER SEGMENTS WILL LIGHT WITH THE
            ROLL AND YOU MUST TRY TO ROLL THIS TOTAL AGAIN
            BEFORE YOU ROLL 7 -
      PUSH THE "GO" BUTTON ONLY ON THE FIRST ROLL. FOR SUBSEQUENT
      ROLLS, PUSH ANOTHER BUTTON.

Coding notes: CRAPS is a highly top-down program.
    The program always flows from START to LIGHT and
    back again with few breaks in sequence. The dice
    are randomized from TIMER (1704) and RNDLP contains
    a small division routine, dividing by 6; the
    remainder, randomly 0 to 5, gives the roll of
    one die. On the first roll of a run, we use
    the table at 02C8 to analyze the total: in this
    table, FF means you lose and 01 means you win.
    FLAG is zero if you're not pushing any button.
    Segments for the display are stored in table
    WINDOW, 0046 to 004B.
