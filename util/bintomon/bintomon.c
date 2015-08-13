/*
 * Convert binary file to Woz monitor format.
 *
 * Copyright (C) 2012-2015 by Jeff Tranter <tranter@pobox.com>
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
 * usage: bintomon [-v] [-f] [-1] [-2] [-l <LoadAddress>] [-r <RunAddress>] <filename>
 *
 * The -l option and <LoadAddress> argument specifies the starting
 * memory address to load. The -r option and <RunAddress> argument
 * specifies the memory address to start execution. With the -f option
 * the LoadAddress and program length are read from the first 4 bytes
 * of the file. A -1 option specifies to use Apple 1 Woz Monitor
 * format. The -2 option specifies to use the Apple II Monitor format.
 * If no <LoadAddress> is specified, it defaults to
 * 0x280. If no <RunAddess> is specified, it defaults to the
 * <LoadAddress>. Addresses can be specified in decimal or hex
 * (prefixed with "0x"). A monitor run or go command is sent at the end of
 * the file. If <RunAddress> is "-" then the run command is not
 * generated in the output.
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

/* print command usage */
void usage(char *name) {
    fprintf(stderr, "usage: %s [-v] [-f] [-1] [-2] [-l <LoadAddress>] [-r <RunAddress>] <filename>\n", name);
}

int main(int argc, char *argv[])
{
    FILE *file;
    unsigned char b;
    int loadAddress = 0x280;
    int runAddress = -2;
    int length = -1;
    int address;
    unsigned char byte;
    int opt;
    size_t size;
    int fromFile = 0;
    int verbose = 0;
    int version = 1; // Use Apple 1 or Apple 2 foramt

    while ((opt = getopt(argc, argv, "v12fl:r:")) != -1) {
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

    address = loadAddress;
    printf("%04X:", address);

    while (fread(&byte, 1, 1, file) == 1) {
        printf(" %02X", byte);
        ++address;
        if ((address % 8) == 0)
            printf("\n:");
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
        if (length != -1)
            fprintf(stderr, "Length (from file): $%04X (%d bytes)\n", length, length);
        fprintf(stderr, "Length (calculated): $%04X (%d bytes)\n", address - loadAddress, address - loadAddress);

    }

    if (length != -1 && address != loadAddress + length) {
        fprintf(stderr, "Note: Last address does not match load address + length: $%04X\n", loadAddress + length);
    }

    return 0;
}
