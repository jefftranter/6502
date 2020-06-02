#include <unistd.h>
#include <algorithm>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <signal.h>
#include "sim6502.h"

/*

This is a 6502 simulator to simulate an Ohio Scientific Superboard II
computer.

It is written in standard C++ and should be portable, but has only
been tested on Linux with the gcc compiler.

Copyright (c) 2020 Jeff Tranter <tranter@pobox.com>

*/


// Use to flag when Control-C pressed.
bool control_c = false;

// Last address use by dump command.
int lastDumpAddress = 0;

// Last address use by unassenble command.
int lastDisassembleAddress = 0;

// Command line options.
int h_option = 0;
int v_option = 0;
int l_option = 0;
string filename = "";
int a_option = 0;
int r_option = 0;
int R_option = 0;


// Control-C handler used to interrupt execution.
void signal_callback_handler(int signum) {
    control_c = true;
}


// Display command line options usage.
void usage()
{
    cout << "Usage: sim6502 [<options>]" << endl;
    cout << "Options:" << endl;
    cout << "-h                   Show command line usage" << endl;
    cout << "-v                   Show software version and copyright" << endl;
    cout << "-l <file>            Load raw file into memory" << endl;
    cout << "-a <address>         Address to load raw file" << endl;
    cout << "-r <address>         Set PC to address" << endl;
    cout << "-R                   Don't reset on startup" << endl;
}


// Show version and license.
void showVersion()
{
    cout << "Sim6502 6502 simulator version 0.1" << endl;
    cout << "Copyright (c) 2020 Jeff Tranter <tranter@pobox.com>" << endl;
    cout << "Licensed under the Apache License, Version 2.0." << endl;
}


// Handle command line options.
static void parse_args(int argc, char **argv)
{
    const char *flags = "hvl:a:r:R";
    int c;

    while ((c = getopt(argc, argv, flags)) != EOF) {
        switch (c) {
        case 'h':
            h_option = 1;
            break;
        case 'v':
            v_option = 1;
            break;
        case'l':
            l_option = 1;
            filename = optarg;
            break;
        case'a':
            try {
                a_option = stoi(optarg, nullptr, 16);
            }
            catch (const std::invalid_argument &a) {
                std::cerr << "Invalid argument to -a option" << endl;
                exit(1);
            }
            break;
        case'r':
            try {
                r_option = stoi(optarg, nullptr, 16);
            }
            catch (const std::invalid_argument &a) {
                std::cerr << "Invalid argument to -r option" << endl;
                exit(1);
            }
            break;
        case'R':
            R_option = 1;
            break;
        case '?':
            exit(1);
            break;
        }
    }
}


int main(int argc, char **argv)
{
    // Parse the command line arguments
    parse_args(argc, argv);

    // Set some output defaults.
    cout << uppercase << hex;

    if (h_option) {
        usage();
        exit(0);
    }

    if (v_option) {
        showVersion();
        exit(0);
    }

    showVersion();

    // Set up Control-C interrupt handler
    signal(SIGINT, signal_callback_handler);

    // Settings for Ohio Scientific Superboard II
    Sim6502 sim;
    sim.setRamRange(0x0000, 0x7fff); // 32K
    sim.setRomRange1(0xa000, 0xbfff); // Basic
    sim.setRomRange2(0xf800, 0xffff); // Monitor
    sim.setVideoRange(0xd000, 0xd3ff);
    sim.setPeripheral(Sim6502::MC6850, 0xf000);
    sim.setKeyboard(0xdf00);

    if (!sim.loadMemory("syn600.rom", 0xf800)) {
        return 1;
    }
    if (!sim.loadMemory("basic1.rom", 0xa000)) {
        return 1;
    }
    if (!sim.loadMemory("basic2.rom", 0xa800)) {
        return 1;
    }
    if (!sim.loadMemory("basic3.rom", 0xb000)) {
        return 1;
    }
    if (!sim.loadMemory("basic4.rom", 0xb800)) {
        return 1;
    }

    // Filename to load specified on command line.
    if (l_option) {
        if (!sim.loadMemory(filename, a_option)) {
            return 1;
        }
        cout << "Loaded " << filename << " at address $" << uppercase << hex << setfill('0') << setw(4) << a_option << endl;
    }

    if (!R_option) {
        sim.reset();
    }

    if (r_option) {
        sim.setPC(r_option);
    }

    while (true) {
        string line;

        cout << "> " << flush;
        getline(cin, line);

        if (cin.eof()) {
            cout << endl;
            exit(0);
        }

        // Vector of string to save tokens
        vector <string> tokens;

        // stringstream class check1
        stringstream check1(line);

        string intermediate;

        // Tokenizing on space
        while (getline(check1, intermediate, ' ')) {
            tokens.push_back(intermediate);
        }

        if (tokens.size() > 0) {

            if (tokens[0] == "?") {
                cout << "Commands:" << endl;
                cout << "Breakpoint   B [-][<address>]" << endl;
                cout << "Dump         D [<start>] [<end>]" << endl;
                cout << "Go           G [<address>]" << endl;
                cout << "Logging      L [<+/-><category>]" << endl;
                cout << "Memory       M <address> <data> ..." << endl;
                cout << "Options      O" << endl;
                cout << "Quit         Q" << endl;
                cout << "Registers    R [<register> <value>]" << endl;
                cout << "Unassemble   U [<address>] [<end>]" << endl;
                cout << "Dump Video   V" << endl;
                cout << "Watchpoint   W [-][<address>] r,w,rw" << endl;
                cout << "Reset        X" << endl;
                cout << "Step         . [<instructions>]" << endl;
                cout << "Step Over    +" << endl;
                cout << "Send IRQ     IRQ" << endl;
                cout << "Send NMI     NMI" << endl;
                cout << "Help         ?" << endl;

            } else if (tokens[0] == "q" || tokens[0] == "Q") {
                exit(0);

            } else if (tokens[0] == ".") {
                try {
                    int instructions = 1;
                    // Get optional number of instructions to step
                    if (tokens.size() == 2) {
                        instructions = stoi(tokens[1], nullptr, 16);
                    }
                    control_c = false;
                    for (int i = 0; i < instructions; i++) {
                        sim.step();
                        if (control_c) {
                            cout << endl << "Control-C interrupt" << endl;
                            break;
                        }
                        if (sim.stop()) {
                            cout << "Stopped due to " << sim.stopReason() << endl;
                            break;
                        }
                    }
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;

                }

            } else if (tokens[0] == "+") {
                sim.step(true);

            } else if (tokens[0] == "r" || tokens[0] == "R") {
                try {
                    if (tokens.size() == 3) {
                        // User specified register name and new value
                        // PC 1234 A 01 X 02 Y 03 SP 04 P 05
                        if ((tokens[1] == "pc") || (tokens[1] == "PC")) {
                            sim.setPC(stoi(tokens[2], nullptr, 16));
                        } else if ((tokens[1] == "a") || (tokens[1] == "A")) {
                            sim.setAReg(stoi(tokens[2], nullptr, 16));
                        } else if ((tokens[1] == "x") || (tokens[1] == "X")) {
                            sim.setXReg(stoi(tokens[2], nullptr, 16));
                        } else if ((tokens[1] == "y") || (tokens[1] == "Y")) {
                            sim.setYReg(stoi(tokens[2], nullptr, 16));
                        } else if ((tokens[1] == "sp") || (tokens[1] == "SP")) {
                            sim.setSP(stoi(tokens[2], nullptr, 16));
                        } else if ((tokens[1] == "p") || (tokens[1] == "P")) {
                            sim.setPReg(stoi(tokens[2], nullptr, 16));
                        } else {
                            cout << "Invalid argument" << endl;
                        }
                    }
                    if (tokens.size() == 1 || tokens.size() == 3) {
                        sim.dumpRegisters();
                    } else {
                        cout << "Invalid argument" << endl;
                    }
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;
                }

            } else if ((tokens[0] == "d" || tokens[0] == "D")) {
                try {
                    int start, end;

                    // Start address specified
                    if (tokens.size() > 1) {
                        start = stoi(tokens[1], nullptr, 16);
                    } else {
                        // Default start to last end address plus one.
                        start = lastDumpAddress;
                    }

                    // End address specified
                    if (tokens.size() > 2) {
                        end = stoi(tokens[2], 0, 16);
                    } else {
                        // Default to dumping 16 addresses.
                        end = start + 15;
                    }
                    sim.dumpMemory(start, end);
                    lastDumpAddress = end + 1;
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;
                }

            } else if ((tokens[0] == "u" || tokens[0] == "U")) {
                try {
                    int start, end;

                    // Start address specified
                    if (tokens.size() > 1) {
                        start = stoi(tokens[1], nullptr, 16);
                    } else {
                        // Default start to last end address plus one.
                        start = lastDisassembleAddress;
                    }

                    // End address specified
                    if (tokens.size() > 2) {
                        end = stoi(tokens[2], 0, 16);
                    } else {
                        // Default to disassembling 16 addresses.
                        end = start + 15;
                    }
                    lastDisassembleAddress = sim.disassembleMemory(start, end);
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;
                }

            } else if ((tokens[0] == "b" || tokens[0] == "B")) {
                try {
                    if (tokens.size() == 1) {
                        // List breakpoints
                        for (auto b: sim.getBreakpoints()) {
                            cout << "Breakpoint at $" << hex << setw(4) <<  b << endl;
                        }
                    } else if (tokens.size() == 2) {
                        // Clear breakpoint
                        int address = stoi(tokens[1], nullptr, 16);
                        if (address > 0) {
                            cout << "Adding breakpoint at $" << hex << setw(4) << address << endl;
                            sim.setBreakpoint(address);
                        } else {
                            cout << "Removing breakpoint at $" << hex << setw(4) << -address << endl;
                            sim.clearBreakpoint(-address);
                        }
                    }
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;
                }

            } else if ((tokens[0] == "w" || tokens[0] == "W")) {
                try {
                    if (tokens.size() == 1) {
                        // List watchpoints
                        for (auto b: sim.getReadWatchpoints()) {
                            cout << "Read watchpoint at $" << hex << setw(4) <<  b << endl;
                        }
                        for (auto b: sim.getWriteWatchpoints()) {
                            cout << "Write watchpoint at $" << hex << setw(4) <<  b << endl;
                        }
                    } else if (tokens.size() == 3) {
                        int address = stoi(tokens[1], nullptr, 16);
                        string type = tokens[2];
                        if (type != "r" && type != "w" && type != "rw") {
                            cout << "Invalid argument" << endl;
                        } else {
                            if (type == "r" || type == "rw") {
                                if (address > 0) {
                                    cout << "Adding read watchpoint at $" << hex << setw(4) << address << endl;
                                    sim.setReadWatchpoint(address);
                                } else {
                                    cout << "Removing read watchpoint at $" << hex << setw(4) << -address << endl;
                                    sim.clearReadWatchpoint(-address);
                                }
                            }
                            if (type == "w" || type == "rw") {
                                if (address > 0) {
                                    cout << "Adding write watchpoint at $" << hex << setw(4) << address << endl;
                                    sim.setWriteWatchpoint(address);
                                } else {
                                    cout << "Removing write watchpoint at $" << hex << setw(4) << -address << endl;
                                    sim.clearWriteWatchpoint(-address);
                                }
                            }
                        }
                    } else {
                        cout << "Invalid argument" << endl;
                    }
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid argument" << endl;
                }

            } else if ((tokens[0] == "g" || tokens[0] == "G")) {
                try {
                    // Get optional go address
                    if (tokens.size() == 2) {
                        int address;
                        address = stoi(tokens[1], nullptr, 16);
                        sim.setPC(address);
                    }

                    // Run until breakpoint hit.
                    std::list<uint16_t> breakpoints = sim.getBreakpoints();

                    control_c = false;
                    while (true) {
                        sim.step();
                        if (std::find(breakpoints.begin(), breakpoints.end(), sim.pc()) != breakpoints.end()) {
                            cout << "Breakpoint hit at $" << hex << setw(4) << sim.pc() << endl;
                            sim.dumpRegisters();
                            break;
                        }
                        if (control_c) {
                            cout << endl << "Control-C interrupt" << endl;
                            break;
                        }
                        if (sim.stop()) {
                            cout << "Stopped due to " << sim.stopReason() << endl;
                            break;
                        }
                    }
                }
                catch (const std::invalid_argument &a) {
                    cout << "Invalid address argument" << endl;
                }

            } else if ((tokens[0] == "x" || tokens[0] == "X")) {
                sim.reset();

            } else if ((tokens[0] == "v" || tokens[0] == "V")) {
                sim.dumpVideo();

            } else if ((tokens[0] == "irq" || tokens[0] == "IRQ")) {
                sim.irq();

            } else if ((tokens[0] == "nmi" || tokens[0] == "NMI")) {
                sim.nmi();

            } else if ((tokens[0] == "l" || tokens[0] == "L")) {
                if (tokens.size() == 1) {
                    sim.loggingStatus();
                }
                if (tokens.size() == 2) {
                    string category = tokens[1];
                    if (category[0] == '+') {
                        sim.enableLogging(category.substr(1), true);
                    } else if (category[0] == '-') {
                        sim.enableLogging(category.substr(1), false);
                    } else {
                        cout << "Invalid argument" << endl;
                    }
                }

            } else if ((tokens[0] == "m" || tokens[0] == "M")) {
                if (tokens.size() < 3) {
                    cout << "Invalid argument" << endl;
                } else {
                    int address;
                    try {
                        address = stoi(tokens[1], nullptr, 16);
                    }
                    catch (const std::invalid_argument &a) {
                        address = 0x10000; // To make it fail later
                    }
                    for (unsigned int i = 2; i < tokens.size(); i++) {
                        int data;
                        try {
                            data = stoi(tokens[i], nullptr, 16);
                        }
                        catch (const std::invalid_argument &a) {
                            data = 0x100; // To make it fail later
                        }
                        if (address > 0xffff) {
                            cout << "Invalid address argument" << endl;
                            break;
                        }
                        if (data > 0xff) {
                            cout << "Invalid data argument" << endl;
                            break;
                        }
                        sim.write(address - 2 + i, data);
                    }
                }

            } else if ((tokens[0] == "o" || tokens[0] == "O")) {
                string line;
                cout << "Set Options (type new value or <Enter> to leave unchanged)" << endl;
                cout <<  "Stop on invalid instruction (" << (sim.stopInvalid() ? "Y/n" : "y/N") << ")? " << flush;
                getline(cin, line);
                if (line == "y" || line == "Y") {
                    sim.setStopInvalid(true);
                } else if (line == "n" || line == "N") {
                    sim.setStopInvalid(false);
                }
                cout <<  "Stop on BRK instruction (" << (sim.stopBrk() ? "Y/n" : "y/N") << ")? " << flush;
                getline(cin, line);
                if (line == "y" || line == "Y") {
                    sim.setStopBrk(true);
                } else if (line == "n" || line == "N") {
                    sim.setStopBrk(false);
                }
                cout << "Serial input file (" << sim.serialInputFile() << ")? " << flush;
                getline(cin, line);
                if (!line.empty()) {
                    sim.setSerialInputFile(line);
                }
                cout << "Serial output file (" << sim.serialOutputFile() << ")? " << flush;
                getline(cin, line);
                if (!line.empty()) {
                    sim.setSerialOutputFile(line);
                }

            } else {
                cout << "Invalid command. Type '?' for help." << endl;
            }
        }
    }

    return 0;
}
