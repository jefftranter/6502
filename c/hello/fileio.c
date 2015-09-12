/*
 * File input/output example.
 * Can compile with: cl65 -t apple2enh fileio.c
 */

#include <stdio.h>

int main(int argc, char *argv[])
{
    FILE *fp;
    size_t rc;
    char buffer[64];

    printf("File I/O demo\n");

    fp = fopen("test.txt", "w");
    if (fp == NULL) {
        printf("Error opening file for write.\n");
    } else {
        printf("Created file test.txt.\n");
    }

    rc = fwrite("Hello, world!\n", 1, 14, fp);
    printf("Wrote %d bytes to file (should be 14).\n", rc);

    fclose(fp);

    fp = fopen("test.txt", "r");
    if (fp == NULL) {
        printf("Error opening file for read.\n");
    } else {
        printf("Opened file test.txt.\n");
    }

    rc = fread(buffer, 1, 64, fp);
    printf("Read %d bytes from file (should be 14).\n", rc);

    /* Add terminating null */
    buffer[rc] = 0;

    printf("File contents:\n%s", buffer);

    fclose(fp);

    return 0;
}
