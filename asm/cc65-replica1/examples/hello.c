#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <conio.h>

int main (void)
{
    int i   = 0;
    short x = 1;
    char c  = 2;
    long l  = 3;
    char buffer[80];

    clrscr();

    for (i = 0; i < 100; i++) {
        printf("%d %d %d\n", i, i*i, i*i*i);
    }

    printf("SIZEOF(CHAR) = %d\n",sizeof(char));
    printf("SIZEOF(SHORT) = %d\n",sizeof(short));
    printf("SIZEOF(INT) = %d\n",sizeof(int));
    printf("SIZEOF(LONG) = %d\n",sizeof(long));

    while (kbhit()) {
        read(0, buffer, 1);
    }

    printf("Press a key to continue\n");
    while (!kbhit())
        ;

    printf("Enter a line of text to continue\n");
    fgets(buffer, sizeof(buffer)-1, stdin);
    printf("KEY WAS: %s\n", buffer);

    return 0;
}
