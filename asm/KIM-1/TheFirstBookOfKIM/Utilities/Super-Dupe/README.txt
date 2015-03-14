SUPER-DUPE
Jim Butterfield

SUPER-DUPE is handy: it lets you duplicate a complete tape
containing many programs in jig time. SUPER-DUPE is
versatile: it will write various tape densities, from
regular to Hypertape . SUPER-DUPE is multi-purpose: if you
don't want to duplicate programs, you can use it for
cataloguing tapes, or for writing Hypertape.

The maximum size program that SUPER-DUPE can copy is
dependent on the amount of memory of the KIM system. The
basic 1K system can copy programs up to 512 bytes long.

For duplicating tape, it's useful to have two tape
recorders: one for reading the old tape, one for writing
the new. They are connected in the usual way, at TAPE IN
and TAPE OUT. Pause controls are handy.

SUPER-DUPE starts at address 0000. Hit GO and start the
input tape. When a program has been read from the input
tape, the display will light, showing the start address of
the program and its ID. If you don't want to copy this
program, hit 0. Otherwise, stop the input tape; start the
output tape (on RECORD) ; then hit 1 for Hypertape , 6 for
regular tape, or any intermediate number. The output tape
will be written; upon completion, the display will light
showing 0000 A2. Stop the output tape. Now bit GO to copy
the next program.

SUPER-DUPE contains a Hypertape writing program which can
be used independently; this starts at address 0100.

Basically, SUPER-DUPE saves you the work of setting up the
SA, EA, and ID for each program, and the trouble of
arranging the Hypertape writer into a part of memory
suitable for each program.

REMEMBER: You must also include HYPERTAPE! (page 119).
