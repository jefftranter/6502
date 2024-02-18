This builds firmware that contains:
1. The JMON machine language monitor.
2. Microsoft Basic (based on Grant Searle's port of OSI Basic).
3. A program that prompts on boot whether to load JMON or Basic (based
   on Grant Searle's code).

Another option is wozmon.bin which only contains a port of the Woz
Monitor from the Apple 1. It does not include Basic.

By default Basic is the 6 digit OSI version. If you comment out the
line with "CONFIG_SMALL := 1" in osi_basic.s, it will build Basic with
9 digits of floating point precision (and longer error messages). This
provides more accuracy at the expense of speed.

9-digit example output:

```
?SQR(2)
 1.41421356 
XX
?SYNTAX ERROR
```

6-digit example output:

```
?SQR(2)
 1.41421 
XX
?SN ERROR
```

Speed comparison, using the David Ahl Basic benchmark (2 MHz clock):

```
 10 REM Ahl's Simple Benchmark
 20 FOR N=1 TO 100: A=N
 30 FOR I=1 TO 10
 40 A=SQR(A): R=R+RND(1)
 50 NEXT I
 60 FOR I=1 TO 10
 70 A=A^2: R=R+RND(1)
 80 NEXT I
 90 S=S+A: NEXT N
 100 PRINT ABS(1010-S/5)
 110 PRINT ABS(1000-R)
```

9-digit version: 58 seconds

6-digit version: 40 seconds

Fun fact: OSI promoted their version of Basic as being faster than
many other microcomputers. They didn't mention that it was because
they were one of the few companies that shipped the 6 digit version of
Microsoft Basic, while others provided the 9 digit version.
