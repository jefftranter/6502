100; SAMPLE ASSEMBLY LANGUAGE PROGRAM
100;
1200; EXTERNAL ROUTINES
130CRLF    = $2D6A
140STROUT  = $2D73
150;
160        *=$3A79         ; Workspace load address (OS6D 3.3)
170        .WORD START     ; Source start (not used)
180        .WORD END       ; Source end (not used)
190       .BYTE  $01       ; Number of tracks
200                        ; Need to start execution at $3E7E (OS65D 3.3)
210START   JSR CRLF
220        JSR STROUT
230        .BYTE 'THIS IS A SAMPLE PROGRAM',0
240        JSR CRLF
250END     RTS
260        .END
