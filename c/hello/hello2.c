#include <stdio.h>
#include <stdlib.h>
#include <apple1.h>

int main (void)
{
    int i   = 0;
    short x = 1;
    char c  = 2;
    long l  = 3;

    for (i = 0; i < 10; i++) {
        printf("%d %d %d\n", i, i*i, i*i*i);
    }

    printf("SIZEOF(CHAR) = %d\n",sizeof(char));
    printf("SIZEOF(SHORT) = %d\n",sizeof(short));
    printf("SIZEOF(INT) = %d\n",sizeof(int));
    printf("SIZEOF(LONG) = %d\n",sizeof(long));

    printf("PRESS A KEY TO CONTINUE\n");

    while (!keypressed())
        ;
    i = readkey();
    printf("KEY WAS: %c\n", i);

    return 0;
}
