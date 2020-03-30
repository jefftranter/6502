This is a port of fig-FORTH 6502 to the Ohio Scientific Model
600/Superboard II.

The original code was downloaded from https://dwheeler.com/6502

It is assembled for a system with 8K of RAM. If you have more memory,
adjust the value of MEM accordingly. Not a lot of memory is left for
program storage in an 8K system.

Input/output uses the screen and keyboard. If you want to use the
serial port, uncomment the relevant lines defining OUTCH and INCH.

The MON command will go to the OSI monitor.
