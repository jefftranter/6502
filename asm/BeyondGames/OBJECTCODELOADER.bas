100 REM                          OBJECT CODE LOADER by Ken Skier
110 REM
120 DIM BYTE(8)                  :REM Initialize BYTE array.
130 READ FIRST                   :REM Get the line number of the first
140 REM                          DATA statement containing object code.
150 READ LAST                    :REM Get the line number of the last
160 REM                          DATA statement containing object code.
170 FOR LINE=FIRST TO LAST       :REM Read the specified DATA lines.
180 GOSUB 300                    :REM Load next data line into memory.
190 NEXT LINE                    :REM If not done, read next DATA line.
200 PRINT "LOADED LINES",FIRST,"THROUGH",LAST,"SUCCESSFULLY."
210 END                          :REM If done, say so.
220 REM
230 REM                          Subroutine at 300 handles one
240 REM                          DATA statement.
300 READ A                       :REM Get address for object code.
310 SUM=A                        :REM Initialize calculated sum of data.
320 FOR J=1 TO 8                 :REM Get 8 bytes of object code from
321 REM                          data.
330 READ BYTE(J)                 :REM Put them in the byte array, and
340 SUM=SUM+BYTE(J)              :REM add them to the calculated sum of
341 REM                          data
350 NEXT J                       :REM Now we have the 8 bytes, and we
360 REM                          have calculated the sum of the data.
370 READ CHECK                   :REM Get checksum from data line.
380 IF SUM <> CHECK THEN 500     :REM If checksum error, handle it.
390 FOR J=1 TO 8                 :REM Since there is no checksum error,
400 POKE A+J-1,BYTE(J)           :REM poke the data into the specified
410 NEXT J                       :REM portion of memory,
420 RETURN                       :REM and return to caller.
430 REM
440 REM                          Checksum error-handling code follows.
500 PRINT "CHECKSUM ERROR IN DATA LINE",LINE
510 PRINT "START ADDRESS GIVEN IN BAD DATA LINE IS",A
520 END
530 REM                          The next two DATA statements specify
540 REM                          the range of DATA statements that
550 REM                          contain object code.
570 REM
600 DATA 1000                    :REM This should be the number of the
610 REM                          first DATA statement containing object
611 REM                          code.
612 REM
620 DATA 2102                    :REM This should be the number of the
630 REM                          last DATA statement containing object
631 REM                          code.
