/*
 * Convert binary file to Woz monitor format.
 *
 * Copyright (C) 2012-2018 by Jeff Tranter <tranter@pobox.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * usage: bintomon [-h] [-v] [-f] [-1] [-2] [-b <bytes>] [-l <LoadAddress>] [-r <RunAddress>] [-c <fill>] <filename>
 *
 * The -h option will display the command usage and exit.
 * The -l option and <LoadAddress> argument specifies the starting
 * memory address to load. The -r option and <RunAddress> argument
 * specifies the memory address to start execution. With the -f option
 * the LoadAddress and program length are read from the first 4 bytes
 * of the file. A -1 option specifies to use Apple 1 Woz Monitor
 * format. The -2 option specifies to use the Apple II Monitor format.
 * The -b option specifies how many data bytes per line (defaults to 8).
 * If no <LoadAddress> is specified, it defaults to
 * 0x280. If no <RunAddess> is specified, it defaults to the
 * <LoadAddress>. Addresses can be specified in decimal or hex
 * (prefixed with "0x"). A monitor run or go command is sent at the end of
 * the file. If <RunAddress> is "-" then the run command is not
 * generated in the output.
 * The -c option causes lines containing only the specified fill
 * character to be skipped. Typically this is used when the input file
 * contains long runs of all zeros or FF.
 * With the -v option verbose output is sent to standard error listing
 * the load and run address and program size.
 *
 * Examples:
 * bintomon myprog.bin
 * bintomon -v -f myprog.bin
 * bintomon -l 0x300 myprog.bin
 * bintomon -l 0x280 -r 0x300 myprog.bin
 *
 */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <stdbool.h>

/* print command usage */
void usage(char *name) {
    fprintf(stderr, "usage: %s [-h] [-v] [-f] [-1] [-2] [-b <Bytes>] [-l <LoadAddress>] [-r <RunAddress>] [-c <Fill>] <Filename>\n", name);
}

/* Show help info */
void showHelp(char *name)
{
    usage(name);
    fprintf(stderr,
            "\n-h  Show help info and exit.\n"
            "-v  Show verbose output.\n"
            "-f  Get load address and length from first 4 bytes of file.\n"
            "-1  Use Apple 1 Woz Monitor format.\n"
            "-2  Use Apple II Monitor format.\n"
            "-b <Bytes>  Specify how many data bytes per line (defaults to 8).\n"
            "-l <LoadAddress>  Specify beginning load address (defaults to 0x280).\n"
            "-r <RunAddress>  Specify program run/start address (defaults to load address).\n"
            "-c <Fill>  Skip lines containing the specified fill character.\n\n"
            "Addresses can be specified in decimal or hex (prefixed with 0x). A\n"
            "monitor run or go command is sent at the end of the file. If run address\n"
            "is - then the run command is not generated in the output.\n");
}

/* Return if an array of length n contains all fill characters. */
bool allFill(unsigned char bytes[], int n, int fill)
{
    for (int i = 0; i < n; i++) {
        if (bytes[i] != fill)
            return false;
    }
    return true;
}

int main(int argc, char *argv[])
{
    FILE *file;
    unsigned char b;
    int loadAddress = 0x280;
    int runAddress = -2;
    int length = -1;
    int address;
    int bytesPerLine = 8;
    unsigned char bytes[255];
    int opt;
    size_t size;
    int fromFile = 0;
    int verbose = 0;
    int version = 1; // Use Apple 1 or Apple 2 format
    bool skipFill = false;
    unsigned char fillChar = 0;

    while ((opt = getopt(argc, argv, "hv12fl:r:b:c:")) != -1) {
        switch (opt) {
        case 'f':
            fromFile = 1;
            break;
        case 'v':
            verbose = 1;
            break;
        case '1':
            version = 1;
            break;
        case '2':
            version = 2;
            break;
        case 'l':
            loadAddress = strtol(optarg, 0, 0);
            break;
        case 'r':
            if (!strcmp(optarg, "-")) {
                runAddress = -1;
            } else {
                runAddress = strtol(optarg, 0, 0);
            }
            break;
        case 'b':
            bytesPerLine = strtol(optarg, 0, 0);
            break;
        case 'c':
            fillChar = strtol(optarg, 0, 0);
            skipFill = true;
            break;
        case 'h':
            showHelp(argv[0]);
            exit(EXIT_SUCCESS);
        default:
            usage(argv[0]);
            exit(EXIT_FAILURE);
        }
    }

    if (argc != optind + 1) {
        usage(argv[0]);
        exit(EXIT_FAILURE);
    }

    file = fopen(argv[optind], "rb");
    if (file == NULL) {
        fprintf(stderr, "%s: Unable to open '%s'\n", argv[0], argv[optind]);
        return 1;
    }

    if (fromFile) {
        /* read load address from file */
        size = fread(&b, 1, 1, file);
        assert(size == 1);
        loadAddress = b;
        size = fread(&b, 1, 1, file);
        assert(size == 1);
        loadAddress += b << 8;

        /* read length from file */
        size = fread(&b, 1, 1, file);
        assert(size == 1);
        length = b;
        size = fread(&b, 1, 1, file);
        assert(size == 1);
        length += b << 8;
    }

    /* If not set, run address is load address */
    if (runAddress == -2)
        runAddress = loadAddress;

    /* Set current address to load address. */
    address = loadAddress;

    /* Set flag when we need to print the address for data. */
    bool printAddress = true;

    int printed = 0;

    // Repeat until end of file:
    //   Read a line's worth of bytes
    //   If the entire line is fill chars
    //     Skip it and advance address.
    //     Set flag that we need to print address.
    //   Else
    //     Print address if needed.
    //     Clear print address flag.
    //     Print the line (or less) of data.

    int n;
    while ((n = fread(&bytes, 1, bytesPerLine, file)) != 0) {
        if (skipFill && allFill(bytes, n, fillChar)) {
            address += n;
            printAddress = true;
        } else {
            if (printAddress) {
                printf("%04X:", address);
            }
            printAddress = false;
            for (int i = 0; i < n; i++) {
                printf(" %02X", bytes[i]);
                address++;
                printed++;
                if ((printed % bytesPerLine) == 0) {
                    printf("\n:");
                    printed = 0;
                }
            }
        }
    }
    printf("\n");
    fclose(file);

    // Add run address
    if (runAddress != -1) {
        if (version == 1) {
            printf("%04XR\n", runAddress);
        }
        if (version == 2) {
            printf("%04XG\n", runAddress);
        }
    }

    if (verbose) {
        fprintf(stderr, "Load address: $%04X\n", loadAddress);
        if (runAddress != -1)
            fprintf(stderr, "Run address: $%04X\n", runAddress);
        else
            fprintf(stderr, "Run address: none \n");
        fprintf(stderr, "Last address: $%04X\n", address -1 );
        if (skipFill) {
            fprintf(stderr, "Skipping fill character: $%02X\n", fillChar);
        }
        if (length != -1)
            fprintf(stderr, "Length (from file): $%04X (%d bytes)\n", length, length);
        fprintf(stderr, "Length (calculated): $%04X (%d bytes)\n", address - loadAddress, address - loadAddress);

    }

    if (length != -1 && address != loadAddress + length) {
        fprintf(stderr, "Note: Last address does not match load address + length: $%04X\n", loadAddress + length);
    }

    return 0;
}
