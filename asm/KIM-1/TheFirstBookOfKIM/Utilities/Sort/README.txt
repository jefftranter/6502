SORT
by Jim Pollock

This program will take any given block of data and
arrange it in numerical sequence, whether the data is
hex or BCD, or both. Since the program uses relative
branch addressing, it can be located anywhere in memory
without modification.

The instruction that determines whether data is arranged
in ascending or descending order is 011F, ( B0 -
descending order, 90 - ascending order).

This is a bubble sort. The top item is compared with
succeeding items and if a larger number is found, they
are swapped. The larger item (now at the top) is then
used for comparisons as the process continues through
the list. After one complete pass, the largest number
will have "bubbled" to the top. The whole process is
repeated using the second item to start, then again
starting with the third item. Eventually the whole list
will be sorted in sequence.
